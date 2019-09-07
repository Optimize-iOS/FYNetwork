//
//  NSURLSession+Monitor.m
//  FYNetworkMonitor
//
//  Created by JackJin on 2019/9/6.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "NSURLSession+Monitor.h"
#import "FYDelegateProxy.h"
#import <objc/runtime.h>


@interface _FYURLSession : FYDelegateProxy

@end

@implementation _FYURLSession

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([NSStringFromSelector(aSelector) isEqualToString:@"URLSession:task:didFinishCollectingMetrics:"]) {
        return YES;
    }else if ([NSStringFromSelector(aSelector) isEqualToString:@"URLSession:task:didCompleteWithError:"]) {
        return YES;
    }
    
    return [super respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [super forwardInvocation:invocation];
    
    if (@available(iOS 10.0, *)) {
        if ([NSStringFromSelector(invocation.selector) isEqualToString:@"URLSession:task:didFinishCollectingMetrics:"]) {
            NSURLSessionTaskMetrics *metr;
            [invocation setArgument:&metr atIndex:4];
            
            //TODO
            NSLog(@"<class:%@ method:%s> metrics data: %@", NSStringFromClass(self.class), __func__, metr);
        }
        
    }else {
        if ([NSStringFromSelector(invocation.selector) isEqualToString:@"URLSession:task:didCompleteWithError:"]) {
            NSURLSessionTask *sessTask;
            [invocation setArgument:&sessTask atIndex:3];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            NSDictionary *timDic = [sessTask performSelector:NSSelectorFromString(@"_timingData")];
#pragma clang diagnostic pop
            
            //TODO
            NSLog(@"<class:%@ method:%s> timDic data: %@", NSStringFromClass(self.class), __func__, timDic);
        }
        
    }
}

@end



@implementation NSURLSession (Monitor)

#pragma mark - LifeCycle

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        Method originalMethod = class_getClassMethod(class, @selector(sessionWithConfiguration:delegate:delegateQueue:));
        Method swizzleMethod = class_getClassMethod(class, @selector(swizzle_sessionWithConfiguration:delegate:delegateQueue:));
        
        method_exchangeImplementations(originalMethod, swizzleMethod);
        
    });
}


#pragma mark - Private

+ (NSURLSession *)swizzle_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(id<NSURLSessionDelegate>)delegate delegateQueue:(NSOperationQueue *)queue {
    if (delegate) {
        SEL setTimSel = NSSelectorFromString(@"set_collectsTimingData:");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [configuration performSelector:setTimSel withObject:@(YES)];
#pragma clang diagnostic pop
        
        _FYURLSession *ses = [[_FYURLSession alloc] initWithTarget:delegate];
        objc_setAssociatedObject(self, @"_FYURLSession", ses, OBJC_ASSOCIATION_RETAIN);
        return [self swizzle_sessionWithConfiguration:configuration delegate:(id<NSURLSessionDelegate>)ses delegateQueue:queue];
    }else {
        return [self swizzle_sessionWithConfiguration:configuration delegate:delegate delegateQueue:queue];
    }
}

@end
