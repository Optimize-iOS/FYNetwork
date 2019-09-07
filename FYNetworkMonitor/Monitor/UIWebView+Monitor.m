//
//  UIWebView+Monitor.m
//  FYNetworkMonitor
//
//  Created by JackJin on 2019/9/7.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "UIWebView+Monitor.h"
#import <objc/runtime.h>
#import "FYDelegateProxy.h"

@interface _FYWebViewProxy : FYDelegateProxy

@end

@implementation _FYWebViewProxy

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([NSStringFromSelector(aSelector) isEqualToString:@""]) {
        return YES;
    }else {
        return [super respondsToSelector:aSelector];
    }
    
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [super forwardInvocation:invocation];
    
    if ([NSStringFromSelector(invocation.selector) isEqualToString:@"webViewDidFinishLoad:"]) {
        UIWebView *webView;
        [invocation setArgument:&webView atIndex:2];
        
        if (@available(iOS 10.0, *)) {
            NSString *timStr = [webView stringByEvaluatingJavaScriptFromString:@"JSON.stringify(window.performance.timing.toJSON())"];
            
            //TODO
            NSLog(@"<class:%@ method:%s> timing str: %@", NSStringFromClass(self.class), __func__, timStr);
        }else {
            __strong NSString *funStr = @"function flatten(obj) {"
            "var ret = {}; "
            "for (var i in obj) { "
            "ret[i] = obj[i];"
            "}"
            "return ret;}";
            [webView stringByEvaluatingJavaScriptFromString:funStr];
            NSString *timStr = [webView stringByEvaluatingJavaScriptFromString:@"JSON.stringify(flatten(window.performance.timing))"];
            
            //TODO
            NSLog(@"<class:%@ method:%s> timing str: %@", NSStringFromClass(self.class), __func__, timStr);
        }
        
    }
}

@end

@implementation UIWebView (Monitor)


#pragma mark - Override

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        Method originalMethod = class_getClassMethod(class, @selector(setDelegate:));
        Method swizzleMethod = class_getClassMethod(class, @selector(swizzleSetDelegate:));
        
        method_exchangeImplementations(originalMethod, swizzleMethod);
    });
}


#pragma mark - Private

- (void)swizzleSetDelegate:(id<UIWebViewDelegate>)delegate {
    if (delegate) {
        _FYWebViewProxy *proxy = [[_FYWebViewProxy alloc] initWithTarget:delegate];
        objc_setAssociatedObject(delegate, @"_FYWebViewProxy", proxy, OBJC_ASSOCIATION_RETAIN);
        
        [self swizzleSetDelegate:(id<UIWebViewDelegate>)proxy];
        
    }else {
        [self swizzleSetDelegate:delegate];
    }
}

@end



@interface _FYWKWebView : FYDelegateProxy

@end

@implementation _FYWKWebView

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([NSStringFromSelector(aSelector) isEqualToString:@"webView:didFinishNavigation:"]) {
        return YES;
    }else {
        return [super respondsToSelector:aSelector];
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [super forwardInvocation:invocation];
    
    if ([NSStringFromSelector(invocation.selector) isEqualToString:@"webView:didFinishNavigation:"]) {
        WKWebView *webView;
        [invocation setArgument:&webView atIndex:2];
        
        if (@available(iOS 10.0, *)) {
            [webView evaluateJavaScript:@"JSON.stringify(window.performance.timing.toJSON())" completionHandler:^(id _Nullable timStr, NSError * _Nullable error) {
                
                //TODO
                
            }];
        }else {
            NSString *funcStr = @"function flatten(obj) {"
            "var ret = {}; "
            "for (var i in obj) { "
            "ret[i] = obj[i];"
            "}"
            "return ret;}";
            [webView evaluateJavaScript:funcStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                if (!error) {
                    [webView evaluateJavaScript:@"JSON.stringify(flatten(window.performance.timing))" completionHandler:^(id _Nullable timStr, NSError * _Nullable error) {
                        
                        if (!error) {
                            //TODO
                            
                        }
                    }];
                }
            }];
        }
    }
}

@end

@implementation WKWebView (Monitor)

#pragma mark - Override

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        Method originalMethod = class_getClassMethod(class, @selector(setNavigationDelegate:));
        Method swizzleMethod = class_getClassMethod(class, @selector(swizzleSetNavigationDelegate:));
        
        method_exchangeImplementations(originalMethod, swizzleMethod);
    });
}


#pragma mark - Private

- (void)swizzleSetNavigationDelegate:(id<WKNavigationDelegate>)navigationDelegate {
    if (navigationDelegate) {
        _FYWebViewProxy *proxy = [[_FYWebViewProxy alloc] initWithTarget:navigationDelegate];
        objc_setAssociatedObject(navigationDelegate, @"_FYWKWebView", proxy, OBJC_ASSOCIATION_RETAIN);
        
        [self swizzleSetNavigationDelegate:(id<WKNavigationDelegate>)proxy];
    }else {
        [self swizzleSetNavigationDelegate:navigationDelegate];
    }
}

@end
