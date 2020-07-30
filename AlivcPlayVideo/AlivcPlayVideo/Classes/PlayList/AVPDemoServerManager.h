//
//  AVPDemoServerManager.h
//  AliPlayerDemo
//
//  Created by 郦立 on 2019/1/15.
//  Copyright © 2019年 com.alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlivcPlayVideoRequestManager.h"

#define DEFAULT_SERVER    [AVPDemoServerManager shareManager]

static NSInteger const pageSize = 12;

typedef NS_ENUM(NSInteger, AVPPlaySourceType) {
    AVPPlaySourceTypeVID,
    AVPPlaySourceTypeURL
};

@interface AVPDemoServerManager : NSObject

@property (nonatomic,strong)NSString *accessKeyId;
@property (nonatomic,strong)NSString *accessKeySecret;
@property (nonatomic,strong)NSString *securityToken;
@property (nonatomic,assign)NSTimeInterval expirationTime;
@property (nonatomic,strong)NSString *region;
//user相关
@property (nonatomic,strong)NSString *token;

+ (instancetype)shareManager;

/**
 获取播放列表

 @param view hud显示的view
 @param sourceType 数据类型
 @param model model
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getVideoListArrayWithHudView:(UIView *)view type:(AVPPlaySourceType)sourceType model:(AVPDemoResponseVideoListModel *)model success:(demoRequestSuccess)success failure:(requestFailure)failure;

/**
 刷新token
 
 @param view hud显示视图
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)reloadTokenInView:(UIView *)view success:(demoRequestSuccess)success failure:(requestFailure)failure;

/**
 刷新stsToken

 @param view hud显示视图
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)reloadStsTokenInView:(UIView *)view success:(demoRequestSuccess)success failure:(requestFailure)failure;

+(NSTimeInterval)getExpirTime:(NSString*)expiration;

@end





