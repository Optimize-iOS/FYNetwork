//
//  NSURLResponse+FY.m
//  FYHttpURLProtocol
//
//  Created by JackJin on 2019/9/5.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "NSURLResponse+FY.h"
#import <dlfcn.h>

typedef CFHTTPMessageRef (*FyURLResponseGetHttpResponse)(CFURLRef response);

@implementation NSURLResponse (FY)

- (NSUInteger)statusLineLength {
    if ([self isKindOfClass:NSHTTPURLResponse.class]) {
        NSData *statusData = [[self _statusLine] dataUsingEncoding:NSUTF8StringEncoding];
        
        return statusData.length;
    }
    
    return 0;
}

- (NSUInteger)headersLength {
    if ([self isKindOfClass:NSHTTPURLResponse.class]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)self;
        NSDictionary *headerFields = httpResponse.allHeaderFields;
        
        __block NSString *headStr = @"";
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
    
    return 0;
}

- (NSUInteger)boyLengthWithReceiveData:(NSData *)data {
    if ([self isKindOfClass:NSHTTPURLResponse.class]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)self;
        if ([[httpResponse.allHeaderFields objectForKey:@"Content-Encoding"] isEqualToString:@"gzip"]) {
            
            //data 变为 zip 数据
        }
        
        return data.length;
    }
    
    return 0;
}

#pragma mark - Private

- (NSString *)_statusLine {
    NSString *statusLine = @"";
    
    NSString *funName = @"CFURLResponseGetHTTPResponse";
    FyURLResponseGetHttpResponse originalGetHttpResponse = dlsym(RTLD_DEFAULT, [funName UTF8String]);
    
    SEL responseSel = NSSelectorFromString(@"_CFURLResponse");
    
    if ([self respondsToSelector:responseSel] && originalGetHttpResponse != NULL) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        CFTypeRef responseRef = CFBridgingRetain([self performSelector:responseSel]);
#pragma clang diagnostic pop
        if (responseRef != NULL) {
            CFHTTPMessageRef messageRef = originalGetHttpResponse(responseRef);
            statusLine = (__bridge_transfer NSString *)CFHTTPMessageCopyResponseStatusLine(messageRef);
            
            CFRelease(messageRef);
        }
        
        CFRelease(responseRef);
    }
    
    return statusLine;
}

@end
