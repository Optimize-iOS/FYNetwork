//
//  FYDelegateProxy.h
//  FYNetworkMonitor
//
//  Created by JackJin on 2019/9/6.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYDelegateProxy : NSProxy

@property (nonatomic, weak) id target;

- (instancetype)initWithTarget:(id)target;


@end

