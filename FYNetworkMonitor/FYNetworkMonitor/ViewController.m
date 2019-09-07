//
//  ViewController.m
//  FYNetworkMonitor
//
//  Created by JackJin on 2019/9/6.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "ViewController.h"
#import "fishhook.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"12345");

    struct rcd_rebinding nslogBind;

    //
    nslogBind.name = "NSLog";

    nslogBind.replacement = myMothod;

    nslogBind.replaced = (void *)&old_nslog;

    struct rcd_rebinding rebs[] = {nslogBind};

    rcd_rebind_symbols(rebs, 1);
    //
}

static void (*old_nslog)(NSString *format, ...);

void myMothod(NSString *format, ...) {
    old_nslog(@"fishhook 勾住了。。。");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"点击屏幕");
}

@end
