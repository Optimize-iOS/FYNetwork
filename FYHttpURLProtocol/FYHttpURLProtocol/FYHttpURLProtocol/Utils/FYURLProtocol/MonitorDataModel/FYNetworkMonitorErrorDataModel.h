//
//  FYNetworkMonitorErrorDataModel.h
//  FYHttpURLProtocol
//
//  Created by JackJin on 2019/9/4.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "FYNetworkMonitorBaseDataModel.h"


@interface FYNetworkMonitorErrorDataModel : FYNetworkMonitorBaseDataModel

//code of error
@property (nonatomic, assign) NSInteger errorCode;

//count of error
@property (nonatomic, assign) NSUInteger errorCount;

//name of exception
@property (nonatomic, copy) NSString *exceptionName;

//detail of exception
@property (nonatomic, copy) NSString *exceptionDetail;

//stack of exception
@property (nonatomic, copy) NSString *stackTrace;

@end

