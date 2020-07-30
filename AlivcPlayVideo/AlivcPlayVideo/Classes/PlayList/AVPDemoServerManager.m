//
//  AVPDemoServerManager.m
//  AliPlayerDemo
//
//  Created by 郦立 on 2019/1/15.
//  Copyright © 2019年 com.alibaba. All rights reserved.
//

#import "AVPDemoServerManager.h"
#import "AVPTool.h"

@interface AVPDemoServerManager()

@end

static AVPDemoServerManager *manager;

@implementation AVPDemoServerManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AVPDemoServerManager alloc]init];
        manager.region = @"cn-shanghai";
    });
    return manager;
}

+ (void)getVideoListArrayWithHudView:(UIView *)view type:(AVPPlaySourceType)sourceType model:(AVPDemoResponseVideoListModel *)model success:(demoRequestSuccess)success failure:(requestFailure)failure {
    if (DEFAULT_SERVER.token) {
        [self getVideoListArrayHasTokenWithHudView:view type:sourceType model:model success:success failure:failure];
    }else {
        [self reloadTokenInView:view success:^(AVPDemoResponseModel *responseObject) {
            [self getVideoListArrayHasTokenWithHudView:view type:sourceType model:model success:success failure:failure];
        } failure:^(NSString *errorMsg) {
            failure(errorMsg);
        }];
    }
}

+ (void)getVideoListArrayHasTokenWithHudView:(UIView *)view type:(AVPPlaySourceType)sourceType model:(AVPDemoResponseVideoListModel *)model success:(demoRequestSuccess)success failure:(requestFailure)failure {
    NSInteger pageNo = 1;
    if (model) { pageNo = model.page + 1; }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:3];
    [dic setObject:[NSString stringWithFormat:@"%ld",(long)pageNo] forKey:@"pageIndex"];
    [dic setObject:[NSString stringWithFormat:@"%ld",(long)pageSize] forKey:@"pageSize"];
    AVPUrlType urlType = AVPUrlTypeGetRecommendVideoList;
    [dic setObject:DEFAULT_SERVER.token forKey:@"token"];
    [self startRequestWithParameters:dic.copy urlType:urlType hudView:view success:^(AVPDemoResponseModel *responseObject) {
        if (success) {
            for (int i = 0; i<responseObject.data.videoList.count; i++) {
                AVPDemoResponseVideoListModel *eveModel = responseObject.data.videoList[i];
                if (model) {
                    eveModel.index = i +1 + model.index;
                }else {
                    eveModel.index = i;
                }
                eveModel.page = pageNo;
            }
            success(responseObject);
        }
    } failure:^(NSString *errorMsg) {
        if (failure) { failure(errorMsg); }
    }];
}

+ (void)reloadTokenInView:(UIView *)view success:(demoRequestSuccess)success failure:(requestFailure)failure {
    [self startRequestWithParameters:nil urlType:AVPUrlTypeRandomUser hudView:view success:^(AVPDemoResponseModel *responseObject) {
        DEFAULT_SERVER.token = responseObject.data.token;
        if (success) { success(responseObject); }
    } failure:^(NSString *errorMsg) {
        if (failure) { failure(errorMsg); }
    }];
}

+ (void)reloadStsTokenInView:(UIView *)view success:(demoRequestSuccess)success failure:(requestFailure)failure {
    [self startRequestWithParameters:nil urlType:AVPUrlTypePlayerVideoSts hudView:view success:^(AVPDemoResponseModel *responseObject) {
        [self setManagerStsWithResponseModel:responseObject];
        if (success) { success(responseObject); }
    } failure:^(NSString *errorMsg) {
        if (failure) { failure(errorMsg); }
    }];
}

+ (void)startRequestWithParameters:(NSDictionary *)parameters urlType:(AVPUrlType)type hudView:(UIView *)view success:(demoRequestSuccess)success failure:(requestFailure)failure {
    if (view) { [AVPTool loadingHudToView:view]; }
    [AlivcPlayVideoRequestManager getWithParameters:parameters urlType:type success:^(AVPDemoResponseModel *responseObject) {
        if (view) { [AVPTool hideLoadingHudForView:view]; }
        if (success) { success(responseObject); }
    } failure:^(NSString *errorMsg) {
        if (view) {
            [AVPTool hideLoadingHudForView:view];
            [AVPTool hudWithText:errorMsg view:view];
        }
        if (failure) { failure(errorMsg); }
    }];
}

+ (void)setManagerStsWithResponseModel:(AVPDemoResponseModel *)model {
    DEFAULT_SERVER.accessKeyId = model.data.accessKeyId;
    DEFAULT_SERVER.accessKeySecret = model.data.accessKeySecret;
    DEFAULT_SERVER.securityToken = model.data.securityToken;
//    NSString *expirationString = [[model.data.expiration stringByReplacingOccurrencesOfString:@"T" withString:@" "] stringByReplacingOccurrencesOfString:@"Z" withString:@""];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
//    NSDate *exdate = [dateFormatter dateFromString:expirationString];
    //东八区时间28800秒，再提前5分钟请求
    DEFAULT_SERVER.expirationTime = [AVPDemoServerManager getExpirTime:model.data.expiration] + 28800 - 300;
}

+(NSTimeInterval)getExpirTime:(NSString*)expiration{
    NSString *expirationString = [[expiration stringByReplacingOccurrencesOfString:@"T" withString:@" "] stringByReplacingOccurrencesOfString:@"Z" withString:@""];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *exdate = [dateFormatter dateFromString:expirationString];
    return [exdate timeIntervalSince1970];
}

@end








