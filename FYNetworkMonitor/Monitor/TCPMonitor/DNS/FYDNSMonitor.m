//
//  FYDNSMonitor.m
//  FYNetworkMonitor
//
//  Created by JackJin on 2019/9/7.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "FYDNSMonitor.h"
#import <netdb.h>

int (*original_getaddrinfo)(const char *host, const char *port, const struct addrinfo *hints, struct addrinfo ** res);

struct hostent* (*original_gethostbyname2)(const char *name);

int32_t (*original_dns_async_start)(int, ...);

int (*original_res_9_query)(const char *dname, int class, int type, unsigned char *answer, int anslen);

int (*original_createDNSLookup)(void const *);

int32_t (*original_getaddrinfo_async_start)(mach_port_t *p, ...);


//getaddrinfo_async_start iOS 10.3

@implementation FYDNSMonitor

+ (void)load {
    rcd_rebind_symbols((struct rcd_rebinding[6]) {
        {
            "getaddrinfo",
            objc_getaddrinfo,
            (void *)&original_getaddrinfo
        },
        {
            "gethostbyname2",
            objc_gethostbyname2,
            (void *)&original_gethostbyname2
        },
        {
            "dns_async_start",
            objc_dns_async_start,
            (void *)&original_dns_async_start
        },
        {
            "res_9_query",
            objc_res_9_query,
            (void *)&original_res_9_query
        },
        {
            "_startTLS",
            objc_createDNSLookup,
            (void *)&original_createDNSLookup
        },
        {
            "getaddrinfo_async_start",
            objc_getaddrinfo_async_start,
            (void *)&original_getaddrinfo_async_start
        },
    }, 6);
}


#pragma mark - Private

bool isVaildIpAdress(const char *ip) {//
    return 1;
}

int objc_getaddrinfo(const char *host, const char *port, const struct addrinfo *hints, struct addrinfo ** res) {
    struct addrinfo hint;
    if (!isVaildIpAdress(host)) {
        memset(&hint, 0, sizeof(hint));
        
        hint.ai_family = hints->ai_family;
        hint.ai_socktype = hints->ai_socktype;
        hint.ai_protocol = hints->ai_protocol;
    }else {
        hint = *hints;
    }
    
    NSDate *startDate = [NSDate date];
    bool result = original_getaddrinfo(host, port, &hint, res);
    
    //TODO
    NSLog(@"<method:%s> startDate: %@", __func__, startDate);
    
    return result;
}

struct hostent* objc_gethostbyname2(const char *name) {
    struct hostent* result = original_gethostbyname2(name);
    
    return result;
}

int32_t objc_dns_async_start(int a, ...) {
    
    return 0;
}

int objc_res_9_query(const char *dname, int class, int type, unsigned char *answer, int anslen) {
    int query = original_res_9_query(dname, class, type, answer, anslen);
    
    return query;
}

int objc_createDNSLookup(void const *value) {
    
    return original_createDNSLookup(value);
}

int32_t objc_getaddrinfo_async_start(mach_port_t *p, ...) {
    //iOS 10.3 NSURLConnection/UIWebView call
    int32_t result = original_dns_async_start(p);
    
    return result;
}

@end
