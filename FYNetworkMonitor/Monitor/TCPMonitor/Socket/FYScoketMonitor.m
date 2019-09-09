//
//  FYScoketMonitor.m
//  FYNetworkMonitor
//
//  Created by JackJin on 2019/9/8.
//  Copyright © 2019 xuehu. All rights reserved.
//

#import "FYScoketMonitor.h"
#import <sys/socket.h>

int (*original_accept)(int, struct sockaddr * __restrict, socklen_t * __restrict);
int (*original_bind)(int fd, const struct sockaddr *addr, socklen_t *length);
int (*original_connect)(int fd, const struct sockaddr *addr, socklen_t *length);

ssize_t (*original_recvmsg)(int fd, struct msghdr *msg, int flags);
ssize_t (*original_sendmsg)(int fd, const struct msghdr *msg, int flags);
ssize_t (*original_sendto)(int fd, const void *buffer, size_t size, int flags, const struct sockaddr *addr, socklen_t length);
ssize_t (*original_recvfrom)(int fd,void *buffer, size_t size,int flags,struct sockaddr *addr, socklen_t *length);

ssize_t (*original_send)(int fd, const void *buffer, size_t size, int d);
ssize_t (*original_recv)(int fd, void *buffer, size_t size, int d);
ssize_t (*original_write)(int fd, const void *buffer, size_t size);
ssize_t (*original_read)(int fd, void *buffer, size_t size);

@implementation FYScoketMonitor

+ (void)load {
    rcd_rebind_symbols((struct rcd_rebinding[11]){
        {
            "accept",
            objc_accept,
            (void *)&original_accept
        },
        {
            "bind",
            objc_bind,
            (void *)&original_bind
        },
        {
            "connect",
            objc_connect,
            (void *)&original_connect
        },
        {
            "recvmsg",
            objc_recvmsg,
            (void *)&original_recvmsg
        },
        {
            "sendmsg",
            objc_sendmsg,
            (void *)&original_sendmsg
        },
        {
            "sendto",
            objc_sendto,
            (void *)&original_sendto
        },
        {
            "recvfrom",
            objc_recvfrom,
            (void *)&original_recvfrom
        },
        {
            "send",
            objc_send,
            (void *)&original_send
        },
        {
            "recv",
            objc_recv,
            (void *)&original_recv
        },
        {
            "write",
            objc_write,
            (void *)&original_write
        },
        {
            "read",
            objc_read,
            (void *)&original_read
        },
    }, 11);
    
}


#pragma mark - Private

static int objc_accept(int fd, struct sockaddr *addr, socklen_t *length) {
    int result = original_accept(fd, addr, length);
    return result;
}

static int objc_bind(int fd, const struct sockaddr *addr, socklen_t *length) {
    int result = original_bind(fd, addr, length);
    return result;
}

static int objc_connect(int fd, const struct sockaddr *addr, socklen_t *length) {
    NSDate *startDate = [NSDate date];
    int result = original_connect(fd, addr, length);
    
    //TODO
    NSLog(@"<method:%s> startDate: %@", __func__, startDate);
    
    return result;
}

ssize_t objc_recvmsg(int fd, struct msghdr *msg, int flags) {
    NSDate *startDate = [NSDate date];
    ssize_t recvSize = original_recvmsg(fd, msg, flags);
    
    //TODO
    NSLog(@"<method:%s> startDate: %@", __func__, startDate);
    
    return recvSize;
}

ssize_t objc_sendmsg(int fd, const struct msghdr *msg, int flags) {
    NSDate *startDate = [NSDate date];
    ssize_t sendSize = original_sendmsg(fd, msg, flags);
    
    //TODO
    NSLog(@"<method:%s> startDate: %@", __func__, startDate);
    
    return sendSize;
}

ssize_t objc_sendto(int fd, const void *buffer, size_t size, int flags, const struct sockaddr *addr, socklen_t length) {
    ssize_t sendtSize = original_sendto(fd, buffer, size, flags, addr, length);
    
    return sendtSize;
}

ssize_t objc_recvfrom(int fd,void *buffer, size_t size,int flags,struct sockaddr *addr, socklen_t *length) {
    ssize_t recvfSize = original_recvfrom(fd, buffer, size, flags, addr, length);
    
    return recvfSize;
}

static ssize_t objc_send(int fd, const void *buffer, size_t size, int d) {
    NSDate *startTime = [NSDate date];
    ssize_t sendSize = original_send(fd, buffer, size, d);
    
    //TODO
    NSLog(@"<method:%s> startTime: %@", __func__, startTime);
    
    return sendSize;
}

static ssize_t objc_recv(int fd, void *buffer, size_t size, int d) {
    NSDate *startTime = [NSDate date];
    ssize_t recvSize = original_recv(fd, buffer, size, d);
    
    //TODO
    NSLog(@"<method:%s> startTime: %@", __func__, startTime);
    
    return recvSize;
}

static ssize_t objc_write(int fd, const void *buffer, size_t size) {
    NSDate *startTime = [NSDate date];
    ssize_t writeSize = original_write(fd, buffer, size);
    
    //TODO
    NSLog(@"<method:%s> startTime: %@", __func__, startTime);
    
    return writeSize;
}

static ssize_t objc_read(int fd, void *buffer, size_t size) {
    NSDate *startTime = [NSDate date];
    ssize_t readSize = original_read(fd, buffer, size);
    
    //TODO
    NSLog(@"<method:%s> startTime: %@", __func__, startTime);
    
    return readSize;
}

@end
