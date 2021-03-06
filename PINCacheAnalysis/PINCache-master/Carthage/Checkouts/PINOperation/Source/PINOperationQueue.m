//
//  PINOperationQueue.m
//  Pods
//
//  Created by Garrett Moon on 8/23/16.
//
//

#import "PINOperationQueue.h"
#import <pthread.h>

@class PINOperation;

@interface NSNumber (PINOperationQueue) <PINOperationReference>

@end

@interface PINOperationQueue () {
  pthread_mutex_t _lock;
  //increments with every operation to allow cancelation
  NSUInteger _operationReferenceCount; //当前引用计数
  NSUInteger _maxConcurrentOperations;
  
  dispatch_group_t _group; //
  
  dispatch_queue_t _serialQueue; //串行任务队列
  BOOL _serialQueueBusy;
  
  dispatch_semaphore_t _concurrentSemaphore;
  dispatch_queue_t _concurrentQueue;
  //
  dispatch_queue_t _semaphoreQueue;
  
  //在 Operation Queue 中所有任务的队列
  NSMutableOrderedSet<PINOperation *> *_queuedOperations;
  //根据当前优先级初始化三个对用的 order 集合
  NSMutableOrderedSet<PINOperation *> *_lowPriorityOperations;
  NSMutableOrderedSet<PINOperation *> *_defaultPriorityOperations;
  NSMutableOrderedSet<PINOperation *> *_highPriorityOperations;
  
  //请求引用任务的 --> 集合字典
  NSMapTable<id<PINOperationReference>, PINOperation *> *_referenceToOperations;
  //请求唯一表示任务 --> 集合字典
  NSMapTable<NSString *, PINOperation *> *_identifierToOperations;
}

@end

@interface PINOperation : NSObject //PIN operation | 下载的操作任务

@property (nonatomic, strong) PINOperationBlock block;
@property (nonatomic, strong) id <PINOperationReference> reference;
@property (nonatomic, assign) PINOperationQueuePriority priority;
@property (nonatomic, strong) NSMutableArray<dispatch_block_t> *completions;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) id data;

+ (instancetype)operationWithBlock:(PINOperationBlock)block reference:(id <PINOperationReference>)reference priority:(PINOperationQueuePriority)priority identifier:(nullable NSString *)identifier data:(nullable id)data completion:(nullable dispatch_block_t)completion;

- (void)addCompletion:(nullable dispatch_block_t)completion;

@end

@implementation PINOperation

+ (instancetype)operationWithBlock:(PINOperationBlock)block reference:(id<PINOperationReference>)reference priority:(PINOperationQueuePriority)priority identifier:(NSString *)identifier data:(id)data completion:(dispatch_block_t)completion
{
  PINOperation *operation = [[self alloc] init];
  operation.block = block;
  operation.reference = reference;
  operation.priority = priority;
  operation.identifier = identifier;
  operation.data = data;
  [operation addCompletion:completion];
  
  return operation;
}

- (void)addCompletion:(dispatch_block_t)completion
{
  if (completion == nil) {
    return;
  }
  if (_completions == nil) {
    _completions = [NSMutableArray array];
  }
  [_completions addObject:completion];
}

@end

@implementation PINOperationQueue

- (instancetype)initWithMaxConcurrentOperations:(NSUInteger)maxConcurrentOperations
{
  return [self initWithMaxConcurrentOperations:maxConcurrentOperations concurrentQueue:dispatch_queue_create("PINOperationQueue Concurrent Queue", DISPATCH_QUEUE_CONCURRENT)];
}

