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
    
    
    [FYURLProtocol start];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://xiaozhuanlan.com/topic/6395124870"]];
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
