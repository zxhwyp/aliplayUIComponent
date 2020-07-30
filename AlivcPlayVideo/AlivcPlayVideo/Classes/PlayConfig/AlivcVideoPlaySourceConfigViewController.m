//
//  AlivcVideoPlaySourceConfigViewController.m
//  AlivcLongVideo
//
//  Created by ToT on 2019/12/17.
//

#import "AlivcVideoPlaySourceConfigViewController.h"
#import "AlivcPlayVideoRequestManager.h"
#import "AlivcUIConfig.h"
#import "AlivcVideoPlayButtonSelectView.h"
#import "AlivcVideoPlayTextFieldTableViewCell.h"
#import "AlivcVideoPlayButtonTableViewCell.h"
#import "AVPTool.h"
#import "NSString+AlivcHelper.h"
#import "AlivcVideoPlayScanViewController.h"
#import "AVPDemoServerManager.h"
#import "AVPDemoServerManager.h"

@interface AlivcVideoPlaySourceConfigViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)AlivcVideoPlayButtonSelectView *sourceSelectView;
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSArray *sourceKeyArray;
@property (nonatomic,strong)AVPUrlSource *tempUrlSource;
@property (nonatomic,strong)AVPVidStsSource *tempVidStsSource;
@property (nonatomic,strong)AVPLiveStsSource *templiveStsSource;
@property (nonatomic,strong)AVPVidMpsSource *tempVidMpsSource;
@property (nonatomic,strong)AVPVidAuthSource *tempVidAuthSource;

@end

@implementation AlivcVideoPlaySourceConfigViewController

- (void)dealloc {
    NSLog(@"AlivcVideoPlaySourceConfigViewController释放了");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
    self.navigationItem.title = [@"播放设置" localString];
    [self addViews];
    
    NSString *key = @"url";
    if (self.sourceSelectView.selectIndex && self.sourceSelectView.selectIndex!=4) {
        key = @"vid";
    }
    NSString *value = [self findSourceValueForKey:key];
    if (value.length == 0) {
        [self resetConfig:nil];
    }else{
        [self copyFromPlayerConfig];
    }
}

- (void)addViews {
    
    NSInteger leftEdge = 30;
    NSInteger viewWidth = self.view.frame.size.width - leftEdge * 2;
    
    __weak typeof(self)weakself = self;
    self.sourceSelectView = [[AlivcVideoPlayButtonSelectView alloc]initWithTitle:[@"播放源" localString] sourceArray:@[@"URL",@"STS",@"MPS",@"AUTH",@"liveSts"] width:viewWidth lineContain:4];
    self.sourceSelectView.frame = CGRectMake(leftEdge, leftEdge, viewWidth, self.sourceSelectView.viewHeight);
    self.sourceSelectView.callBack = ^(NSInteger index) {
        [weakself.tableView reloadData];
    };
    [self.view addSubview:self.sourceSelectView];
    if (self.playerConfig.sourceType > 0) {
        self.sourceSelectView.selectIndex = self.playerConfig.sourceType-1;
    }else {
        self.sourceSelectView.selectIndex = 0;
    }
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(leftEdge, CGRectGetMaxY(self.sourceSelectView.frame)+leftEdge, viewWidth, self.view.frame.size.height- 40 - 44-  SafeBottom-SafeTop-CGRectGetMaxY(self.sourceSelectView.frame)-leftEdge*2)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView registerClass:[AlivcVideoPlayTextFieldTableViewCell class] forCellReuseIdentifier:@"AlivcVideoPlayTextFieldTableViewCell"];
    [self.tableView registerClass:[AlivcVideoPlayButtonTableViewCell class] forCellReuseIdentifier:@"AlivcVideoPlayButtonTableViewCell"];
    [self.view addSubview:self.tableView];
    
    NSInteger buttonWidth = self.view.frame.size.width/2;
    UIButton *useButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40 - SafeBottom-SafeTop-44, buttonWidth, 40)];
    useButton.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
    useButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [useButton setTitle:[@"使用此配置" localString] forState:UIControlStateNormal];
    [useButton addTarget:self action:@selector(useConfig:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:useButton];
    
    UIButton *resetButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth, self.view.frame.size.height - 40 - SafeBottom-SafeTop-44, buttonWidth, 40)];
    resetButton.backgroundColor = [AlivcUIConfig shared].kAVCThemeColor;
    resetButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [resetButton setTitle:[@"默认配置" localString] forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(resetConfig:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetButton];
    
    UIView *buttonline1 = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 40 - SafeBottom-SafeTop-44, buttonWidth, 0.5)];
    buttonline1.backgroundColor = [AlivcUIConfig shared].kAVCThemeColor;
    [self.view addSubview:buttonline1];
    
    UIView *buttonline2 = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 0.5 - SafeBottom-SafeTop-44, buttonWidth, 0.5)];
    buttonline2.backgroundColor = [AlivcUIConfig shared].kAVCThemeColor;
    [self.view addSubview:buttonline2];
}

