//
//  CocoaSocketClient.h
//  SwiftDemo
//
//  Created by oneStep on 2023/10/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//@protocol CocoaSocketClientDelegate <NSObject>
//
//- (void)backClientData:(NSString *)data;
//
//@end

@interface CocoaSocketClient : NSObject

- (void)socketConnect;

- (void)sendMessageData:(NSString *)content;

@property (nonatomic,copy) void (^readClientBackData)(NSString *data);


@end

NS_ASSUME_NONNULL_END
