//
//  NSURLRequest+FY.m
//  FYHttpURLProtocol
//
//  Created by JackJin on 2019/9/5.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "NSURLRequest+FY.h"

@implementation NSURLRequest (FY)

- (NSUInteger)lineLength {
    NSString *jointLine = [NSString stringWithFormat:@"%@ %@ %@\n", self.HTTPMethod, self.URL.path, @"HTTP/1.1"];
    return [[jointLine dataUsingEncoding:NSUTF8StringEncoding] length];
}

- (NSUInteger)headersLength {
    __block NSString *headStr = @"";
    
    NSDictionary *headerFields = self.allHTTPHeaderFields;
    NSDictionary *cookieHeader = [self _getCookies];
    
    if (cookieHeader.count) {
        NSMutableDictionary *mutHeaderFieldWithCookie = [NSMutableDictionary dictionaryWithDictionary:cookieHeader];
        [mutHeaderFieldWithCookie addEntriesFromDictionary:headerFields];
        
        headerFields = [mutHeaderFieldWithCookie copy];
    }
    
    [headerFields enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        headStr = [headStr stringByAppendingString:key];
        headStr = [headStr stringByAppendingString:@":"];
        
        if (obj) {
            headStr = [headStr stringByAppendingString:obj];
        }
        
        headStr = [headStr stringByAppendingString:@"\n"];
    }];
    
    return [[headStr dataUsingEncoding:NSUTF8StringEncoding] length];
}

- (NSUInteger)bodyLenth {
    NSDictionary *headFields = self.allHTTPHeaderFields;
    NSUInteger resLength = [self.HTTPBody length];
    
    if ([headFields objectForKey:@"Content-Encoding"]) {
        NSData *bodyData;
        
        if (resLength == 0 ||  self.HTTPBody == nil) {
            uint8_t bytes[1024] = {0};
            NSInputStream *stream = self.HTTPBodyStream;
            NSMutableData *streamData = [NSMutableData data];
            [stream open];
            
            while ([stream hasBytesAvailable]) {
                NSInteger len = [stream read:bytes maxLength:1024];
                if (len > 0 && stream.streamError == nil) {
                    [streamData appendBytes:(void *)bytes length:len];
                }
            }
            
            bodyData = [streamData copy];
            [stream close];
        }else {
            bodyData = self.HTTPBody;
        }
        
        return [bodyData length];
    }
    
    return 0;
}


#pragma mark - Private

- (NSDictionary *)_getCookies {
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray<NSHTTPCookie *> *cookies = [cookieStorage cookiesForURL:self.URL];
    
    if (cookies.count) {
        return [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    }
    
    return nil;
}


@end
