//
//  NSURLSession+FY.m
//  FYHttpURLProtocol
//
//  Created by JackJin on 2019/8/30.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "NSURLSession+FY.h"
#import <objc/runtime.h>
#import "FYURLProtocol.h"


@implementation NSURLSession (FY)


#pragma mark - Override

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originMethod = class_getClassMethod([NSURLSession class], @selector(sessionWithConfiguration:));
        Method swizzleMethod = class_getClassMethod([self class], @selector(swizzle_sessionWithConfiguration:));
        
        if (originMethod && swizzleMethod) {
            method_exchangeImplementations(originMethod, swizzleMethod);
        }
        
        originMethod = class_getClassMethod([NSURLSession class], @selector(sessionWithConfiguration:delegate:delegateQueue:));
        swizzleMethod = class_getClassMethod([self class], @selector(swizzle_sessionWithConfiguation:delegate:delegateQueue:));
        
        if (originMethod && swizzleMethod) {
            method_exchangeImplementations(originMethod, swizzleMethod);
        }
        
    });
}


#pragma mark - Private

+ (NSURLSession *)swizzle_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration {
    NSURLSessionConfiguration *newConfiguration = configuration;
    
    if (!newConfiguration) {
        return nil;
    }
    
    newConfiguration.protocolClasses = @[[FYURLProtocol class]];
    return [self swizzle_sessionWithConfiguration:newConfiguration];
}

+ (NSURLSession *)swizzle_sessionWithConfiguation:(NSURLSessionConfiguration *)configuration delegate:(id<NSURLSessionDataDelegate>)delegate delegateQueue:(NSOperationQueue *)queue {
    NSURLSessionConfiguration *newConfiguration = configuration;
    
    if (!newConfiguration) {
        return nil;
    }
    
    newConfiguration.protocolClasses = @[[FYURLProtocol class]];
    return [self swizzle_sessionWithConfiguation:newConfiguration delegate:delegate delegateQueue:queue];
}

@end
