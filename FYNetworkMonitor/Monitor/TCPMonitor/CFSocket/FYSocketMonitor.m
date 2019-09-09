//
//  FYSocketMonitor.m
//  FYNetworkMonitor
//
//  Created by JackJin on 2019/9/7.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "FYSocketMonitor.h"
#import <CoreFoundation/CFSocket.h>

CFSocketError (*original_CFSocketConnectToAddress)(CFSocketRef s, CFDataRef address, CFTimeInterval timeout);

CFSocketError (*original_CFSocketSendData)(CFSocketRef s, CFDataRef address, CFDataRef data, CFTimeInterval timeout);

@implementation FYCFSocketMonitor

+ (void)load {
    rcd_rebind_symbols((struct rcd_rebinding[2]) {
        {
            "CFSocketConnectToAddress",
            objc_CFSocketConnectToAddress,
            (void *)&original_CFSocketConnectToAddress
        },
        {
            "CFSocketSendData",
            objc_CFSocketSendData,
            (void *)&original_CFSocketSendData
        }
    }, 2);
}


#pragma mark - Private

CFSocketError objc_CFSocketConnectToAddress(CFSocketRef s, CFDataRef address, CFTimeInterval timeout) {
    CFSocketError error = original_CFSocketConnectToAddress(s, address, timeout);
    abort();
    
    return error;
}

CFSocketError objc_CFSocketSendData(CFSocketRef s, CFDataRef address, CFDataRef data, CFTimeInterval timeout) {
    CFSocketError error = original_CFSocketSendData(s, address, data, timeout);
    
    abort();
    
    return error;
}

@end
