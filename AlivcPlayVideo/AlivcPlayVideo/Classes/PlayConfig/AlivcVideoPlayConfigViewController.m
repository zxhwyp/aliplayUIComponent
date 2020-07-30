//
//  AlivcVideoPlayConfigViewController.m
//  AlivcLongVideo
//
//  Created by ToT on 2019/12/17.
//

#import "AlivcVideoPlayConfigViewController.h"
#import "AlivcVideoPlayPlayerConfigViewController.h"
#import "AlivcVideoPlaySourceConfigViewController.h"
#import "AlivcVideoPlayPlayerConfig.h"
#import "AlivcLongVideoViewDetailController.h"
#import "AlivcUIConfig.h"
#import "AlivcVideoPlayButtonSelectView.h"
#import "AVPTool.h"
#import "AlivcPlayVideoRequestManager.h"
#import "NSString+AlivcHelper.h"
#import "AVPDemoServerManager.h"

@interface AlivcVideoPlayConfigViewController ()

@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)AlivcVideoPlayPlayerConfig *playerConfig;
@property (nonatomic,strong)AlivcVideoPlayButtonSelectView *sourceSelectView;
@property (nonatomic,strong)AlivcVideoPlayButtonSelectView *decoderSelectView;
@property (nonatomic,strong)AlivcVideoPlayButtonSelectView *mirrorSelectView;
@property (nonatomic,strong)AlivcVideoPlayButtonSelectView *rotateSelectView;
@property (nonatomic,strong)AlivcVideoPlayButtonSelectView *autoVideoSelectView;
@property (nonatomic,strong)AlivcVideoPlayButtonSelectView *seekModeSelectView;
@property (nonatomic,strong)AlivcVideoPlayButtonSelectView *backPlaySelectView;
@property (nonatomic,assign)BOOL hasPush;

@end

@implementation AlivcVideoPlayConfigViewController

- (void)dealloc {
    NSLog(@"AlivcVideoPlayConfigViewController释放了");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [@"播放设置" localString];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
    self.playerConfig = [[AlivcVideoPlayPlayerConfig alloc]init];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[AlivcImage imageInBasicVideoNamed:@"alivc_barrage"] style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonItemAction)];
    
    [self addViews];
    
    //初始化播放器组件
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"AlivcBasicVideo.bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:path];
        NSString *encrptyFilePath = [bundle pathForResource:@"encryptedApp" ofType:@"dat"];
        [AliPrivateService initKey:encrptyFilePath];
//        [AliPlayer setEnableLog:YES];
//        [AliPlayer setLogCallbackInfo:LOG_LEVEL_DEBUG callbackBlock:nil];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.hidden = NO;
    self.hasPush = NO;
    
    self.sourceSelectView.selectIndex = self.playerConfig.sourceType;
}

