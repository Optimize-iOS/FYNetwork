//
//  FYURLProtocol.h
//  FYHttpURLProtocol
//
//  Created by JackJin on 2019/8/30.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYURLProtocol : NSURLProtocol


+ (void)start;

+ (void)end;

+ (void)registerWKWebView;

+ (void)unregisterWKWebView;


@end


