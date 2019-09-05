//
//  NSURLRequest+FY.h
//  FYHttpURLProtocol
//
//  Created by JackJin on 2019/9/5.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSURLRequest (FY)

- (NSUInteger)lineLength;

- (NSUInteger)headersLength;

- (NSUInteger)bodyLenth;

@end

