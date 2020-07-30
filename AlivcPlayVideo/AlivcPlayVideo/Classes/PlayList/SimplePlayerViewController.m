//
//  SimplePlayerViewController.m
//  AliPlayerDemo
//
//  Created by 郦立 on 2019/1/9.
//  Copyright © 2019年 com.alibaba. All rights reserved.
//

#import "SimplePlayerViewController.h"
#import "AVPSimplePlayScrollView.h"
#import "AVPErrorModel+string.h"
#import "AVPTool.h"
#import "AliyunReachability.h"
#import "AlivcVideoPlayEmptyView.h"
#import "NSString+AlivcHelper.h"

@interface SimplePlayerViewController ()<AVPSimplePlayScrollViewDelegate,AVPDelegate>

/**
 滚动视图容器
 */
@property (nonatomic,strong)AVPSimplePlayScrollView *simplePlayScrollView;

/**
 播放器当前状态
 */
@property (nonatomic,assign)AVPStatus playerStatus;

/**
 是否正在请求，变量控制重复请求
 */
@property (nonatomic,assign)BOOL isAtRequest;

/**
 最大数据量
 */
@property (nonatomic,assign)NSInteger maxDataCount;

@property (nonatomic,strong)AliyunReachability *reachability;
@property (nonatomic,strong)AlivcVideoPlayEmptyView *emptyView;

@end

@implementation SimplePlayerViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"SimplePlayerViewController释放了");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.maxDataCount = 999;
    self.view.backgroundColor = [UIColor blackColor];
    
    self.simplePlayScrollView = [[AVPSimplePlayScrollView alloc]initWithFrame:self.view.bounds dataArray:self.dataArray];
    self.simplePlayScrollView.delegate = self;
    self.simplePlayScrollView.currentIndex = self.currentModel.index;
    [self.view addSubview:self.simplePlayScrollView];
    
    [self initPlayer];
    
    self.reachability = [AliyunReachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged) name:AliyunSVReachabilityChangedNotification object:nil];
    if ([self.reachability currentReachabilityStatus] != AliyunSVNetworkStatusNotReachable) {
        [self moveToCurrentModel];
        if (self.dataArray.count - self.currentModel.index < 5) {
            [self AVPSimplePlayScrollViewNeedNewData:self.simplePlayScrollView];
        }
    }else {
        __weak typeof(self)weakSelf = self;
        self.emptyView = [[AlivcVideoPlayEmptyView alloc]initWithFrame:self.view.bounds];
        self.emptyView.callBack = ^{
            switch ([weakSelf.reachability currentReachabilityStatus]) {
                case AliyunSVNetworkStatusNotReachable:
                    [AVPTool hudWithText:[@"当前无网络" localString] view:weakSelf.view];
                    break;
                case AliyunSVNetworkStatusReachableViaWWAN:
                case AliyunSVNetworkStatusReachableViaWiFi: {
                    [weakSelf AVPSimplePlayScrollViewNeedNewData:weakSelf.simplePlayScrollView];
                }
                    break;
                default:
                    break;
            }
        };
        self.emptyView.backCallBack = ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        [self.view addSubview:self.emptyView];
    }

    // 添加检测app进入后台的观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationWillResignActiveNotification object:nil];
    // app从后台进入前台都会调用这个方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name: UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear stop before");
    [self.listPlayer stop];
    NSLog(@"viewDidDisappear stop after");
//    [self.listPlayer destroy];
    NSLog(@"viewDidDisappear destroy after");
    [self.listPlayer destroy];
    self.listPlayer = nil;
}

- (void)initPlayer {
    self.listPlayer = [[AliListPlayer alloc]init];
    self.listPlayer.loop = YES;
    self.listPlayer.autoPlay = YES;
    self.listPlayer.scalingMode = AVP_SCALINGMODE_SCALEASPECTFIT;
    self.listPlayer.delegate = self;
    self.listPlayer.stsPreloadDefinition = @"FD";
    self.listPlayer.playerView = self.simplePlayScrollView.playView;
    if (self.dataArray.count > 0) {
        if (self.PlaySourceType == AVPPlaySourceTypeVID) {
            for (AVPDemoResponseVideoListModel *model in self.dataArray) {
                [self.listPlayer addVidSource:model.videoId uid:model.uuid.UUIDString];
            }
        }else {
            for (AVPDemoResponseVideoListModel *model in self.dataArray) {
                [self.listPlayer addUrlSource:model.fileUrl uid:model.uuid.UUIDString];
            }
        }
    }
}

