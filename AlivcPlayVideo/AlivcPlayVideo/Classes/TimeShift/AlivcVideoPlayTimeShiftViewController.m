//
//  Created by ToT on 2019/12/4.
//  Copyright © 2019 aliyun. All rights reserved.
//

#import "AlivcVideoPlayTimeShiftViewController.h"
#import "AlivcVideoPlayLiveTimeShift.h"
#import "AlivcVideoPlayTimeShiftView.h"
#import "AVPTool.h"

@interface AlivcVideoPlayTimeShiftViewController ()<AVPDelegate,AlivcVideoPlayTimeShiftViewDelegate>

@property (nonatomic,strong)AlivcVideoPlayLiveTimeShift *livePlayer;
@property (nonatomic,assign)AVPStatus playerStatus;
@property (nonatomic,assign)NSTimeInterval tempTotalTime;
@property (nonatomic,strong)AlivcVideoPlayTimeShiftView *playerView;
@property (nonatomic,strong)NSTimer *timer;

@end

@implementation AlivcVideoPlayTimeShiftViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"AlivcVideoPlayTimeShiftViewController 释放了");
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.navigationController.navigationBar.hidden = YES;
    
    self.view.backgroundColor = [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1];
    
    self.playerView = [[AlivcVideoPlayTimeShiftView alloc]initWithFrame:CGRectMake(0, SafeTop, self.view.frame.size.width, self.view.frame.size.width*9/16)];
    self.playerView.delegate = self;
    [self.view addSubview:self.playerView];
    
    self.livePlayer = [[AlivcVideoPlayLiveTimeShift alloc] init];
    self.livePlayer.playerView = self.playerView.livePlayView;
    self.livePlayer.delegate = self;
    [self livePlayerPrepare];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerLoopAction:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    // app进入后台的观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationWillResignActiveNotification object:nil];
    // app从后台进入前台的观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name: UIApplicationDidBecomeActiveNotification object:nil];
    
    //禁止手势返回
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)livePlayerPrepare {
    [self.playerView hiddenRetryButton];
    [self.playerView showLoadingView];
    NSTimeInterval currentSeconds = [[NSDate date] timeIntervalSince1970];
    NSString *currentLive = [NSString stringWithFormat:@"http://qt1.alivecdn.com/openapi/timeline/query?auth_key=1594731135-0-0-61c9bd253b29ef4c8017ce05c0953083&app=timeline&stream=testshift&format=ts&lhs_start_unix_s_0=%.0f&lhs_end_unix_s_0=%.0f",(currentSeconds - 5 * 60), (currentSeconds + 5 * 60)];
    [self.livePlayer setLiveTimeShiftUrl:currentLive];
    [self.livePlayer prepareWithLiveTimeUrl:@"http://qt1.alivecdn.com/timeline/testshift.m3u8?auth_key=1594730859-0-0-b71fd57c57a62a3c2b014f24ca2b9da3"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.livePlayer stop];
    [self.livePlayer destroy];
    [self.timer invalidate];
}

- (void)timerLoopAction:(NSTimer *)sender {
    if (self.livePlayer) {
        //开始时间
        double s = self.livePlayer.timeShiftModel.startTime;
        //记录总的结束时间， getmodel 直播时间 - 播放时间<2分钟， getmodel直播时间+5分钟
        if (self.tempTotalTime ==0) {
            self.tempTotalTime = self.livePlayer.timeShiftModel.endTime;
        }
        //可时移时间
        double shiftTime = (self.livePlayer.timeShiftModel.endTime - self.livePlayer.timeShiftModel.startTime)*0.1;
        if ((self.tempTotalTime-self.livePlayer.liveTime)<0.5*shiftTime) {
            self.tempTotalTime = self.livePlayer.liveTime+shiftTime;
        }
        //进度条总长度
        double n = self.tempTotalTime - s;
        //播放进度百分比，小球位置
        double t = (self.livePlayer.currentPlayTime-s)/n;
        if (isnan(t)|isinf(t)) { t = 0; }
        [self.playerView setSliderValue:t];
        //直播进度百分比，红色区域
        double p = (self.livePlayer.liveTime-s)/n;
        //红色竖线位置
        if (isnan(p)|isinf(p)) { p = 0; }
        if (p > 1) { p = 1; }
        [self.playerView setProgressValue:p];
        //更新当前时间和时移时间页面
        self.playerView.currentPlayTime = self.livePlayer.currentPlayTime;
        self.playerView.tempTotalTime = self.tempTotalTime;
    }
}

