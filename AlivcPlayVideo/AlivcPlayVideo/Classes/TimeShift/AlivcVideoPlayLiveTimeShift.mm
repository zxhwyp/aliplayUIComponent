//
//  AlivcVideoPlayLiveTimeShift.mm
//  AliPlayerSDK
//
//  Created by shiping.csp on 2018/11/16.
//  Copyright © 2018年 com.alibaba.AliyunPlayer. All rights reserved.
//

#import "AlivcVideoPlayLiveTimeShift.h"

@interface AlivcVideoPlayLiveTimeShift ()
{
    NSString *mLivePlayingUrl;
    NSString * mLiveShiftUrl;
    int mCountTime;
    BOOL mNeedPause;
    dispatch_source_t mTimer;
}
@property(nonatomic,assign) AVPStatus mCurrentStatus;
@end

@implementation AlivcVideoPlayLiveTimeShift

-(instancetype)init
{
    self = [super init];
    if (self) {
        mTimer = nil;
        mNeedPause = NO;
        mLiveShiftUrl = nil;
        mLivePlayingUrl = nil;
        mCountTime = 0;
    }
    return self;
}

-(void)stop
{
    [super stop];
    
    if (mTimer && mLivePlayingUrl) {
        dispatch_suspend(mTimer);
        mNeedPause = YES;
        mCountTime = 0;
    }
}

-(void)start
{
    [super start];
    
    if (mTimer && mLivePlayingUrl && mNeedPause) {
        dispatch_resume(mTimer);
        mNeedPause = NO;
    }
}

- (void)prepareWithLiveTimeUrl:(NSString*)liveTimeUrl{
    
    if (!liveTimeUrl) {
        return;
    }
    
    AVPUrlSource* source = [[AVPUrlSource alloc] urlWithString:liveTimeUrl];
    [self setUrlSource:source];
    [self prepare];
    
    mLivePlayingUrl = liveTimeUrl;
    
    if(mTimer && mNeedPause){
        dispatch_resume(mTimer);
        mNeedPause = NO;
    }
}

- (BOOL)baseRequestGetWithStatus:(NSString *)requestUrl completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler{
    
    NSURL *url = [NSURL URLWithString:requestUrl];
    if (!url) {
        return NO;
    }
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 10;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:completionHandler];
    [task resume];
    [session finishTasksAndInvalidate];
    return YES;
}

-(void)sendLiveShiftError:(AVPErrorCode)errorCode errorMsg:(NSString*)errorMsg requestId:(NSString*)requestId
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onError:errorModel:)]){
        dispatch_async(dispatch_get_main_queue(), ^{
            AVPErrorModel* model = [[AVPErrorModel alloc] init];
            model.code = errorCode;
            model.message = errorMsg;
            model.requestId = requestId;
            [self.delegate onError:self errorModel:model];
        });
    }
}

-(void)sendLiveShiftError:(AVPErrorModel*)model
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onError:errorModel:)]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate onError:self errorModel:model];
        });
    }
}

- (void)requestDataTimeLineWithLiveTimeShiftUrl:(NSString *)liveTimeShiftUrl completionHandler:(void (^)(id, AVPErrorModel *))completionHandler{
    
    [self baseRequestGetWithStatus:liveTimeShiftUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        @try{
            if (error && (data == nil||data.length <=0 )) {
                AVPErrorModel* model = [[AVPErrorModel alloc] init];
                model.code = ERROR_SERVER_LIVESHIFT_REQUEST_ERROR;
                model.message = @"request liveshift server error";
                model.requestId = nil;
                completionHandler(nil,model);
                return ;
            }
            
            NSError *dictError;
            NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&dictError];
            if (dictError) {
                AVPErrorModel* model = [[AVPErrorModel alloc] init];
                model.code = ERROR_SERVER_LIVESHIFT_REQUEST_ERROR;
                model.message = @"request liveshift server data error, json parser error";
                model.requestId = nil;
                completionHandler(nil,model);
                return ;
            }
            
            int retCode = [[resultJSON objectForKey:@"retCode"] intValue];
            switch (retCode) {
                case 0:
                {
                    completionHandler(resultJSON,nil);
                    return;
                }break;
                
                case 4001:
                {
                    AVPErrorModel* model = [[AVPErrorModel alloc] init];
                    model.code = ERROR_SERVER_LIVESHIFT_REQUEST_ERROR;
                    model.message = @"request liveshift server param error";
                    model.requestId = nil;
                    completionHandler(nil,model);
                }
                break;
                
                case 4002:
                {
                    AVPErrorModel* model = [[AVPErrorModel alloc] init];
                    model.code = ERROR_SERVER_LIVESHIFT_REQUEST_ERROR;
                    model.message = @"request liveshift server error,stream num is not 0";
                    model.requestId = nil;
                    completionHandler(nil,model);
                }
                break;
                
                case 4003:
                {
                    AVPErrorModel* model = [[AVPErrorModel alloc] init];
                    model.code = ERROR_SERVER_LIVESHIFT_REQUEST_ERROR;
                    model.message = @"request liveshift server error,data not found";
                    model.requestId = nil;
                    completionHandler(nil,model);
                }
                break;
                
                case 5001:
                {
                    AVPErrorModel* model = [[AVPErrorModel alloc] init];
                    model.code = ERROR_SERVER_LIVESHIFT_REQUEST_ERROR;
                    model.message = @"request liveshift server error,internal db error";
                    model.requestId = nil;
                    completionHandler(nil,model);
                }
                break;
                    
                default:
                    break;
            }
        }@catch (NSException *exception) {
            NSString *msg = exception.reason;
            AVPErrorModel* model = [[AVPErrorModel alloc] init];
            model.code = ERROR_SERVER_LIVESHIFT_UNKNOWN;
            model.message = msg;
            model.requestId = nil;
            completionHandler(nil,model);
        } @finally {
            
        }
    }];
}


