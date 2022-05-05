//
//  edge_ios_oc.h
//  n2n
//
//  Created by samuel.song.bc@gmail.com on 2021/5/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NetDataType) {
    NetDataTun,
    NetDataUdp
};

@interface EdgeConfig : NSObject //OmniEdgeConfig
@property (nonatomic, copy) NSString *superNodeAddr;
@property (nonatomic, assign) NSUInteger superNodePort;
@property (nonatomic, copy) NSString *networkName;
@property (nonatomic, copy) NSString *encryptionKey;
@property (nonatomic, copy) NSString *ipAddress;
@end

@interface EdgeEngine : NSObject

- (instancetype)initWithTunnelProvider:(id)provider;

- (BOOL)start:(EdgeConfig *)config;
- (void)onData:(NSData *)data withType:(NetDataType)type ip:(NSString *)ip port:(NSInteger)port;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