- (void)addViews {
    
    NSInteger leftEdge = 30;
    NSInteger viewWidth = self.view.frame.size.width - leftEdge * 2;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - SafeBottom-SafeTop-leftEdge-40-44)];
    self.scrollView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.view addSubview:self.scrollView];
    
    self.sourceSelectView = [[AlivcVideoPlayButtonSelectView alloc]initWithTitle:[@"播放源" localString] sourceArray:@[[@"默认源" localString],@"URL",@"STS",@"MPS",@"AUTH",@"liveSts"] width:viewWidth];
    self.sourceSelectView.frame = CGRectMake(leftEdge, leftEdge, viewWidth, self.sourceSelectView.viewHeight);
    __weak typeof(self) weakSelf = self;
    self.sourceSelectView.callBack = ^(NSInteger index) {
        weakSelf.playerConfig.sourceType = (SourceType)index;
    };
    [self.scrollView addSubview:self.sourceSelectView];
    
    self.decoderSelectView = [[AlivcVideoPlayButtonSelectView alloc]initWithTitle:[@"解码方式" localString] sourceArray:@[[@"软解" localString],[@"硬解" localString]] width:viewWidth];
    self.decoderSelectView.frame = CGRectMake(leftEdge, CGRectGetMaxY(self.sourceSelectView.frame)+leftEdge, viewWidth, self.decoderSelectView.viewHeight);
    [self.scrollView addSubview:self.decoderSelectView];
    
    self.mirrorSelectView = [[AlivcVideoPlayButtonSelectView alloc]initWithTitle:[@"镜像模式" localString] sourceArray:@[[@"无" localString],[@"水平" localString],[@"垂直" localString]] width:viewWidth];
    self.mirrorSelectView.frame = CGRectMake(leftEdge, CGRectGetMaxY(self.decoderSelectView.frame)+leftEdge, viewWidth, self.mirrorSelectView.viewHeight);
    [self.scrollView addSubview:self.mirrorSelectView];
    
    self.rotateSelectView = [[AlivcVideoPlayButtonSelectView alloc]initWithTitle:[@"旋转角度" localString] sourceArray:@[@"0°",@"90°",@"180°",@"270°"] width:viewWidth];
    self.rotateSelectView.frame = CGRectMake(leftEdge, CGRectGetMaxY(self.mirrorSelectView.frame)+leftEdge, viewWidth, self.rotateSelectView.viewHeight);
    [self.scrollView addSubview:self.rotateSelectView];
     
    self.autoVideoSelectView = [[AlivcVideoPlayButtonSelectView alloc]initWithTitle:[@"自适应码率" localString] sourceArray:@[[@"关闭" localString],[@"开启" localString]] width:viewWidth];
    self.autoVideoSelectView.frame = CGRectMake(leftEdge, CGRectGetMaxY(self.rotateSelectView.frame)+leftEdge, viewWidth, self.autoVideoSelectView.viewHeight);
    [self.scrollView addSubview:self.autoVideoSelectView];
    
    self.seekModeSelectView = [[AlivcVideoPlayButtonSelectView alloc]initWithTitle:[@"seek模式" localString] sourceArray:@[[@"非精准seek" localString],[@"精准seek" localString]] width:viewWidth];
    self.seekModeSelectView.frame = CGRectMake(leftEdge, CGRectGetMaxY(self.autoVideoSelectView.frame)+leftEdge, viewWidth, self.seekModeSelectView.viewHeight);
    [self.scrollView addSubview:self.seekModeSelectView];
    
    self.backPlaySelectView = [[AlivcVideoPlayButtonSelectView alloc]initWithTitle:[@"后台播放" localString] sourceArray:@[[@"关闭" localString],[@"打开" localString]] width:viewWidth];
    self.backPlaySelectView.frame = CGRectMake(leftEdge, CGRectGetMaxY(self.seekModeSelectView.frame)+leftEdge, viewWidth, self.backPlaySelectView.viewHeight);
    [self.scrollView addSubview:self.backPlaySelectView];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(self.backPlaySelectView.frame));
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40 - SafeBottom-SafeTop-44, self.view.frame.size.width, 40)];
    button.backgroundColor = [AlivcUIConfig shared].kAVCThemeColor;
    button.titleLabel.font = [UIFont systemFontOfSize:18];
    [button setTitle:[@"开启播放界面" localString] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pushToPlayView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-40-leftEdge, 20, 40, 38)];
    editButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [editButton setTitle:[@"编辑" localString] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:editButton];
}

#pragma mark action

