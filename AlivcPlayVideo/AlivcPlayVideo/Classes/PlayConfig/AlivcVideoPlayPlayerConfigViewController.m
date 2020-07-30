//
//  AlivcVideoPlayPlayerConfigViewController.m
//  AlivcLongVideo
//
//  Created by ToT on 2019/12/17.
//

#import "AlivcVideoPlayPlayerConfigViewController.h"
#import "AlivcUIConfig.h"
#import "AlivcVideoPlayTextFieldTableViewCell.h"
#import "AlivcVideoPlaySwitchTableViewCell.h"
#import "AVPTool.h"
#import "NSString+AlivcHelper.h"

@interface AlivcVideoPlayPlayerConfigViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSArray *allTitleArray;
@property (nonatomic,strong)NSArray *allKeyArray;
@property (nonatomic,strong)NSArray *switchKeyArray;
@property (nonatomic,strong)AVPConfig *tempConfig;
@property (nonatomic,strong)AVPCacheConfig *tempCacheConfig;

@end

@implementation AlivcVideoPlayPlayerConfigViewController

- (void)dealloc {
    NSLog(@"AlivcVideoPlayPlayerConfigViewController释放了");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
    self.navigationItem.title = [@"播放参数设置" localString];
    
    [self initConfigSource];
    [self addViews];
    
    if ([self.playerConfig.urlSource.playerUrl.absoluteString hasPrefix:@"artc"]) {
        [self setTempConfigWithValue:@"1000" forKey:@"maxDelayTime"];
//        [self setTempConfigWithValue:@"150" forKey:@"maxBufferDuration"];
        [self setTempConfigWithValue:@"10" forKey:@"highBufferDuration"];
        [self setTempConfigWithValue:@"10" forKey:@"startBufferDuration"];
    }
}

- (void)addViews {

    NSInteger leftEdge = 30;
    NSInteger viewWidth = self.view.frame.size.width - leftEdge * 2;
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(leftEdge, leftEdge, viewWidth, self.view.frame.size.height- 40 - 44-  SafeBottom-SafeTop-leftEdge*2)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView registerClass:[AlivcVideoPlayTextFieldTableViewCell class] forCellReuseIdentifier:@"AlivcVideoPlayTextFieldTableViewCell"];
    [self.tableView registerClass:[AlivcVideoPlaySwitchTableViewCell class] forCellReuseIdentifier:@"AlivcVideoPlaySwitchTableViewCell"];
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
    
    if (self.tempConfig) { self.playerConfig.config = self.tempConfig; }
    if (self.tempCacheConfig) { self.playerConfig.cacheConfig = self.tempCacheConfig; }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetConfig:(UIButton *)sender {
    NSLog(@"resetConfig");
    
    self.tempConfig = [[AVPConfig alloc]init];
    self.tempCacheConfig = [[AVPCacheConfig alloc]init];
    self.tempCacheConfig.maxDuration = 100;
    self.tempCacheConfig.maxSizeMB = 200;
    [self.tableView reloadData];
    [AVPTool hudWithText:[@"恢复成功" localString] view:self.view];
    return;
}

#pragma mark configSource

- (void)initConfigSource {
    self.allTitleArray = @[[@"启播" localString],
                           [@"卡顿恢复" localString],
                           [@"最大缓存值" localString],
                           [@"直播最大延迟" localString],
                           [@"网络超时" localString],
                           [@"网络重试次数" localString],
                           [@"probe大小" localString],
                           [@"请求referer" localString],
                           [@"httpProxy代理" localString],
                           [@"停止隐藏最后帧" localString],
                           [@"开启SEI" localString],
                           [@"缓存最大长度" localString],
                           [@"缓存最大空间" localString],
                           [@"开启自定义缓存" localString]];
    self.allKeyArray = @[@"startBufferDuration",
                         @"highBufferDuration",
                         @"maxBufferDuration",
                         @"maxDelayTime",
                         @"networkTimeout",
                         @"networkRetryCount",
                         @"maxProbeSize",
                         @"referer",
                         @"httpProxy",
                         @"clearShowWhenStop",
                         @"enableSEI",
                         @"maxDuration",
                         @"maxSizeMB",
                         @"enable"];
    self.switchKeyArray = @[@"clearShowWhenStop",
                            @"enableSEI",
                            @"enable"];
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allKeyArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self)weakself = self;
    if ([self indexIsSwitchCell:indexPath.row]) {
        AlivcVideoPlaySwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlivcVideoPlaySwitchTableViewCell"];
        cell.leaderText = self.allTitleArray[indexPath.row];
        cell.leaderTextKey = self.allKeyArray[indexPath.row];
        cell.insideSwitch.on = [self findSourceBoolValueForKey:cell.leaderTextKey];
        cell.callBack = ^(NSString *leaderText, NSString *leaderTextKey, BOOL isOn) {
            NSLog(@"%@ %@ %d",leaderText,leaderTextKey,isOn);
            [weakself setSourceBoolValue:isOn forKey:leaderTextKey];
        };
        return cell;
    }else {
        AlivcVideoPlayTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlivcVideoPlayTextFieldTableViewCell"];
        cell.leaderText = self.allTitleArray[indexPath.row];
        cell.inputTextField.text = [self findSourceValueForKey:cell.leaderText];
        cell.callBack = ^(NSString *leaderText, NSString *changedText) {
            NSLog(@"%@ %@",leaderText,changedText);
            [weakself setSourceValue:changedText forKey:leaderText];
        };
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self indexIsSwitchCell:indexPath.row]) {
        return 50;
    }else {
        return 88;
    }
}

