//
//  Created by ToT on 2019/12/4.
//  Copyright © 2019 aliyun. All rights reserved.
//

#import "AlivcVideoPlayTimeShiftView.h"
#import "NSString+AlivcHelper.h"

@interface AlivcVideoPlayTimeShiftView()

@property (nonatomic,strong)UIButton *playButton;
@property (nonatomic,strong)UILabel *liveLabel;
@property (nonatomic,strong)UIProgressView *progressView;
@property (nonatomic,strong)UISlider *slider;
@property (nonatomic,strong)UIButton *fullScreenButton;
@property (nonatomic,strong)UIView *lineView;
@property (nonatomic,assign)BOOL isTouchDown;
@property (nonatomic,assign)CGRect currentFrame;
@property (nonatomic,assign)BOOL isFullScreen;
@property (nonatomic,strong)UILabel *leftTimeLabel;
@property (nonatomic,strong)UILabel *rightTimeLabel;
@property (nonatomic,strong)UIActivityIndicatorView *loadingView;
@property (nonatomic,strong)UIButton *retryButton;

@end

@implementation AlivcVideoPlayTimeShiftView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.currentFrame = frame;
        self.backgroundColor = [UIColor blackColor];
        
        self.livePlayView = [[UIView alloc]init];
        [self addSubview:self.livePlayView];
        
        self.playButton = [[UIButton alloc]init];
        [self.playButton addTarget:self action:@selector(playButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playButton];
        self.isPlaying = NO;
        
        self.liveLabel = [[UILabel alloc] init];
        self.liveLabel.textAlignment = NSTextAlignmentCenter;
        [self.liveLabel setFont:[UIFont systemFontOfSize:12]];
        [self.liveLabel setTextColor:[UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1]];
        NSString *liveStringPoint = @"•";
        NSString *liveString = @" Live";
        NSString *time = [NSString stringWithFormat:@"%@%@", liveStringPoint, liveString];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:time];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, liveStringPoint.length)];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(liveStringPoint.length, liveString.length)];
        self.liveLabel.attributedText = str;
        [self addSubview:self.liveLabel];
        
        self.progressView = [[UIProgressView alloc]init];
        self.progressView.trackTintColor = [UIColor blackColor];
        self.progressView.progressTintColor = [UIColor whiteColor];
        [self addSubview:self.progressView];
                
        self.slider = [[UISlider alloc] init];
        self.slider.minimumTrackTintColor = [UIColor colorWithRed:68/255.0 green:173/255.0 blue:236/255.0 alpha:1];
        self.slider.maximumTrackTintColor = [UIColor whiteColor];
        self.slider.value = 0.0f;
        self.slider.continuous = NO;
        [self.slider setThumbImage:[AlivcImage imageInBasicVideoNamed:@"timeShift_bulePoint"] forState:UIControlStateNormal];
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.slider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
        [self.slider addTarget:self action:@selector(sliderTouchUpInSide:) forControlEvents:UIControlEventTouchUpInside];
        [self.slider addTarget:self action:@selector(sliderTouchUpOutSide:) forControlEvents:UIControlEventTouchUpOutside];
        [self addSubview:self.slider];
        
        self.leftTimeLabel = [[UILabel alloc]init];
        self.leftTimeLabel.font = [UIFont systemFontOfSize:14.0f];
        self.leftTimeLabel.textColor = [UIColor whiteColor];
        self.leftTimeLabel.textAlignment = NSTextAlignmentLeft;
        self.leftTimeLabel.text = @"00:00:00";
        [self addSubview:self.leftTimeLabel];
        
        self.rightTimeLabel = [[UILabel alloc]init];
        self.rightTimeLabel.font = [UIFont systemFontOfSize:14.0f];
        self.rightTimeLabel.textColor = [UIColor whiteColor];
        self.rightTimeLabel.textAlignment = NSTextAlignmentRight;
        self.rightTimeLabel.text = @"00:00:00";
        [self addSubview:self.rightTimeLabel];
        
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = [UIColor redColor];
        [self.slider addSubview:self.lineView];
        
        self.fullScreenButton = [[UIButton alloc] init];
        [self.fullScreenButton setImage:[AlivcImage imageInBasicVideoNamed:@"alivc_fullScreen"] forState:UIControlStateNormal];
        [self.fullScreenButton addTarget:self action:@selector(fullScreenButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.fullScreenButton];
        
        self.loadingView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.loadingView.hidden = YES;
        self.loadingView.color = [UIColor whiteColor];
        [self addSubview:self.loadingView];
        
        self.retryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 82, 30)];
        [self.retryButton setBackgroundImage:[AlivcImage imageInBasicVideoNamed:@"al_error_btn_blue"] forState:UIControlStateNormal];
        [self.retryButton setImage:[AlivcImage imageInBasicVideoNamed:@"al_over_btn_refresh_blue"] forState:UIControlStateNormal];
        self.retryButton.imageEdgeInsets = UIEdgeInsetsMake(0, -12, 0, 0);
        self.retryButton.titleLabel.font = [UIFont systemFontOfSize:14];
        self.retryButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.retryButton setTitleColor:[UIColor colorWithRed:(0 / 255.0) green:(193 / 255.0) blue:(222 / 255.0) alpha:1] forState:UIControlStateNormal];
        self.retryButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -12);
        [self.retryButton setTitle:[@"重试" localString] forState:UIControlStateNormal];
        [self.retryButton addTarget:self action:@selector(retryButtonAction) forControlEvents:UIControlEventTouchUpInside];
        self.retryButton.hidden = YES;
        [self addSubview:self.retryButton];
        
        UIButton *backButton = [[UIButton alloc]init];
        [backButton addTarget:self action:@selector(backButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setImage:[AlivcImage imageInBasicVideoNamed:@"avcBackIcon"] forState:UIControlStateNormal];
        backButton.frame = CGRectMake(0, 0, 40, 40);
        backButton.center = CGPointMake(15 + backButton.frame.size.width / 2, 20 + 22);
        [self addSubview:backButton];
        
        //屏幕旋转通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)retryButtonAction {
    if ([self.delegate respondsToSelector:@selector(retryButtonActionInTimeShiftView:)]) {
        [self.delegate retryButtonActionInTimeShiftView:self];
    }
}

