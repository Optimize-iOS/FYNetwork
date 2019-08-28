//
//  PINRemoteImageMemoryContainer.h
//  Pods
//
//  Created by Garrett Moon on 3/17/16.
//
//

#import <Foundation/Foundation.h>

#import "PINRemoteImageMacros.h"
#import "PINRemoteLock.h"

@class PINImage;

//图片资源 
@interface PINRemoteImageMemoryContainer : NSObject

@property (nonatomic, strong) PINImage *image;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) PINRemoteLock *lock;

@end