- (BOOL)indexIsSwitchCell:(NSInteger)index {
    NSString *title = self.allKeyArray[index];
    if ([self.switchKeyArray containsObject:title]) {
        return YES;
    }
    return NO;
}

- (BOOL)findSourceBoolValueForKey:(NSString *)key {
    NSInteger index = [self.allKeyArray indexOfObject:key];
    if (index < 11) {
        AVPConfig *config= self.playerConfig.config;
        if (self.tempConfig) { config = self.tempConfig; }
        BOOL backBool = [[config valueForKey:key] boolValue];
        return backBool;
    }else {
        AVPCacheConfig *cacheconfig= self.playerConfig.cacheConfig;
        if (self.tempCacheConfig) { cacheconfig = self.tempCacheConfig; }
        BOOL backBool = [[cacheconfig valueForKey:key] boolValue];
        return backBool;
    }
}

- (void)setSourceBoolValue:(BOOL)isOn forKey:(NSString *)key {
    NSInteger index = [self.allKeyArray indexOfObject:key];
    if (index < 11) {
        if (!self.tempConfig) {
            self.tempConfig = [AlivcVideoPlayPlayerConfig copyConfigWithConfig:self.playerConfig.config];
        }
        [self.tempConfig setValue:@(isOn) forKey:key];
    }else {
        if (!self.tempCacheConfig) {
            self.tempCacheConfig = [AlivcVideoPlayPlayerConfig copyCacheConfigWithConfig:self.playerConfig.cacheConfig];
        }
        [self.tempCacheConfig setValue:@(isOn) forKey:key];
    }
}

- (NSString *)findSourceValueForKey:(NSString *)key {
    NSInteger index = [self.allTitleArray indexOfObject:key];
    key = self.allKeyArray[index];
    if (index < 11) {
        AVPConfig *config= self.playerConfig.config;
        if (self.tempConfig) { config = self.tempConfig; }
        NSArray *stringKeyArray = @[@"referer",@"userAgent",@"httpProxy"];
        if ([stringKeyArray containsObject:key]) {
            return [config valueForKey:key];
        }else {
            NSString *backString = [[config valueForKey:key] stringValue];
            return backString;
        }
    }else {
        AVPCacheConfig *cacheconfig= self.playerConfig.cacheConfig;
        if (self.tempCacheConfig) { cacheconfig = self.tempCacheConfig; }
        NSString *backString = [[cacheconfig valueForKey:key] stringValue];
        return backString;
    }
}

- (void)setSourceValue:(NSString *)value forKey:(NSString *)key {
    NSInteger index = [self.allTitleArray indexOfObject:key];
    key = self.allKeyArray[index];
    if (index < 11) {
        [self setTempConfigWithValue:value forKey:key];
    }else {
        if (!self.tempCacheConfig) {
            self.tempCacheConfig = [AlivcVideoPlayPlayerConfig copyCacheConfigWithConfig:self.playerConfig.cacheConfig];
        }
        [self.tempCacheConfig setValue:value forKey:key];
    }
}

-(void)setTempConfigWithValue:(id)value forKey:(NSString*)key{
    if (!self.tempConfig) {
        self.tempConfig = [AlivcVideoPlayPlayerConfig copyConfigWithConfig:self.playerConfig.config];
    }
    [self.tempConfig setValue:value forKey:key];
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