- (instancetype)initWithMaxConcurrentOperations:(NSUInteger)maxConcurrentOperations concurrentQueue:(dispatch_queue_t)concurrentQueue
{
  if (self = [super init]) {
    NSAssert(maxConcurrentOperations > 0, @"Max concurrent operations must be greater than 0.");
    _maxConcurrentOperations = maxConcurrentOperations;
    _operationReferenceCount = 0;
    
    //TODO
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    //mutex must be recursive to allow scheduling of operations from within operations
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&_lock, &attr);
    
    _group = dispatch_group_create();
    
    _serialQueue = dispatch_queue_create("PINOperationQueue Serial Queue", DISPATCH_QUEUE_SERIAL);
    
    _concurrentQueue = concurrentQueue;
    
    //Create a queue with max - 1 because this plus the serial queue add up to max.
    _concurrentSemaphore = dispatch_semaphore_create(_maxConcurrentOperations - 1);
    _semaphoreQueue = dispatch_queue_create("PINOperationQueue Serial Semaphore Queue", DISPATCH_QUEUE_SERIAL);
    
    _queuedOperations = [[NSMutableOrderedSet alloc] init];
    _lowPriorityOperations = [[NSMutableOrderedSet alloc] init];
    _defaultPriorityOperations = [[NSMutableOrderedSet alloc] init];
    _highPriorityOperations = [[NSMutableOrderedSet alloc] init];
    
    _referenceToOperations = [NSMapTable weakToWeakObjectsMapTable];
    _identifierToOperations = [NSMapTable weakToWeakObjectsMapTable];
  }
  return self;
}

- (void)dealloc
{
  pthread_mutex_destroy(&_lock);
}

+ (instancetype)sharedOperationQueue
{
    static PINOperationQueue *sharedOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedOperationQueue = [[PINOperationQueue alloc] initWithMaxConcurrentOperations:MAX([[NSProcessInfo processInfo] activeProcessorCount], 2)];
    });
    return sharedOperationQueue;
}

- (id <PINOperationReference>)nextOperationReference
{
  [self lock];
    id <PINOperationReference> reference = [NSNumber numberWithUnsignedInteger:++_operationReferenceCount];
  [self unlock];
  return reference;
}

// Deprecated
- (id <PINOperationReference>)addOperation:(dispatch_block_t)block
{
  return [self scheduleOperation:block];
}

- (id <PINOperationReference>)scheduleOperation:(dispatch_block_t)block
{
  return [self scheduleOperation:block withPriority:PINOperationQueuePriorityDefault];
}

// Deprecated
- (id <PINOperationReference>)addOperation:(dispatch_block_t)block withPriority:(PINOperationQueuePriority)priority
{
  return [self scheduleOperation:block withPriority:priority];
}

//Step-Save 3.1
- (id <PINOperationReference>)scheduleOperation:(dispatch_block_t)block withPriority:(PINOperationQueuePriority)priority
{
  //把相关操作转为当前 queue 队列中单个任务
  PINOperation *operation = [PINOperation operationWithBlock:^(id data) { block(); }
                                                   reference:[self nextOperationReference]
                                                    priority:priority
                                                  identifier:nil
                                                        data:nil
                                                  completion:nil];
  [self lock];
    [self locked_addOperation:operation];//在当前 Queue 添加当前任务
  [self unlock];
  
  [self scheduleNextOperations:NO];
  
  return operation.reference;
}

// Deprecated
- (id<PINOperationReference>)addOperation:(PINOperationBlock)block
                             withPriority:(PINOperationQueuePriority)priority
                               identifier:(NSString *)identifier
                           coalescingData:(id)coalescingData
                      dataCoalescingBlock:(PINOperationDataCoalescingBlock)dataCoalescingBlock
                               completion:(dispatch_block_t)completion
{
  return [self scheduleOperation:block
                    withPriority:priority
                      identifier:identifier
                  coalescingData:coalescingData
             dataCoalescingBlock:dataCoalescingBlock
                      completion:completion];
}