- (void)moveToCurrentModel {
    if (!self.currentModel) { return; }
    if (self.PlaySourceType == AVPPlaySourceTypeVID) {
        if (DEFAULT_SERVER.expirationTime <= [AVPTool currentTimeInterval]) {
            [AVPDemoServerManager reloadStsTokenInView:self.view success:^(AVPDemoResponseModel *responseObject) {
                [self moveToCurrentModelTokenEffective];
            } failure:nil];
        }else {
            [self moveToCurrentModelTokenEffective];
        }
    }else {
        [self.listPlayer moveTo:self.currentModel.uuid.UUIDString];
    }
}

- (void)moveToCurrentModelTokenEffective {
    [self.listPlayer moveTo:self.currentModel.uuid.UUIDString accId:DEFAULT_SERVER.accessKeyId accKey:DEFAULT_SERVER.accessKeySecret token:DEFAULT_SERVER.securityToken region:DEFAULT_SERVER.region];
}

- (void)applicationEnterBackground {
    [self.listPlayer pause];
    self.listPlayer.autoPlay = NO;
}

- (void)applicationDidBecomeActive {
    [self.listPlayer start];
    self.listPlayer.autoPlay = YES;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

#pragma mark AVPSimplePlayScrollViewDelegate

/**
 返回按钮点击事件
 
 @param simplePlayScrollView simplePlayScrollView
 */
- (void)AVPSimplePlayScrollViewBackButtonTouched:(AVPSimplePlayScrollView *)simplePlayScrollView {
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 全屏点击事件
 
 @param simplePlayScrollView simplePlayScrollView
 */
- (void)AVPSimplePlayScrollViewTapGestureAction:(AVPSimplePlayScrollView *)simplePlayScrollView {
    if (self.playerStatus == AVPStatusStarted) {
        [self.listPlayer pause];
    }else if (self.playerStatus == AVPStatusPaused) {
        [self.listPlayer start];
    }
}

/**
 滚动事件,移动位置超过一个
 
 @param simplePlayScrollView simplePlayScrollView
 @param index 移动到第几个
 */
- (void)AVPSimplePlayScrollView:(AVPSimplePlayScrollView *)simplePlayScrollView scrollViewDidEndDeceleratingAtIndex:(NSInteger)index {
    self.simplePlayScrollView.showPlayImage = NO;
    AVPDemoResponseVideoListModel *model = [self findModelFromIndex:index];
    if (self.playerStatus == AVPStatusPaused && index == self.currentModel.index) {
        [self.simplePlayScrollView showPlayView];
        [self.listPlayer start];
    }else {
        self.currentModel = model;
        [self moveToCurrentModel];
    }
    NSLog(@"播放第%ld个",(long)index);
}

/**
 移动到下一个
 
 @param simplePlayScrollView simplePlayScrollView
 @param index 第几个
 */
- (void)AVPSimplePlayScrollView:(AVPSimplePlayScrollView *)simplePlayScrollView motoNextAtIndex:(NSInteger)index {
    self.simplePlayScrollView.showPlayImage = NO;
    AVPDemoResponseVideoListModel *model = [self findModelFromIndex:index];
    if (model && self.currentModel != model) {
        self.currentModel = model;
        if (self.PlaySourceType == AVPPlaySourceTypeVID) {
            if (DEFAULT_SERVER.expirationTime <= [AVPTool currentTimeInterval]) {
                [AVPDemoServerManager reloadStsTokenInView:self.view success:^(AVPDemoResponseModel *responseObject) {
                    [self.listPlayer moveToNext:DEFAULT_SERVER.accessKeyId accKey:DEFAULT_SERVER.accessKeySecret token:DEFAULT_SERVER.securityToken region:DEFAULT_SERVER.region];
                } failure:nil];
            }else {
                [self.listPlayer moveToNext:DEFAULT_SERVER.accessKeyId accKey:DEFAULT_SERVER.accessKeySecret token:DEFAULT_SERVER.securityToken region:DEFAULT_SERVER.region];
            }
        }else {
            [self.listPlayer moveToNext];
        }
        NSLog(@"播放第%ld个",(long)index);
    }
}

/**
 移动到上一个
 
 @param simplePlayScrollView simplePlayScrollView
 @param index 第几个
 */
- (void)AVPSimplePlayScrollView:(AVPSimplePlayScrollView *)simplePlayScrollView motoPreAtIndex:(NSInteger)index {
    self.simplePlayScrollView.showPlayImage = NO;
    AVPDemoResponseVideoListModel *model = [self findModelFromIndex:index];
    if (model && self.currentModel != model) {
        self.currentModel = model;
        if (self.PlaySourceType == AVPPlaySourceTypeVID) {
            if (DEFAULT_SERVER.expirationTime <= [AVPTool currentTimeInterval]) {
                [AVPDemoServerManager reloadStsTokenInView:self.view success:^(AVPDemoResponseModel *responseObject) {
                    [self.listPlayer moveToPre:DEFAULT_SERVER.accessKeyId accKey:DEFAULT_SERVER.accessKeySecret token:DEFAULT_SERVER.securityToken region:DEFAULT_SERVER.region];
                } failure:nil];
            }else {
                [self.listPlayer moveToPre:DEFAULT_SERVER.accessKeyId accKey:DEFAULT_SERVER.accessKeySecret token:DEFAULT_SERVER.securityToken region:DEFAULT_SERVER.region];
            }
        }else {
            [self.listPlayer moveToPre];
        }
        NSLog(@"播放第%ld个",(long)index);
    }
}

- (AVPDemoResponseVideoListModel *)findModelFromIndex:(NSInteger)index {
    for (AVPDemoResponseVideoListModel *model in self.dataArray) {
        if (model.index == index) {
            return model;
        }
    }
    return nil;
}

/**
 需要新数据回调
 
 @param simplePlayScrollView simplePlayScrollView
 */
- (void)AVPSimplePlayScrollViewNeedNewData:(AVPSimplePlayScrollView *)simplePlayScrollView {
    if (!self.isAllData) {
        if (self.isAtRequest) {
            return;
        }
        self.isAtRequest = YES;
        AVPDemoResponseVideoListModel *lastModel = nil;
        if (self.dataArray.count != 0) { lastModel = self.dataArray.lastObject; }
        [AVPDemoServerManager getVideoListArrayWithHudView:nil type:self.PlaySourceType model:lastModel success:^(AVPDemoResponseModel *responseObject) {
            int lastIndex = -1;
            if (lastModel) { lastIndex = (int)lastModel.index; }
            AVPDemoResponseVideoListModel *firstModel = responseObject.data.videoList.firstObject;
            if (firstModel && firstModel.index > lastIndex) {
                [self addDataSource:responseObject.data.videoList];
                if (responseObject.data.videoList.count < pageSize) {
                    self.isAllData = YES;
                }
                if (self.currentModel == nil) {
                    self.currentModel = self.dataArray.firstObject;
                    if (self.currentModel) { [self moveToCurrentModel]; }
                }
            }
            self.isAtRequest = NO;
            if (self.dataArray.count == 1) {
                [self AVPSimplePlayScrollViewNeedNewData:self.simplePlayScrollView];
            }
        } failure:^(NSString *errorMsg) {
            self.isAtRequest = NO;
        }];
    }
}

- (void)addDataSource:(NSArray *)array {
    for (AVPDemoResponseVideoListModel *model in array) {
        if (self.PlaySourceType == AVPPlaySourceTypeVID) {
            [self.listPlayer addVidSource:model.videoId uid:model.uuid.UUIDString];
        }else {
            [self.listPlayer addUrlSource:model.fileUrl uid:model.uuid.UUIDString];
        }
    }
    [self.dataArray addObjectsFromArray:array];
    [self.simplePlayScrollView addDataArray:array];
    if (self.dataArray.count > self.maxDataCount) {
        NSArray *removeArray = [self.dataArray subarrayWithRange:NSMakeRange(0, self.dataArray.count - self.maxDataCount)];
        for (AVPDemoResponseVideoListModel *model in removeArray) {
            [self.listPlayer removeSource:model.uuid.UUIDString];
        }
        [self.dataArray removeObjectsInArray:removeArray];
        [self.simplePlayScrollView removeDataArray:removeArray];
    }
}

/**
 当前播放视图移除屏幕
 
 @param simplePlayScrollView simplePlayScrollView
 */
- (void)AVPSimplePlayScrollViewScrollOut:(AVPSimplePlayScrollView *)simplePlayScrollView {
    [self.listPlayer pause];
}

/**
 下拉刷新回调

 @param simplePlayScrollView simplePlayScrollView
 */
- (void)AVPSimplePlayScrollViewHeaderRefreshing:(AVPSimplePlayScrollView *)simplePlayScrollView {
    [AVPDemoServerManager getVideoListArrayWithHudView:self.view type:self.PlaySourceType model:nil success:^(AVPDemoResponseModel *responseObject) {
        for (AVPDemoResponseVideoListModel *model in self.dataArray) {
            [self.listPlayer removeSource:model.uuid.UUIDString];
        }
        [self.simplePlayScrollView removeDataArray:self.dataArray];
        [self.dataArray removeAllObjects];
        [self.simplePlayScrollView endRefreshingAndReset:YES];
        
        [self addDataSource:responseObject.data.videoList];
        if (responseObject.data.videoList.count < pageSize) { self.isAllData = YES; }
        self.currentModel = self.dataArray.firstObject;
        if (self.currentModel) { [self moveToCurrentModel]; }
        if (self.dataArray.count == 1) {
            [self AVPSimplePlayScrollViewNeedNewData:self.simplePlayScrollView];
        }
    } failure:^(NSString *errorMsg) {
        [self.simplePlayScrollView endRefreshingAndReset:NO];
    }];
}

#pragma mark AVPDelegate

/**
 @brief 错误代理回调
 @param player 播放器player指针
 @param errorModel 播放器错误描述，参考AliVcPlayerErrorModel
 */
- (void)onError:(AliPlayer*)player errorModel:(AVPErrorModel *)errorModel {
    [AVPTool hudWithText:[errorModel errorString] view:self.view];
}

/**
 @brief 播放器事件回调
 @param player 播放器player指针
 @param eventType 播放器事件类型，@see AVPEventType
 */
-(void)onPlayerEvent:(AliPlayer*)player eventType:(AVPEventType)eventType {
    switch (eventType) {
        case AVPEventPrepareDone: {
        }
            break;
        case AVPEventFirstRenderedStart: {
            [self.simplePlayScrollView showPlayView];
        }
            break;
        default:
            break;
    }
}

/**
 @brief 播放器状态改变回调
 @param player 播放器player指针
 @param oldStatus 老的播放器状态 参考AVPStatus
 @param newStatus 新的播放器状态 参考AVPStatus
 */
- (void)onPlayerStatusChanged:(AliPlayer*)player oldStatus:(AVPStatus)oldStatus newStatus:(AVPStatus)newStatus {
    self.playerStatus = newStatus;
    switch (newStatus) {
        case AVPStatusStarted: {
            self.simplePlayScrollView.showPlayImage = NO;
        }
            break;
        case AVPStatusPaused: {
            self.simplePlayScrollView.showPlayImage = YES;
        }
            break;
        default:
            break;
    }
}

#pragma mark - 网络状态改变

- (void)reachabilityChanged {
    switch ([self.reachability currentReachabilityStatus]) {
        case AliyunSVNetworkStatusReachableViaWWAN: {
            [AVPTool hudWithText:[@"当前使用移动数据网络" localString] view:self.view];
        }
        case AliyunSVNetworkStatusReachableViaWiFi: {
            if ([self.view.subviews containsObject:self.emptyView]) {
                [self AVPSimplePlayScrollViewNeedNewData:self.simplePlayScrollView];
                [self.emptyView removeFromSuperview];
                [[NSNotificationCenter defaultCenter]removeObserver:self name:AliyunSVReachabilityChangedNotification object:nil];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - 默认竖屏

- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

@end









