//
//  ViewController.m
//  FYHttpURLProtocol
//
//  Created by JackJin on 2019/8/29.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "ViewController.h"
#import "FYURLProtocol.h"
#import "QNUrlSafeBase64.h"


@interface ViewController ()<NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //NSLog(@"WKWebView ContextController Base 64: %@", [QNUrlSafeBase64 encodeString:@"browsingContextController"]);
    //NSLog(@"WKWebView register Protocol Base 64: %@", [QNUrlSafeBase64 encodeString:@"registerSchemeForCustomProtocol:"]);
    //NSLog(@"WKWebView register Protocol Base 64: %@", [QNUrlSafeBase64 encodeString:@"unregisterSchemeForCustomProtocol:"]);
    //NSLog(@"_remoteAddressAndPort register Protocol Base 64: %@", [QNUrlSafeBase64 encodeString:@"_remoteAddressAndPort"]);
    //NSLog(@"_requestHeaderBytesSent register Protocol Base 64: %@", [QNUrlSafeBase64 encodeString:@"_requestHeaderBytesSent"]);
    //NSLog(@"_responseHeaderBytesReceived register Protocol Base 64: %@", [QNUrlSafeBase64 encodeString:@"_responseHeaderBytesReceived"]);
    
    
    [FYURLProtocol start];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.jianshu.com/u/c48ed5ae3925"]];
    //NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    self.dataTask = [session dataTaskWithRequest:request];
    
    [self.dataTask resume];
}


#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSLog(@"%p length of data is: %lu", __func__, (unsigned long)data.length);
}


@end