- (id<PINOperationReference>)scheduleOperation:(PINOperationBlock)block
                                  withPriority:(PINOperationQueuePriority)priority
                                    identifier:(NSString *)identifier
                                coalescingData:(id)coalescingData
                           dataCoalescingBlock:(PINOperationDataCoalescingBlock)dataCoalescingBlock
                                    completion:(dispatch_block_t)completion
{
  id<PINOperationReference> reference = nil;
  BOOL isNewOperation = NO;
  
  [self lock];
    PINOperation *operation = nil;
    if (identifier != nil && (operation = [_identifierToOperations objectForKey:identifier]) != nil) {
      // There is an exisiting operation with the provided identifier, let's coalesce these operations
      if (dataCoalescingBlock != nil) {
        operation.data = dataCoalescingBlock(operation.data, coalescingData);
      }
      
      [operation addCompletion:completion];
    } else {
      isNewOperation = YES;
      operation = [PINOperation operationWithBlock:block
                                         reference:[self nextOperationReference]
                                          priority:priority
                                        identifier:identifier
                                              data:coalescingData
                                        completion:completion];
      [self locked_addOperation:operation];
    }
    reference = operation.reference;
  [self unlock];
  
  if (isNewOperation) {
    [self scheduleNextOperations:NO];
  }
  
  return reference;
}

//Step-Save 3.2
- (void)locked_addOperation:(PINOperation *)operation
{
  NSMutableOrderedSet *queue = [self operationQueueWithPriority:operation.priority];
  
  dispatch_group_enter(_group); //
  [queue addObject:operation];
  [_queuedOperations addObject:operation];
  [_referenceToOperations setObject:operation forKey:operation.reference];
  if (operation.identifier != nil) {
    [_identifierToOperations setObject:operation forKey:operation.identifier];
  }
}

- (void)cancelAllOperations
{
  [self lock];
    for (PINOperation *operation in [[_referenceToOperations copy] objectEnumerator]) {
      [self locked_cancelOperation:operation.reference];
    }
  [self unlock];
}


- (BOOL)cancelOperation:(id <PINOperationReference>)operationReference
{
  [self lock];
    BOOL success = [self locked_cancelOperation:operationReference];
  [self unlock];
  return success;
}

- (NSUInteger)maxConcurrentOperations
{
  [self lock];
    NSUInteger maxConcurrentOperations = _maxConcurrentOperations;
  [self unlock];
  return maxConcurrentOperations;
}

- (void)setMaxConcurrentOperations:(NSUInteger)maxConcurrentOperations
{
  NSAssert(maxConcurrentOperations > 0, @"Max concurrent operations must be greater than 0.");
  [self lock];
    __block NSInteger difference = maxConcurrentOperations - _maxConcurrentOperations;
    _maxConcurrentOperations = maxConcurrentOperations;
  [self unlock];
  
  if (difference == 0) {
    return;
  }
  
  dispatch_async(_semaphoreQueue, ^{
    while (difference != 0) {
      if (difference > 0) {
        dispatch_semaphore_signal(_concurrentSemaphore);
        difference--;
      } else {
        dispatch_semaphore_wait(_concurrentSemaphore, DISPATCH_TIME_FOREVER);
        difference++;
      }
    }
  });
}

#pragma mark - private methods

- (BOOL)locked_cancelOperation:(id <PINOperationReference>)operationReference
{
  BOOL success = NO;
  PINOperation *operation = [_referenceToOperations objectForKey:operationReference];
  if (operation) {
    NSMutableOrderedSet *queue = [self operationQueueWithPriority:operation.priority];
    if ([queue containsObject:operation]) {
      success = YES;
      [queue removeObject:operation];
      [_queuedOperations removeObject:operation];
      dispatch_group_leave(_group);
    }
  }
  return success;
}

- (void)setOperationPriority:(PINOperationQueuePriority)priority withReference:(id <PINOperationReference>)operationReference
{
  [self lock];
    PINOperation *operation = [_referenceToOperations objectForKey:operationReference];
    if (operation && operation.priority != priority) {
      NSMutableOrderedSet *oldQueue = [self operationQueueWithPriority:operation.priority];
      [oldQueue removeObject:operation];
      
      operation.priority = priority;
      
      NSMutableOrderedSet *queue = [self operationQueueWithPriority:priority];
      [queue addObject:operation];
    }
  [self unlock];
}

/**
 Schedule next operations schedules the next operation by queue order onto the serial queue if
 it's available and one operation by priority order onto the concurrent queue.
 
 */