- (void)rightBarButtonItemAction {
    AlivcVideoPlayPlayerConfigViewController *vc = [[AlivcVideoPlayPlayerConfigViewController alloc]init];
    vc.playerConfig = self.playerConfig;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)editButtonAction {
    NSLog(@"编辑");
    
    AlivcVideoPlaySourceConfigViewController *vc = [[AlivcVideoPlaySourceConfigViewController alloc]init];
    vc.playerConfig = self.playerConfig;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushToPlayView:(UIButton *)sender {
    switch (self.sourceSelectView.selectIndex) {
        case 1: {
            if (!self.playerConfig.urlSource) {
                [AVPTool loadingHudToView:self.view];
                [AlivcPlayVideoRequestManager getWithParameters:nil urlType:AVPUrlTypePlayerVideoPlayInfo success:^(AVPDemoResponseModel *responseObject) {
                    [AVPTool hideLoadingHudForView:self.view];
                    self.playerConfig.urlSource = [[AVPUrlSource alloc]urlWithString:responseObject.data.playInfoList.firstObject.playURL];
                    [self pushToPlayViewHasSource];
                } failure:^(NSString *errorMsg) {
                    [AVPTool hideLoadingHudForView:self.view];
                    [AVPTool hudWithText:errorMsg view:self.view];
                }];
            }else {
               [self pushToPlayViewHasSource];
            }
        }
            break;
        case 2: {
            if (!self.playerConfig.vidStsSource) {
                [AVPTool loadingHudToView:self.view];
                [AlivcPlayVideoRequestManager getWithParameters:nil urlType:AVPUrlTypePlayerVideoSts success:^(AVPDemoResponseModel *responseObject) {
                    [AVPTool hideLoadingHudForView:self.view];
                    self.playerConfig.vidStsSource = [[AVPVidStsSource alloc] initWithVid:responseObject.data.videoId accessKeyId:responseObject.data.accessKeyId accessKeySecret:responseObject.data.accessKeySecret securityToken:responseObject.data.securityToken region:@"cn-shanghai"];
                    [self pushToPlayViewHasSource];
                } failure:^(NSString *errorMsg) {
                    [AVPTool hideLoadingHudForView:self.view];
                    [AVPTool hudWithText:errorMsg view:self.view];
                }];
            }else {
               [self pushToPlayViewHasSource];
            }
        }
            break;
        case 3: {
            if (!self.playerConfig.vidMpsSource) {
                [AVPTool loadingHudToView:self.view];
                [AlivcPlayVideoRequestManager getWithParameters:nil urlType:AVPUrlTypePlayerVideoMps success:^(AVPDemoResponseModel *responseObject) {
                    [AVPTool hideLoadingHudForView:self.view];
                    self.playerConfig.vidMpsSource = [[AVPVidMpsSource alloc]initWithVid:responseObject.data.MediaId accId:responseObject.data.AkInfo.AccessKeyId accSecret:responseObject.data.AkInfo.AccessKeySecret stsToken:responseObject.data.AkInfo.SecurityToken authInfo:responseObject.data.authInfo region:responseObject.data.RegionId playDomain:@"" mtsHlsUriToken:responseObject.data.HlsUriToken];
                    [self pushToPlayViewHasSource];
                } failure:^(NSString *errorMsg) {
                    [AVPTool hideLoadingHudForView:self.view];
                    [AVPTool hudWithText:errorMsg view:self.view];
                }];
            }else {
               [self pushToPlayViewHasSource];
            }
        }
            break;
        case 4: {
            if (!self.playerConfig.vidAuthSource) {
                [AVPTool loadingHudToView:self.view];
                [AlivcPlayVideoRequestManager getWithParameters:nil urlType:AVPUrlTypePlayerVideoPlayAuth success:^(AVPDemoResponseModel *responseObject) {
                    [AVPTool hideLoadingHudForView:self.view];
                    self.playerConfig.vidAuthSource = [[AVPVidAuthSource alloc]initWithVid:responseObject.data.videoMeta.videoId playAuth:responseObject.data.playAuth region:@"cn-shanghai"];
                    [self pushToPlayViewHasSource];
                } failure:^(NSString *errorMsg) {
                    [AVPTool hideLoadingHudForView:self.view];
                    [AVPTool hudWithText:errorMsg view:self.view];
                }];
            }else {
               [self pushToPlayViewHasSource];
            }
        }
            break;
        case 5: {
            if (!self.playerConfig.liveStsSource) {
                [AVPTool loadingHudToView:self.view];
                [AlivcPlayVideoRequestManager getWithParameters:nil urlType:AVPUrlTypePlayerVideoLiveSts success:^(AVPDemoResponseModel *responseObject) {
                    [AVPTool hideLoadingHudForView:self.view];
                    self.playerConfig.liveStsSource = [[AVPLiveStsSource alloc] initWithUrl:@"" accessKeyId:responseObject.data.accessKeyId accessKeySecret:responseObject.data.accessKeySecret securityToken:responseObject.data.securityToken region:@"cn-shanghai" domain:@"" app:@"" stream:@""];
                    self.playerConfig.liveStsExpireTime = [AVPDemoServerManager getExpirTime:responseObject.data.expiration];
                    [self pushToPlayViewHasSource];
                } failure:^(NSString *errorMsg) {
                    [AVPTool hideLoadingHudForView:self.view];
                    [AVPTool hudWithText:errorMsg view:self.view];
                }];
            }else {
               [self pushToPlayViewHasSource];
            }
        }
            break;
        default:
            [self pushToPlayViewHasSource];
            break;
    }
}

- (void)pushToPlayViewHasSource {
    if (!self.hasPush) {
        self.hasPush = YES;
        self.playerConfig.sourceType = (SourceType)self.sourceSelectView.selectIndex;
        self.playerConfig.enableHardwareDecoder = (BOOL)self.decoderSelectView.selectIndex;
        self.playerConfig.mirrorMode = (AVPMirrorMode)self.mirrorSelectView.selectIndex;
        self.playerConfig.rotateMode = (AVPRotateMode)self.rotateSelectView.selectIndex*90;
        self.playerConfig.autoVideo = (BOOL)self.autoVideoSelectView.selectIndex;
        if (self.playerConfig.autoVideo) {
            self.playerConfig.urlSource.definitions = self.playerConfig.vidStsSource.definitions = self.playerConfig.vidMpsSource.definitions = self.playerConfig.vidAuthSource.definitions = @"AUTO";
        }
        self.playerConfig.accurateSeek = (BOOL)self.seekModeSelectView.selectIndex;
        self.playerConfig.backPlay = (BOOL)self.backPlaySelectView.selectIndex;
                
        AlivcLongVideoViewDetailController *vc = [[AlivcLongVideoViewDetailController alloc]init];
        vc.playerConfig = self.playerConfig;
        [self.navigationController pushViewController:vc animated:YES];
        
        NSLog(@"开启播放");
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
