
//
//  FYURLProtocol.m
//  FYHttpURLProtocol
//
//  Created by JackJin on 2019/8/30.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "FYURLProtocol.h"
#import <WebKit/WKWebView.h>
#import "QNUrlSafeBase64.h"


FOUNDATION_STATIC_INLINE Class ContextControllerClass() {
    static Class cls;
    if (!cls) {
        NSData *decodeData = [QNUrlSafeBase64 decodeString:@"YnJvd3NpbmdDb250ZXh0Q29udHJvbGxlcg=="];
        NSString *decodeString = [[NSString alloc] initWithData:decodeData encoding:NSUTF8StringEncoding];
        
        cls = [[[WKWebView new] valueForKey:decodeString] class];
    }
    
    return cls;
}

FOUNDATION_STATIC_INLINE SEL RegisterSchemeSelector() {
    NSData *decodeData = [QNUrlSafeBase64 decodeString:@"cmVnaXN0ZXJTY2hlbWVGb3JDdXN0b21Qcm90b2NvbDo="];
    NSString *decodeSting = [[NSString alloc] initWithData:decodeData encoding:NSUTF8StringEncoding];
    
    return NSSelectorFromString(decodeSting);
}

FOUNDATION_STATIC_INLINE SEL UnregisterSchemeSelector() {
    NSData *decodeData = [QNUrlSafeBase64 decodeString:@"dW5yZWdpc3RlclNjaGVtZUZvckN1c3RvbVByb3RvY29sOg=="];
    NSString *decodeSting = [[NSString alloc] initWithData:decodeData encoding:NSUTF8StringEncoding];
    
    return NSSelectorFromString(decodeSting);
}


static NSString *kUrlProtocolKey = @"kUrlProtocolKey";


@interface FYURLProtocol ()<NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *task;

@end


@implementation FYURLProtocol


#pragma mark - Class

+ (void)start {
    [NSURLProtocol registerClass:self];
}

+ (void)end {
    [NSURLProtocol unregisterClass:self];
}

+ (void)registerWKWebView {
    [FYURLProtocol wk_registerScheme:@"http"];
    [FYURLProtocol wk_registerScheme:@"https"];
}

+ (void)unregisterWKWebView {
    [FYURLProtocol wk_unregisterScheme:@"http"];
    [FYURLProtocol wk_unregisterScheme:@"https"];
}


#pragma mark - Override

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([NSURLProtocol propertyForKey:kUrlProtocolKey inRequest:request]) {
        return NO;
    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [NSURLProtocol setProperty:@(YES) forKey:kUrlProtocolKey inRequest:mutableRequest];
    
    return [mutableRequest copy];
}

- (void)startLoading {
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    self.task = [session dataTaskWithRequest:self.request];
    
    [self.task resume];
}

- (void)stopLoading {
    [self.task cancel];
    self.task = nil;
}


#pragma mark - Private

+ (void)wk_registerScheme:(NSString *)scheme {
    Class cls = ContextControllerClass();
    SEL sel = RegisterSchemeSelector();
    
    if ([(id)cls respondsToSelector:sel]) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [(id)cls performSelector:sel withObject:scheme];
#pragma clang diagnostic pop
    }
}

+ (void)wk_unregisterScheme:(NSString *)scheme {
    Class cls = ContextControllerClass();
    SEL sel = UnregisterSchemeSelector();
    
    if ([(id)cls respondsToSelector:sel]) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [(id)cls performSelector:sel withObject:scheme];
#pragma clang diagnostic pop
    }
}


#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [[self client] URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
    }else {
        [self.client URLProtocolDidFinishLoading:self];
    }
}

@end