#pragma mark action

- (void)useConfig:(UIButton *)sender {
    NSLog(@"useConfig");
    
    switch (self.sourceSelectView.selectIndex) {
        case 0: {
            self.playerConfig.urlSource = [AlivcVideoPlayPlayerConfig copyUrlSourceWithSource:self.tempUrlSource];
            self.playerConfig.sourceType = SourceTypeUrl;
        }
            break;
        case 1: {
            self.playerConfig.vidStsSource = [AlivcVideoPlayPlayerConfig copyStsSourceWithSource:self.tempVidStsSource];
            self.playerConfig.sourceType = SourceTypeSts;
        }
            break;
        case 2: {
            self.playerConfig.vidMpsSource = [AlivcVideoPlayPlayerConfig copyMpsSourceWithSource:self.tempVidMpsSource];
            self.playerConfig.sourceType = SourceTypeMps;
        }
            break;
        case 3: {
            self.playerConfig.vidAuthSource = [AlivcVideoPlayPlayerConfig copyAuthSourceWithSource:self.tempVidAuthSource];
            self.playerConfig.sourceType = SourceTypeAuth;
        }
        case 4: {
            self.playerConfig.liveStsSource = [AlivcVideoPlayPlayerConfig copyLiveStsSourceWithSource:self.templiveStsSource];
            self.playerConfig.sourceType = SourceTypeLiveSts;
        }
            break;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)copyFromPlayerConfig{
    NSLog(@"resetConfig");
    
    switch (self.sourceSelectView.selectIndex) {
        case 0: {
            self.tempUrlSource = [[AVPUrlSource alloc]urlWithString:self.playerConfig.urlSource.playerUrl.absoluteString];
        }
            break;
        case 1: {
            self.tempVidStsSource = [[AVPVidStsSource alloc] initWithVid:self.playerConfig.vidStsSource.vid accessKeyId:self.playerConfig.vidStsSource.accessKeyId accessKeySecret:self.playerConfig.vidStsSource.accessKeySecret securityToken:self.playerConfig.vidStsSource.securityToken region:self.playerConfig.vidStsSource.region];
        }
            break;
        case 2: {
            self.tempVidMpsSource = [[AVPVidMpsSource alloc]initWithVid:self.playerConfig.vidMpsSource.vid accId:self.playerConfig.vidMpsSource.accId accSecret:self.playerConfig.vidMpsSource.accSecret stsToken:self.playerConfig.vidMpsSource.stsToken authInfo:self.playerConfig.vidMpsSource.authInfo region:self.playerConfig.vidMpsSource.region playDomain:self.playerConfig.vidMpsSource.playDomain mtsHlsUriToken:self.playerConfig.vidMpsSource.mtsHlsUriToken];
        }
            break;
        case 3: {
            self.tempVidAuthSource = [[AVPVidAuthSource alloc]initWithVid:self.playerConfig.vidAuthSource.vid playAuth:self.playerConfig.vidAuthSource.playAuth region:self.playerConfig.vidAuthSource.region];
        }
            break;
        case 4: {
            self.templiveStsSource = [[AVPLiveStsSource alloc] initWithUrl:self.playerConfig.liveStsSource.url accessKeyId:self.playerConfig.liveStsSource.accessKeyId accessKeySecret:self.playerConfig.liveStsSource.accessKeySecret securityToken:self.playerConfig.liveStsSource.securityToken region:self.playerConfig.liveStsSource.region domain:self.playerConfig.liveStsSource.domain app:self.playerConfig.liveStsSource.app stream:self.playerConfig.liveStsSource.stream];
        }
        break;
        default:
            break;
    }
}

- (void)resetConfig:(UIButton *)sender {
    NSLog(@"resetConfig");
    
    switch (self.sourceSelectView.selectIndex) {
        case 0: {
            [AlivcPlayVideoRequestManager getWithParameters:nil urlType:AVPUrlTypePlayerVideoPlayInfo success:^(AVPDemoResponseModel *responseObject) {
                self.tempUrlSource = [[AVPUrlSource alloc]urlWithString:responseObject.data.playInfoList.firstObject.playURL];
                [self.tableView reloadData];
                [AVPTool hudWithText:[@"恢复成功" localString] view:self.view];
            } failure:^(NSString *errorMsg) {
                [AVPTool hudWithText:errorMsg view:self.view];
            }];
        }
            break;
        case 1: {
            [AlivcPlayVideoRequestManager getWithParameters:nil urlType:AVPUrlTypePlayerVideoSts success:^(AVPDemoResponseModel *responseObject) {
                self.tempVidStsSource = [[AVPVidStsSource alloc] initWithVid:responseObject.data.videoId accessKeyId:responseObject.data.accessKeyId accessKeySecret:responseObject.data.accessKeySecret securityToken:responseObject.data.securityToken region:@"cn-shanghai"];
                [self.tableView reloadData];
                [AVPTool hudWithText:[@"恢复成功" localString] view:self.view];
            } failure:^(NSString *errorMsg) {
                [AVPTool hudWithText:errorMsg view:self.view];
            }];
        }
            break;
        case 2: {
            [AlivcPlayVideoRequestManager getWithParameters:nil urlType:AVPUrlTypePlayerVideoMps success:^(AVPDemoResponseModel *responseObject) {
                self.tempVidMpsSource = [[AVPVidMpsSource alloc]initWithVid:responseObject.data.MediaId accId:responseObject.data.AkInfo.AccessKeyId accSecret:responseObject.data.AkInfo.AccessKeySecret stsToken:responseObject.data.AkInfo.SecurityToken authInfo:responseObject.data.authInfo region:responseObject.data.RegionId playDomain:@"" mtsHlsUriToken:responseObject.data.HlsUriToken];
                [self.tableView reloadData];
                [AVPTool hudWithText:[@"恢复成功" localString] view:self.view];
            } failure:^(NSString *errorMsg) {
                [AVPTool hudWithText:errorMsg view:self.view];
            }];
        }
            break;
        case 3: {
            [AlivcPlayVideoRequestManager getWithParameters:nil urlType:AVPUrlTypePlayerVideoPlayAuth success:^(AVPDemoResponseModel *responseObject) {
                self.tempVidAuthSource = [[AVPVidAuthSource alloc]initWithVid:responseObject.data.videoMeta.videoId playAuth:responseObject.data.playAuth region:@"cn-shanghai"];
                [self.tableView reloadData];
                [AVPTool hudWithText:[@"恢复成功" localString] view:self.view];
            } failure:^(NSString *errorMsg) {
                [AVPTool hudWithText:errorMsg view:self.view];
            }];
        }
            break;
        case 4: {
            [AlivcPlayVideoRequestManager getWithParameters:nil urlType:AVPUrlTypePlayerVideoLiveSts success:^(AVPDemoResponseModel *responseObject) {
                self.templiveStsSource = [[AVPLiveStsSource alloc] initWithUrl:@"" accessKeyId:responseObject.data.accessKeyId accessKeySecret:responseObject.data.accessKeySecret securityToken:responseObject.data.securityToken region:@"cn-shanghai" domain:@"" app:@"" stream:@""];
                self.playerConfig.liveStsExpireTime = [AVPDemoServerManager getExpirTime:responseObject.data.expiration];
                [self.tableView reloadData];
                [AVPTool hudWithText:[@"恢复成功" localString] view:self.view];
            } failure:^(NSString *errorMsg) {
                [AVPTool hudWithText:errorMsg view:self.view];
            }];
        }
        break;
        default:
            break;
    }
}

- (void)reloadStsConfig {
    NSLog(@"reloadStsConfig");
    
    switch (self.sourceSelectView.selectIndex) {
        case 1: {
            AVPVidStsSource *source = self.playerConfig.vidStsSource;
            if (self.tempVidStsSource) { source = self.tempVidStsSource; }
            if (source.vid.length == 0) {
                [AVPTool hudWithText:[@"vid不能为空" localString] view:self.view];
                return;
            }
            
            [AlivcPlayVideoRequestManager getWithParameters:@{@"videoId":source.vid} urlType:AVPUrlTypePlayerVideoSts success:^(AVPDemoResponseModel *responseObject) {
                self.tempVidStsSource = [[AVPVidStsSource alloc] initWithVid:responseObject.data.videoId accessKeyId:responseObject.data.accessKeyId accessKeySecret:responseObject.data.accessKeySecret securityToken:responseObject.data.securityToken region:@"cn-shanghai"];
                [self.tableView reloadData];
                [AVPTool hudWithText:[@"刷新成功" localString] view:self.view];
            } failure:^(NSString *errorMsg) {
                [AVPTool hudWithText:errorMsg view:self.view];
            }];
        }
            break;
        case 2: {
            AVPVidMpsSource *source = self.playerConfig.vidMpsSource;
            if (self.tempVidMpsSource) { source = self.tempVidMpsSource; }
            if (source.vid.length == 0) {
                [AVPTool hudWithText:[@"vid不能为空" localString] view:self.view];
                return;
            }
            
            [AlivcPlayVideoRequestManager getWithParameters:@{@"videoId":source.vid} urlType:AVPUrlTypePlayerVideoMps success:^(AVPDemoResponseModel *responseObject) {
                self.tempVidMpsSource = [[AVPVidMpsSource alloc]initWithVid:responseObject.data.MediaId accId:responseObject.data.AkInfo.AccessKeyId accSecret:responseObject.data.AkInfo.AccessKeySecret stsToken:responseObject.data.AkInfo.SecurityToken authInfo:responseObject.data.authInfo region:responseObject.data.RegionId playDomain:@"" mtsHlsUriToken:responseObject.data.HlsUriToken];
                [self.tableView reloadData];
                [AVPTool hudWithText:[@"刷新成功" localString] view:self.view];
            } failure:^(NSString *errorMsg) {
                [AVPTool hudWithText:errorMsg view:self.view];
            }];
        }
            break;
        case 3: {
            AVPVidAuthSource *source = self.playerConfig.vidAuthSource;
            if (self.tempVidAuthSource) { source = self.tempVidAuthSource; }
            if (source.vid.length == 0) {
                [AVPTool hudWithText:[@"vid不能为空" localString] view:self.view];
                return;
            }
            
            [AlivcPlayVideoRequestManager getWithParameters:@{@"videoId":source.vid} urlType:AVPUrlTypePlayerVideoPlayAuth success:^(AVPDemoResponseModel *responseObject) {
                self.tempVidAuthSource = [[AVPVidAuthSource alloc]initWithVid:responseObject.data.videoMeta.videoId playAuth:responseObject.data.playAuth region:@"cn-shanghai"];
                [self.tableView reloadData];
                [AVPTool hudWithText:[@"刷新成功" localString] view:self.view];
            } failure:^(NSString *errorMsg) {
                [AVPTool hudWithText:errorMsg view:self.view];
            }];
        }
            break;
        case 4: {
            AVPLiveStsSource *source = self.playerConfig.liveStsSource;
            if (self.templiveStsSource) { source = self.templiveStsSource; }
            [AlivcPlayVideoRequestManager getWithParameters:nil urlType:AVPUrlTypePlayerVideoLiveSts success:^(AVPDemoResponseModel *responseObject) {
                self.templiveStsSource = [[AVPLiveStsSource alloc] initWithUrl:self.templiveStsSource.url accessKeyId:responseObject.data.accessKeyId accessKeySecret:responseObject.data.accessKeySecret securityToken:responseObject.data.securityToken region:@"cn-shanghai" domain:self.templiveStsSource.domain app:self.templiveStsSource.app stream:self.templiveStsSource.stream];
                self.playerConfig.liveStsExpireTime = [AVPDemoServerManager getExpirTime:responseObject.data.expiration];
                [self.tableView reloadData];
                [AVPTool hudWithText:[@"刷新成功" localString] view:self.view];
            } failure:^(NSString *errorMsg) {
                [AVPTool hudWithText:errorMsg view:self.view];
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark keySource

- (NSArray *)sourceKeyArray {
    switch (self.sourceSelectView.selectIndex) {
        case 0:
            return @[@"url"];
        case 1:
            return @[@"vid",@"accessKeyId",@"accessKeySecret",@"securityToken",@"region",@"previewTime"];
        case 2:
            return @[@"vid",@"accessKeyId",@"accessKeySecret",@"securityToken",@"authInfo",@"region",@"playDomain",@"mtsHlsUriToken"];
        case 3:
            return @[@"vid",@"playAuth",@"region",@"previewTime"];
        case 4:
            return @[@"url",@"accessKeyId",@"accessKeySecret",@"securityToken",@"region",@"domain",@"app",@"stream"];
        default:
            return nil;
    }
}


#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.sourceSelectView.selectIndex == 0) {
        return self.sourceKeyArray.count;
    }
    return self.sourceKeyArray.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    if (indexPath.row == self.sourceKeyArray.count) {
        AlivcVideoPlayButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlivcVideoPlayButtonTableViewCell"];
        cell.callBack = ^{
            NSLog(@"点击事件");
            [weakSelf reloadStsConfig];
        };
        return cell;
    }
    
    AlivcVideoPlayTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlivcVideoPlayTextFieldTableViewCell"];
    cell.leaderText = self.sourceKeyArray[indexPath.row];
    if ([cell.leaderText isEqualToString:@"url"]) {
        cell.showScanButton = YES;
        cell.toScanCallBack = ^{
            AlivcVideoPlayScanViewController *vc = [[AlivcVideoPlayScanViewController alloc]init];
            vc.scanedTextCallBack = ^(NSString *text) {
                if(self.sourceSelectView.selectIndex==0){
                    weakSelf.tempUrlSource = [[AVPUrlSource alloc]urlWithString:text];
                }else if (self.sourceSelectView.selectIndex==4){
                    weakSelf.templiveStsSource.url = text;
                    if([text containsString:@"live-encrypt"]){
                        NSRange headerRange = [text rangeOfString:@"://"];
                            if (headerRange.length>0) {
                                text = [text substringFromIndex:headerRange.location+headerRange.length];
                            }
                            NSArray *arr = [text componentsSeparatedByString:@"/"];
                            if (arr.count==3) {
                                weakSelf.templiveStsSource.domain = arr[0];
                                weakSelf.templiveStsSource.app = arr[1];
                                text = arr[2];
                                NSRange range = [text rangeOfString:@"_"];
                                if (range.length>0) {
                                    text = [text substringToIndex:range.location];
                                    weakSelf.templiveStsSource.stream = text;
                                }
                            }
                        }
                    }
                [weakSelf.tableView reloadData];
            };
            [weakSelf.navigationController pushViewController:vc animated:YES];
        };
    }else {
        cell.showScanButton = NO;
    }
    
    cell.inputTextField.text = [self findSourceValueForKey:cell.leaderText];
    cell.callBack = ^(NSString *leaderText, NSString *changedText) {
        [weakSelf setSourceValue:changedText forKey:leaderText];
        NSLog(@"%@ %@",leaderText,changedText);
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.sourceKeyArray.count) {
        return 60;
    }
    return 88;
}

- (NSString *)findSourceValueForKey:(NSString *)key {
    switch (self.sourceSelectView.selectIndex) {
        case 0: {
            AVPUrlSource *source = self.playerConfig.urlSource;
            if (self.tempUrlSource) { source = self.tempUrlSource; }
            return source.playerUrl.absoluteString;
        }
        case 1: {
            AVPVidStsSource *source = self.playerConfig.vidStsSource;
            if (self.tempVidStsSource) { source = self.tempVidStsSource; }
            if ([key isEqualToString:@"previewTime"]) {
                NSData *jsonData = [source.playConfig dataUsingEncoding:NSUTF8StringEncoding];
                if (jsonData) {
                    NSDictionary *playConfigDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                    NSString *previewTime = [playConfigDic[@"PreviewTime"] stringValue];
                    return previewTime;
                } else {
                    return nil;
                }
            }else {
                return [source valueForKey:key];
            }
        }
        case 2: {
            AVPVidMpsSource *source = self.playerConfig.vidMpsSource;
            if (self.tempVidMpsSource) { source = self.tempVidMpsSource; }
            if ([key isEqualToString:@"accessKeyId"]) {
                key = @"accId";
            }else if ([key isEqualToString:@"accessKeySecret"]) {
                key = @"accSecret";
            }else if ([key isEqualToString:@"securityToken"]) {
                key = @"stsToken";
            }
            return [source valueForKey:key];
        }
        case 3: {
            AVPVidAuthSource *source = self.playerConfig.vidAuthSource;
            if (self.tempVidAuthSource) { source = self.tempVidAuthSource; }
            if ([key isEqualToString:@"previewTime"]) {
                NSData *jsonData = [source.playConfig dataUsingEncoding:NSUTF8StringEncoding];
                if (jsonData) {
                    NSDictionary *playConfigDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                    NSString *previewTime = [playConfigDic[@"PreviewTime"] stringValue];
                    return previewTime;
                } else {
                    return nil;
                }
            }else {
                return [source valueForKey:key];
            }
        }
        case 4: {
            AVPLiveStsSource *source = self.playerConfig.liveStsSource;
            if (self.templiveStsSource) { source = self.templiveStsSource; }
            if ([key isEqualToString:@"previewTime"]) {
                NSData *jsonData = [source.stream dataUsingEncoding:NSUTF8StringEncoding];
                if (jsonData) {
                    NSDictionary *playConfigDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                    NSString *previewTime = [playConfigDic[@"PreviewTime"] stringValue];
                    return previewTime;
                } else {
                    return nil;
                }
            }else {
                return [source valueForKey:key];
            }
        }
        default:
            return nil;
    }
}

- (void)setSourceValue:(NSString *)value forKey:(NSString *)key {
    if (![self.sourceKeyArray containsObject:key]) { return; }
    switch (self.sourceSelectView.selectIndex) {
        case 0: {
            self.tempUrlSource = [[AVPUrlSource alloc]urlWithString:value];
        }
            break;
        case 1: {
            if (!self.tempVidStsSource) {
                self.tempVidStsSource = [AlivcVideoPlayPlayerConfig copyStsSourceWithSource:self.playerConfig.vidStsSource];
            }
            if ([key isEqualToString:@"previewTime"]) {
                int previewTime = [value intValue];
                VidPlayerConfigGenerator* vpGenerator = [[VidPlayerConfigGenerator alloc] init];
                [vpGenerator setPreviewTime:previewTime];
                value = [vpGenerator generatePlayerConfig];
                key = @"playConfig";
            }
            [self.tempVidStsSource setValue:value forKey:key];
        }
            break;
        case 2: {
            if (!self.tempVidMpsSource) {
                self.tempVidMpsSource = [AlivcVideoPlayPlayerConfig copyMpsSourceWithSource:self.playerConfig.vidMpsSource];
            }
            if ([key isEqualToString:@"accessKeyId"]) {
                key = @"accId";
            }else if ([key isEqualToString:@"accessKeySecret"]) {
                key = @"accSecret";
            }else if ([key isEqualToString:@"securityToken"]) {
                key = @"stsToken";
            }
            [self.tempVidMpsSource setValue:value forKey:key];
        }
            break;
        case 3: {
            if (!self.tempVidAuthSource) {
                self.tempVidAuthSource = [AlivcVideoPlayPlayerConfig copyAuthSourceWithSource:self.playerConfig.vidAuthSource];
            }
            if ([key isEqualToString:@"previewTime"]) {
                int previewTime = [value intValue];
                VidPlayerConfigGenerator* vpGenerator = [[VidPlayerConfigGenerator alloc] init];
                [vpGenerator setPreviewTime:previewTime];
                value = [vpGenerator generatePlayerConfig];
                key = @"playConfig";
            }
            [self.tempVidAuthSource setValue:value forKey:key];
        }
            break;
        case 4: {
            if (!self.templiveStsSource) {
                self.templiveStsSource = [AlivcVideoPlayPlayerConfig copyLiveStsSourceWithSource:self.playerConfig.liveStsSource];
            }
            if ([key isEqualToString:@"previewTime"]) {
                int previewTime = [value intValue];
                VidPlayerConfigGenerator* vpGenerator = [[VidPlayerConfigGenerator alloc] init];
                [vpGenerator setPreviewTime:previewTime];
                value = [vpGenerator generatePlayerConfig];
                key = @"playConfig";
            }
            [self.templiveStsSource setValue:value forKey:key];
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