- (void)backButtonTouched:(UIButton *)sender {
    if (self.isFullScreen) {
        self.isFullScreen = NO;
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        [self layoutSubviews];
    }else {
        if ([self.delegate respondsToSelector:@selector(backButtonTouchedInTimeShiftView:)]) {
            [self.delegate backButtonTouchedInTimeShiftView:self];
        }
    }
}

- (void)deviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        self.isFullScreen = YES;
    }else {
        self.isFullScreen = NO;
    }
    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.isFullScreen) {
        self.frame = [UIScreen mainScreen].bounds;
    }else {
        self.frame = self.currentFrame;
    }
    
    self.livePlayView.frame = self.bounds;
    self.playButton.frame = CGRectMake(20, self.frame.size.height-40, 40, 40);
    self.liveLabel.frame = CGRectMake(65, self.frame.size.height-40, 40, 40);
    NSInteger leftEdge = 120;
    NSInteger rightEdge = 60;
    self.progressView.frame = CGRectMake(leftEdge+2, self.frame.size.height-21, self.frame.size.width-leftEdge-rightEdge-4, 2);
    self.slider.frame = CGRectMake(leftEdge, self.frame.size.height-40, self.frame.size.width-leftEdge-rightEdge, 40);
    self.lineView.frame = CGRectMake(0, 10, 2, 20);
    [self setLineViewValue:self.progressView.progress];
    self.fullScreenButton.frame = CGRectMake(self.frame.size.width-50, self.frame.size.height-40, 40, 40);
    NSInteger timeLabelEdge = 30;
    self.leftTimeLabel.frame = CGRectMake(timeLabelEdge, self.frame.size.height-60, 100, 20);
    self.rightTimeLabel.frame = CGRectMake(self.frame.size.width-100-timeLabelEdge, self.frame.size.height-60, 100, 20);
    self.loadingView.center = self.center;
    self.retryButton.center = self.center;
}

- (void)playButtonAction {
    if ([self.delegate respondsToSelector:@selector(playButtonActionInTimeShiftView:)]) {
        [self.delegate playButtonActionInTimeShiftView:self];
    }
}

- (void)sliderValueChanged:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(timeShiftView:sliderValueChanged:)]) {
        [self.delegate timeShiftView:self sliderValueChanged:sender.value];
    }
}

- (void)sliderTouchDown:(UISlider*)sender{
    self.isTouchDown = YES;
}

- (void)sliderTouchUpInSide:(UISlider*)sender{
    self.isTouchDown = NO;
}

- (void)sliderTouchUpOutSide:(UISlider*)sender{
    self.isTouchDown = NO;
}

- (void)fullScreenButtonAction {
    self.isFullScreen = !self.isFullScreen;
    if (self.isFullScreen) {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    }else {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    }
    [self layoutSubviews];
    if ([self.delegate respondsToSelector:@selector(timeShiftView:fullScreenChanged:)]) {
        [self.delegate timeShiftView:self fullScreenChanged:self.isFullScreen];
    }
}

- (void)setIsPlaying:(BOOL)isPlaying {
    _isPlaying = isPlaying;
    if (isPlaying) {
        [self.playButton setImage:[AlivcImage imageInBasicVideoNamed:@"timeShift_pause"] forState:UIControlStateNormal];
    }else {
        [self.playButton setImage:[AlivcImage imageInBasicVideoNamed:@"timeShift_play"] forState:UIControlStateNormal];
    }
}

- (void)setSliderValue:(CGFloat)vaule {
    if (!self.isTouchDown) { [self.slider setValue:vaule animated:YES]; }
}

- (void)setProgressValue:(CGFloat)vaule {
    [self.progressView setProgress:vaule];
    [self setLineViewValue:vaule];
}

- (void)setLineViewValue:(CGFloat)vaule {
    self.lineView.frame = CGRectMake(vaule*self.slider.frame.size.width, self.lineView.frame.origin.y, self.lineView.frame.size.width, self.lineView.frame.size.height);
}

- (void)setCurrentPlayTime:(NSTimeInterval)currentPlayTime {
    _currentPlayTime = currentPlayTime;
    self.leftTimeLabel.text = [self stringFromDate:currentPlayTime];
}

- (void)setTempTotalTime:(NSTimeInterval)tempTotalTime {
    _tempTotalTime = tempTotalTime;
    self.rightTimeLabel.text = [self stringFromDate:tempTotalTime];
}

- (NSString *)stringFromDate:(NSTimeInterval)num{
    NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:num];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc]init];
    [dateformatter setDateFormat:@"HH:mm:ss"];
    return [dateformatter stringFromDate:date1];
}

- (void)hiddenLoadingView {
    [self.loadingView stopAnimating];
    self.loadingView.hidden = YES;
}

- (void)showLoadingView {
    [self.loadingView startAnimating];
    self.loadingView.hidden = NO;
}

- (void)hiddenRetryButton {
    self.retryButton.hidden = YES;
}

- (void)showRetryButton {
    self.retryButton.hidden = NO;
}

@end
