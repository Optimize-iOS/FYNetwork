//
//  FYDelegateProxy.m
//  FYNetworkMonitor
//
//  Created by JackJin on 2019/9/6.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "FYDelegateProxy.h"

@implementation FYDelegateProxy


#pragma mark - LifeCycle

- (instancetype)initWithTarget:(id)target {
    self.target = target;
    return self;
}


#pragma mark - Override

- (void)forwardInvocation:(NSInvocation *)invocation {
    if (!self.target) {
        return;
    }
    
    if ([self.target respondsToSelector:invocation.selector]) {
        [self.target forwardInvocation:invocation];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    if (!self.target) {
        return [NSMethodSignature signatureWithObjCTypes:"v@"];
    }
    
    return [self.target methodSignatureForSelector:sel];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [self.target respondsToSelector:aSelector];
}


@end