- (void)setLiveTimeShiftUrl:(NSString*)liveTimeShiftUrl{
    
    if (!liveTimeShiftUrl) {
        return;
    }
    
    liveTimeShiftUrl= [liveTimeShiftUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    mLiveShiftUrl = liveTimeShiftUrl;

    __weak typeof(self)wSelf = self;
    [self requestDataTimeLineWithLiveTimeShiftUrl:liveTimeShiftUrl completionHandler:^(id obj, AVPErrorModel *error) {
        if (error) {
            [self sendLiveShiftError:error];
            return;
        }

        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)obj;
            AVPTimeShiftModel *model = [[AVPTimeShiftModel alloc] init];
            @try{
                model.startTime =  [[dict[@"content"][@"timeline"] firstObject][@"start"] doubleValue];
                model.endTime = [[dict[@"content"][@"timeline"] lastObject][@"end"] doubleValue];
                model.currentTime = [dict[@"content"][@"current"] doubleValue];
                dispatch_async(dispatch_get_main_queue(), ^{
                    wSelf.currentPlayTime = model.currentTime;
                    wSelf.liveTime = model.currentTime;
                    self.timeShiftModel = model;
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    self->mTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
                    dispatch_source_set_timer(self->mTimer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0); //每秒执行
                    dispatch_source_set_event_handler(self->mTimer, ^{
                        [self liveTime:nil];
                    });
                    dispatch_resume(self->mTimer);
                });
            }@catch (NSException *exception) {

            }
        }
    }];
}

- (void)liveTime:(NSTimer *)timer {
    
    if (mCountTime%60==0) {
        __weak typeof(self)wSelf = self;
        [self requestDataTimeLineWithLiveTimeShiftUrl:mLiveShiftUrl completionHandler:^(id obj, AVPErrorModel *error) {
            if (error) {
                [self sendLiveShiftError:error];
                return;
            }
            
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *dict = (NSDictionary *)obj;
                AVPTimeShiftModel *model = [[AVPTimeShiftModel alloc] init];
                @try{
                    model.startTime =  [[dict[@"content"][@"timeline"] firstObject][@"start"] doubleValue];
                    model.endTime = [[dict[@"content"][@"timeline"] lastObject][@"end"] doubleValue];
                    model.currentTime = [dict[@"content"][@"current"] doubleValue];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        wSelf.liveTime = model.currentTime;
                        self.timeShiftModel = model;
                    });
                }@catch (NSException *exception) {
                    
                }
            }
        }];
    }else{
        self.liveTime ++;
        if (self.mCurrentStatus != AVPStatusPaused) {
            self.currentPlayTime ++;
        }
    }
    mCountTime++;
}

- (void)seekToLiveTime:(NSTimeInterval)startTime {
    [self stop];
    if (self.liveTime<=startTime) {
        self.currentPlayTime = self.liveTime;
        [self prepareWithLiveTimeUrl:mLivePlayingUrl];
        [self start];
    }else{
        NSTimeInterval count = self.liveTime - startTime;
        self.currentPlayTime = startTime;
        NSString *str = mLivePlayingUrl;
        NSString *currentStr  = @"";
        //判断 用户提供的播放地址，最后字符是否时“？”，同时是否时鉴权地址 autho_key。
        NSRange range;
        range = [str rangeOfString:@"?" options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            if (range.location == str.length-1) {
                currentStr = [NSString stringWithFormat:@"%@lhs_offset_unix_s_0==%.0f&lhs_start=1&aliyunols=on",str,count];
            }else{
                currentStr = [NSString stringWithFormat:@"%@&lhs_offset_unix_s_0=%.0f&lhs_start=1&aliyunols=on",str,count];
            }
        }else{
            currentStr = [NSString stringWithFormat:@"%@?lhs_offset_unix_s_0=%.0f&lhs_start=1&aliyunols=on",str,count];
        }
        
        AVPUrlSource* source = [[AVPUrlSource alloc] urlWithString:currentStr];
        [self setUrlSource:source];
        [self prepare];
        [self start];
    }
}

@end
