//
//  FYNetworkMonitorBaseDataModel.h
//  FYHttpURLProtocol
//
//  Created by JackJin on 2019/9/4.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FYNetworkMonitorBaseDataModel : NSObject

//url of request
@property (nonatomic, copy) NSString *requestUrl;

@property (nonatomic, assign) NSUInteger requestLineLength;

@property (nonatomic, assign) UInt64 requestHeadersLength;

@property (nonatomic, assign) UInt64 requestBodyLength;

//header of request
@property (nonatomic, strong) NSArray *requestHeaders;

@property (nonatomic, assign) NSUInteger responseStatusLineLength;

@property (nonatomic, assign) UInt64 responseHeadersLength;

@property (nonatomic, assign) UInt64 responseBodyLength;

//header of response
@property (nonatomic, strong) NSArray *responseHeaders;

//paramters in request
@property (nonatomic, copy) NSString *requestParamters;

//method in header in request
@property (nonatomic, copy) NSString *httpMethod;

//version of http
@property (nonatomic, copy) NSString *httpProtocol;

//
@property (nonatomic, assign) BOOL useProxy;

//ip after dns analysis
@property (nonatomic, copy) NSString *ip;

@end

