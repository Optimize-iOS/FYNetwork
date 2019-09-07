//
//  NSURLConnection+Monitor.m
//  FYNetworkMonitor
//
//  Created by JackJin on 2019/9/6.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "NSURLConnection+Monitor.h"
#import "FYDelegateProxy.h"
#import <objc/runtime.h>

@interface _FYURLConnextionProxy : FYDelegateProxy

@end

@implementation _FYURLConnextionProxy

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([NSStringFromSelector(aSelector) isEqualToString:@"connectionDidFinishLoading:"]) {
        return YES;
    }
    
    return [super respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [super forwardInvocation:invocation];
    
    if ([NSStringFromSelector(invocation.selector) isEqualToString:@"connectionDidFinishLoading:"]) {
        NSURLConnection *con;
        [invocation getArgument:&con atIndex:2];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSDictionary *timDic = [con performSelector:NSSelectorFromString(@"_timingData")];
#pragma clang diagnostic pop
        
        //TODO
        NSLog(@"<class:%@ method:%s> timing data: %@", NSStringFromClass(self.class), __func__, timDic);
    }
}


@end


@implementation NSURLConnection (Monitor)

#pragma mark - LifeCycle

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        Method originalMethod = class_getClassMethod(class, @selector(initWithRequest:delegate:));
        Method swizzleMethod = class_getClassMethod(class, @selector(swizzle_initWithRequest:delegate:));
        
        if (originalMethod && swizzleMethod) {
            method_exchangeImplementations(originalMethod, swizzleMethod);
        }
        
        SEL setTimSel = NSSelectorFromString(@"_setCollectsTimingData:");
        [NSURLConnection performSelector:setTimSel withObject:@(YES)];
    });
}


#pragma mark - Private

- (instancetype)swizzle_initWithRequest:(NSURLRequest *)request delegate:(id)delegate {
    if (delegate) {
        _FYURLConnextionProxy *proxy = [[_FYURLConnextionProxy alloc] initWithTarget:delegate];
        
        objc_setAssociatedObject(delegate, @"_FYURLConnextionProxy", proxy, OBJC_ASSOCIATION_RETAIN);
        return [self swizzle_initWithRequest:request delegate:proxy];
        
    }else {
        return [self swizzle_initWithRequest:request delegate:delegate];
    }
}

@end
