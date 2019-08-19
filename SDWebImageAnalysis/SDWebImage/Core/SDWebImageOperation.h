/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>

/// A protocol represents cancelable operation.
//操作的 Operation protocol 对应的协议
@protocol SDWebImageOperation <NSObject>

- (void)cancel;

@end

/// NSOperation conform to `SDWebImageOperation`.
// 对 NSOperaion 来额外添加 cancel 取消操作 
@interface NSOperation (SDWebImageOperation) <SDWebImageOperation>

@end