//Step-Save 3.3
- (void)scheduleNextOperations:(BOOL)onlyCheckSerial
{
  
  ///串行执行
  [self lock];
  
    //get next available operation in order, ignoring priority and run it on the serial queue
    if (_serialQueueBusy == NO) {
      PINOperation *operation = [self locked_nextOperationByQueue];
      if (operation) {
        _serialQueueBusy = YES;
        dispatch_async(_serialQueue, ^{
          
          //Step-Save 3.6.1 Done!!!
          operation.block(operation.data);
          ///
          for (dispatch_block_t completion in operation.completions) {
            completion();
          }
          //Enter
          dispatch_group_leave(_group);
          
          [self lock];
            _serialQueueBusy = NO;
          [self unlock];
          
          //see if there are any other operations
          [self scheduleNextOperations:YES];
        });
      }
    }
  
  NSInteger maxConcurrentOperations = _maxConcurrentOperations;
  
  [self unlock];
  
  //从当前执行中返回
  if (onlyCheckSerial) {
    return;
  }

  //if only one concurrent operation is set, let's just use the serial queue for executing it
  if (maxConcurrentOperations < 2) {
    return;
  }
  
  ///并行执行
  dispatch_async(_semaphoreQueue, ^{
    //根据执行任务数量 加锁🔐
    dispatch_semaphore_wait(_concurrentSemaphore, DISPATCH_TIME_FOREVER);
    [self lock];
      PINOperation *operation = [self locked_nextOperationByPriority];
    [self unlock];
  
    if (operation) {
      dispatch_async(_concurrentQueue, ^{
        
        //Step-Save 3.6.2 Done!!!
        operation.block(operation.data);
        for (dispatch_block_t completion in operation.completions) {
          completion();
        }
        dispatch_group_leave(_group);
        dispatch_semaphore_signal(_concurrentSemaphore);
      });
    } else {
      dispatch_semaphore_signal(_concurrentSemaphore);
    }
  });
}

- (NSMutableOrderedSet *)operationQueueWithPriority:(PINOperationQueuePriority)priority
{
  switch (priority) {
    case PINOperationQueuePriorityLow:
      return _lowPriorityOperations;
      
    case PINOperationQueuePriorityDefault:
      return _defaultPriorityOperations;
      
    case PINOperationQueuePriorityHigh:
      return _highPriorityOperations;
          
    default:
      NSAssert(NO, @"Invalid priority set");
      return _defaultPriorityOperations;
  }
}

//Call with lock held
- (PINOperation *)locked_nextOperationByPriority
{
  PINOperation *operation = [_highPriorityOperations firstObject];
  if (operation == nil) {
    operation = [_defaultPriorityOperations firstObject];
  }
  if (operation == nil) {
    operation = [_lowPriorityOperations firstObject];
  }
  if (operation) {
    [self locked_removeOperation:operation];
  }
  return operation;
}

//Call with lock held
//Step-Save 3.4
- (PINOperation *)locked_nextOperationByQueue
{
  //获取当前操作 | 把操作从相应的优先级队列以及所有操作队列中 remove
  PINOperation *operation = [_queuedOperations firstObject];
  [self locked_removeOperation:operation];
  return operation;
}

- (void)waitUntilAllOperationsAreFinished
{
  [self scheduleNextOperations:NO];
  dispatch_group_wait(_group, DISPATCH_TIME_FOREVER);
}

//Call with lock held
//Step-Save 3.5
- (void)locked_removeOperation:(PINOperation *)operation
{
  if (operation) {
    NSMutableOrderedSet *priorityQueue = [self operationQueueWithPriority:operation.priority];
    [priorityQueue removeObject:operation];
    [_queuedOperations removeObject:operation];
  }
}

//lock 采用 pthread_mutex_lock
- (void)lock
{
  pthread_mutex_lock(&_lock);
}

- (void)unlock
{
  pthread_mutex_unlock(&_lock);
}

@end