- (void)applicationEnterBackground {
    [self.livePlayer pause];
}

- (void)applicationDidBecomeActive {
    [self.livePlayer start];
}

#pragma mark AlivcVideoPlayTimeShiftViewDelegate

- (void)playButtonActionInTimeShiftView:(AlivcVideoPlayTimeShiftView *)timeShiftView {
    if (self.playerStatus == AVPStatusStarted) {
        [self.livePlayer pause];
    }else if (self.playerStatus == AVPStatusIdle || self.playerStatus == AVPStatusInitialzed || self.playerStatus == AVPStatusStopped || self.playerStatus == AVPStatusCompletion || self.playerStatus == AVPStatusError) {
        [self livePlayerPrepare];
    }else {
        [self.livePlayer start];
    }
}

- (void)retryButtonActionInTimeShiftView:(AlivcVideoPlayTimeShiftView *)timeShiftView {
    [self livePlayerPrepare];
}

- (void)timeShiftView:(AlivcVideoPlayTimeShiftView *)timeShiftView sliderValueChanged:(CGFloat)value {
    NSLog(@"%@,%f",timeShiftView,value);
    if (self.tempTotalTime > 0) {
        [self.playerView showLoadingView];
        NSTimeInterval startTime = self.livePlayer.timeShiftModel.startTime;
        [self.livePlayer seekToLiveTime:(self.tempTotalTime-startTime)*value+startTime];
    }
}

- (void)timeShiftView:(AlivcVideoPlayTimeShiftView *)timeShiftView fullScreenChanged:(BOOL)isfullScreen {
    NSLog(@"点击全屏");
}

- (void)backButtonTouchedInTimeShiftView:(AlivcVideoPlayTimeShiftView *)timeShiftView {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark AVPDelegate

-(void)onPlayerEvent:(AliPlayer*)player eventType:(AVPEventType)eventType {
    switch (eventType) {
        case AVPEventPrepareDone:
            [self.livePlayer start];
            break;
        case AVPEventFirstRenderedStart:
            [self.playerView hiddenLoadingView];
            break;
        case AVPEventLoadingStart:
            [self.playerView showLoadingView];
            break;
        case AVPEventLoadingEnd:
            [self.playerView hiddenLoadingView];
            break;
        default:
            break;
    }
}

- (void)onPlayerStatusChanged:(AliPlayer*)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus {
    self.playerStatus = newStatus;
    if (newStatus == AVPStatusStarted) {
        self.playerView.isPlaying = YES;
    }else {
        self.playerView.isPlaying = NO;
    }
}

- (void)onError:(AliPlayer *)player errorModel:(AVPErrorModel *)errorModel {
    NSLog(@"errorCode:%lu errorMessage%@",(unsigned long)errorModel.code,errorModel.message);
    
    [AVPTool hudWithText:errorModel.message view:self.view];
    if (errorModel.code != ERROR_SERVER_LIVESHIFT_REQUEST_ERROR) {
        [self.playerView hiddenLoadingView];
        [self.playerView showRetryButton];
    }
}

- (void)onPlayerEvent:(AliPlayer*)player eventWithString:(AVPEventWithString)eventWithString description:(NSString *)description {
    [AVPTool hudWithText:description view:self.view];
}

@end
