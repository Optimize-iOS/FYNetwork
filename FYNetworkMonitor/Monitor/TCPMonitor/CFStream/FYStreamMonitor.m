//
//  FYStreamMonitor.m
//  FYNetworkMonitor
//
//  Created by JackJin on 2019/9/7.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "FYStreamMonitor.h"
#import <CFNetwork/CFNetwork.h>

CFIndex (*original_CFReadStreamRead)(CFReadStreamRef stream, UInt8 *buffer, CFIndex bufferLength);

CFIndex (*original_CFWriteStreamWrite)(CFWriteStreamRef stream, const UInt8 *buffer, CFIndex bufferLength);

Boolean (*original_CFReadStreamOpen)(CFReadStreamRef stream);

Boolean (*original_CFWriteStreamOpen)(CFWriteStreamRef stream);

Boolean (*original_CFReadStreamSetClient)(CFReadStreamRef stream, CFOptionFlags streamEvents, CFReadStreamClientCallBack clientCB, CFStreamClientContext *clientContext);

Boolean (*original_CFWriteStreamSetClient)(CFWriteStreamRef stream, CFOptionFlags streamEvents, CFWriteStreamClientCallBack clientCB, CFStreamClientContext *clientContext);

@implementation FYStreamMonitor

+ (void)load {
    rcd_rebind_symbols((struct rcd_rebinding[6]) {
        {
            "CFReadStreamRead",
            objc_CFReadStreamRead,
            (void *)&original_CFReadStreamRead
        },
        {
            "CFWriteStreamWrite",
            objc_CFWriteStreamWrite,
            (void *)&original_CFWriteStreamWrite
        },
        {
            "CFReadStreamOpen",
            objc_CFReadStreamOpen,
            (void *)&original_CFReadStreamOpen
        },
        {
            "CFWriteStreamOpen",
            objc_CFWriteStreamOpen,
            (void *)&original_CFWriteStreamOpen
        },
        {
            "CFReadStreamSetClient",
            objc_CFReadStreamSetClient,
            (void *)&original_CFReadStreamSetClient
        },
        {
            "CFWriteStreamSetClient",
            objc_CFWriteStreamSetClient,
            (void *)&original_CFWriteStreamSetClient
        }
    }, 6);
}

#pragma mark - Private

static CFIndex objc_CFReadStreamRead(CFReadStreamRef stream, UInt8 *buffer, CFIndex bufferLength) {
    NSDate *startDate = [NSDate date];
    CFIndex index = original_CFReadStreamRead(stream, buffer, bufferLength);
    
    //TODO
    NSLog(@"<method:%s> startDate: %@", __func__, startDate);
    
    return index;
}

static CFIndex objc_CFWriteStreamWrite(CFWriteStreamRef stream, const UInt8 *buffer, CFIndex bufferLength) {
    NSDate *startDate = [NSDate date];
    CFIndex index = original_CFWriteStreamWrite(stream, buffer, bufferLength);
    
    //TODO
    NSLog(@"<method:%s> startDate: %@", __func__, startDate);
    
    return index;
}

static Boolean objc_CFReadStreamOpen(CFReadStreamRef stream) {
    NSDate *startDate = [NSDate date];
    BOOL open = original_CFReadStreamOpen(stream);
    
    //TODO
    NSLog(@"<method:%s> startDate: %@", __func__, startDate);
    
    return open;
}

static Boolean objc_CFWriteStreamOpen(CFWriteStreamRef stream) {
    NSDate *startDate = [NSDate date];
    BOOL open = original_CFWriteStreamOpen(stream);
    
    //TODO
    NSLog(@"<method:%s> startDate: %@", __func__, startDate);
    
    return open;
}

Boolean objc_CFReadStreamSetClient(CFReadStreamRef stream, CFOptionFlags streamEvents, CFReadStreamClientCallBack clientCB, CFStreamClientContext *clientContext) {
    BOOL clientEnable = original_CFReadStreamSetClient(stream, streamEvents, clientCB, clientContext);
    
    return clientEnable;
}

Boolean objc_CFWriteStreamSetClient(CFWriteStreamRef stream, CFOptionFlags streamEvents, CFWriteStreamClientCallBack clientCB, CFStreamClientContext *clientContext) {
    BOOL clientEnable = original_CFWriteStreamSetClient(stream, streamEvents, clientCB, clientContext);
    
    return clientEnable;
}

@end
