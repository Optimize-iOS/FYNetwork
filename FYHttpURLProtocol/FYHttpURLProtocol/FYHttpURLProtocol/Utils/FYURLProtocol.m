
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
#import "FYNetworkMonitorDataModel.h"
#import "FYNetworkMonitorErrorDataModel.h"
#import "NSURLSession+FY.h"
#import "NSURLRequest+FY.h"
#import "NSURLResponse+FY.h"


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
@property (nonatomic, strong) NSOperationQueue *sessionDelegateQueue;

@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) FYNetworkMonitorDataModel *dataModel;
@property (nonatomic, strong) FYNetworkMonitorErrorDataModel *errorModel;

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
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.sessionDelegateQueue = [[NSOperationQueue alloc] init];
    self.sessionDelegateQueue.maxConcurrentOperationCount = 1;
    self.sessionDelegateQueue.name = @"com.fy.httpurl.protocol";
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:self.sessionDelegateQueue];
    
    self.task = [session dataTaskWithRequest:self.request];
    
    [self.task resume];
}

- (void)stopLoading {
    NSURLResponse *response = self.task.response;
    self.dataModel.responseStatusLineLength = [response statusLineLength];
    self.dataModel.requestHeadersLength = [response headersLength];
    self.dataModel.requestBodyLength = [response boyLengthWithReceiveData:self.receivedData.copy];
    
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
    [self.receivedData appendData:data];
    [[self client] URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics {
    if (@available(iOS 10.0, *)) {
        if ([metrics.transactionMetrics count] <= 0) return;
        
        [metrics.transactionMetrics enumerateObjectsUsingBlock:^(NSURLSessionTaskTransactionMetrics * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.fetchStartDate) {
                self.dataModel.requestDate = [obj.fetchStartDate timeIntervalSince1970] * 1000;
            }
            
            if (obj.domainLookupStartDate && obj.domainLookupEndDate) {
                self.dataModel.waitDNSTime = ceil([obj.domainLookupStartDate timeIntervalSinceDate:obj.fetchStartDate] * 1000);
                self.dataModel.dnsLookupTime = ceil([obj.domainLookupEndDate timeIntervalSinceDate:obj.domainLookupStartDate] * 1000);
            }
            
            if (obj.connectStartDate && obj.connectEndDate) {
                self.dataModel.tcpTime = ceil([obj.connectEndDate timeIntervalSinceDate:obj.connectStartDate] * 1000);
            }
            
            if (obj.secureConnectionEndDate && obj.secureConnectionStartDate) {
                self.dataModel.sslTime = ceil([obj.secureConnectionEndDate timeIntervalSinceDate:obj.secureConnectionStartDate] * 1000);
            }
            
            if (obj.fetchStartDate && obj.responseEndDate) {
                self.dataModel.requestTime = ceil([obj.responseEndDate timeIntervalSinceDate:obj.fetchStartDate] * 1000);
            }
            
            self.dataModel.httpProtocol = obj.networkProtocolName;
            
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)obj.response;
            NSURLRequest *request = obj.request;
            if ([response isKindOfClass:NSHTTPURLResponse.class]) {
                self.dataModel.receiveBytes = response.expectedContentLength;
            }
            
            NSString *remoteDecodeString = [[NSString alloc] initWithData:[QNUrlSafeBase64 decodeString:@"X3JlbW90ZUFkZHJlc3NBbmRQb3J0"] encoding:NSUTF8StringEncoding];
            if ([obj respondsToSelector:NSSelectorFromString(remoteDecodeString)]) {
                self.dataModel.ip = [obj valueForKey:remoteDecodeString];
            }
            
            NSString *requestDecodeString = [[NSString alloc] initWithData:[QNUrlSafeBase64 decodeString:@"X3JlcXVlc3RIZWFkZXJCeXRlc1NlbnQ="] encoding:NSUTF8StringEncoding];
            if ([obj respondsToSelector:NSSelectorFromString(requestDecodeString)]) {
                self.dataModel.sendBytes = [[obj valueForKey:requestDecodeString] unsignedIntegerValue];
            }
            
            NSString *responseDecodeString = [[NSString alloc] initWithData:[QNUrlSafeBase64 decodeString:@"X3Jlc3BvbnNlSGVhZGVyQnl0ZXNSZWNlaXZlZA=="] encoding:NSUTF8StringEncoding];
            if ([obj respondsToSelector:NSSelectorFromString(responseDecodeString)]) {
                self.dataModel.receiveBytes = [[obj valueForKey:responseDecodeString] unsignedIntegerValue];
            }
            
            self.dataModel.requestUrl = [obj.request.URL absoluteString];
            self.dataModel.httpMethod = obj.request.HTTPMethod;
            self.dataModel.httpCode = response.statusCode;
            self.dataModel.useProxy = obj.isProxyConnection;
            self.dataModel.requestLineLength = [request lineLength];
            self.dataModel.requestHeadersLength = [request headersLength];
            self.dataModel.requestBodyLength = [request bodyLenth];
        }];
        
        //upload dataModel to apm system
        
        NSLog(@"data model: %@ responseData: %llu", self.dataModel, self.dataModel.requestDate);
    }
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
    }else {
        [self.client URLProtocolDidFinishLoading:self];
    }
    
    if (error) {
        NSURLRequest *request = task.currentRequest;
        NSURLResponse *response = task.response;
        if (request) {
            self.errorModel.requestUrl = request.URL.absoluteString;
            self.errorModel.httpMethod = request.HTTPMethod;
            self.errorModel.requestParamters = request.URL.query;
        }
        
        self.errorModel.errorCode = error.code;
        self.errorModel.exceptionName = error.domain;
        self.errorModel.exceptionDetail = error.description;
        self.errorModel.requestLineLength = [request lineLength];
        self.errorModel.requestHeadersLength = [request headersLength];
        self.errorModel.requestBodyLength = [request bodyLenth];
        self.errorModel.responseStatusLineLength = [response statusLineLength];
        self.errorModel.requestHeadersLength = [response headersLength];
        self.errorModel.requestBodyLength = [response boyLengthWithReceiveData:self.receivedData];
        
        //upload errorModel to apm system
        
        NSLog(@"error model: %@", self.errorModel);
    }
    
    self.task = nil;
}


#pragma mark - Lazying

- (NSMutableData *)receivedData {
    if (_receivedData == nil) {
        _receivedData = [NSMutableData data];
    }
    
    return _receivedData;
}

- (FYNetworkMonitorDataModel *)dataModel {
    if (_dataModel == nil) {
        _dataModel = [[FYNetworkMonitorDataModel alloc] init];
    }
    
    return _dataModel;
}

- (FYNetworkMonitorErrorDataModel *)errorModel {
    if (_errorModel == nil) {
        _errorModel = [[FYNetworkMonitorErrorDataModel alloc] init];
    }
    
    return _errorModel;
}

@end
