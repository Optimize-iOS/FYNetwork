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

//header of request
@property (nonatomic, strong) NSArray *requestHeaders;

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

