//
//  Created by ToT on 2019/12/4.
//  Copyright © 2019 aliyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlivcVideoPlayTimeShiftView;

@protocol AlivcVideoPlayTimeShiftViewDelegate <NSObject>

- (void)playButtonActionInTimeShiftView:(AlivcVideoPlayTimeShiftView *)timeShiftView;

- (void)retryButtonActionInTimeShiftView:(AlivcVideoPlayTimeShiftView *)timeShiftView;

- (void)timeShiftView:(AlivcVideoPlayTimeShiftView *)timeShiftView sliderValueChanged:(CGFloat)value;

- (void)timeShiftView:(AlivcVideoPlayTimeShiftView *)timeShiftView fullScreenChanged:(BOOL)isfullScreen;

- (void)backButtonTouchedInTimeShiftView:(AlivcVideoPlayTimeShiftView *)timeShiftView;

@optional



@end


@interface AlivcVideoPlayTimeShiftView : UIView

@property (nonatomic,weak)id <AlivcVideoPlayTimeShiftViewDelegate>delegate;
@property (nonatomic,strong)UIView *livePlayView;
@property (nonatomic,assign)BOOL isPlaying;
@property (nonatomic,assign)NSTimeInterval currentPlayTime;
@property (nonatomic,assign)NSTimeInterval tempTotalTime;

- (void)setSliderValue:(CGFloat)vaule;
- (void)setProgressValue:(CGFloat)vaule;
- (void)hiddenLoadingView;
- (void)showLoadingView;
- (void)hiddenRetryButton;
- (void)showRetryButton;

@end


