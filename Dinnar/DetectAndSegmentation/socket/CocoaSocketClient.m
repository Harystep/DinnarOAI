//
//  CocoaSocketClient.m
//  SwiftDemo
//
//  Created by oneStep on 2023/10/16.
//

#import "CocoaSocketClient.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@interface CocoaSocketClient ()<GCDAsyncSocketDelegate>

@property (nonatomic,strong) GCDAsyncSocket *clientSocket;

@property (nonatomic,assign) BOOL connected;

@property (nonatomic, strong) NSTimer *connectTimer;

@end

static GCDAsyncSocket *_socketClient = nil;

@implementation CocoaSocketClient

- (void)socketConnect {
    NSLog(@"start connecting");
    self.clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error;
    [self.clientSocket connectToHost:@"192.168.110.112" onPort:60000 error:&error];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
//    NSLog(@"连接主机对应端口%@", sock);
//    [self showMessageWithStr:@"链接成功"];
//    [self showMessageWithStr:[NSString stringWithFormat:@"服务器IP: %@-------端口: %d", host,port]];
    NSLog(@"connect----suc");
    // 连接成功开启定时器
    [self addTimer];
    // 连接后,可读取服务端的数据
    [self.clientSocket readDataWithTimeout:- 1 tag:0];
    self.connected = YES;
}

// 添加定时器
- (void)addTimer
{
    // 长连接定时器
   self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];
    // 把定时器添加到当前运行循环,并且调为通用模式
   [[NSRunLoop currentRunLoop] addTimer:self.connectTimer forMode:NSRunLoopCommonModes];
}

// 心跳连接
- (void)longConnectToSocket
{
   // 发送固定格式的数据,指令@"longConnect"
   float version = [[UIDevice currentDevice] systemVersion].floatValue;
   NSString *longConnect = [NSString stringWithFormat:@"123%f",version];

   NSData  *data = [longConnect dataUsingEncoding:NSUTF8StringEncoding];

   [self.clientSocket writeData:data withTimeout:- 1 tag:0];
}

/**
 客户端socket断开

 @param sock 客户端socket
 @param err 错误描述
 */
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
//    [self showMessageWithStr:@"断开连接"];
    NSLog(@"========>断开连接");    
    self.clientSocket.delegate = nil;
    self.clientSocket = nil;
    self.connected = NO;
    [self.connectTimer invalidate];
}

/**
 读取数据

 @param sock 客户端socket
 @param data 读取到的数据
 @param tag 本次读取的标记
 */
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    // 读取到服务端数据值后,能再次读取
    [self.clientSocket readDataWithTimeout:- 1 tag:0];
   
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kReadClientDataKey" object:text];
}

// 发送数据
- (void)sendMessageData:(NSString *)content
{
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    // withTimeout -1 : 无穷大,一直等
    // tag : 消息标记
    NSLog(@"data--->%@", content);
    [self.clientSocket writeData:data withTimeout:- 1 tag:0];
}

@end
    
