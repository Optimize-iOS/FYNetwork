//
//  FYNetworkMonitorDataModel.h
//  FYHttpURLProtocol
//
//  Created by JackJin on 2019/9/4.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "FYNetworkMonitorBaseDataModel.h"


@interface FYNetworkMonitorDataModel : FYNetworkMonitorBaseDataModel

//date of client start request
@property (nonatomic, assign) UInt64 requestDate;

//time from start request to start dns analyse
@property (nonatomic, assign) int waitDNSTime;

//cost time that dns analyse
@property (nonatomic, assign) int dnsLookupTime;

//cost time that three times when tcp establish connection
@property (nonatomic, assign) int tcpTime;

//cost time that SSL
@property (nonatomic, assign) int sslTime;

//cost time that form request to reponse
@property (nonatomic, assign) int requestTime;

//reveiver code of http
@property (nonatomic, assign) NSInteger httpCode;

//bytes of send
@property (nonatomic, assign) UInt64 sendBytes;

//sbytes of receiver 
@property (nonatomic, assign) UInt64 receiveBytes;

@end

