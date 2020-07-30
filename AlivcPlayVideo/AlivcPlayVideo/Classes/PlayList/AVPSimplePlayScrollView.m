//
//  AVPSimplePlayScrollView.m
//  AliPlayerDemo
//
//  Created by 郦立 on 2019/1/9.
//  Copyright © 2019年 com.alibaba. All rights reserved.
//

#import "AVPSimplePlayScrollView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MJRefresh.h"

@interface AVPSimplePlayScrollView()<UIScrollViewDelegate>

@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)NSMutableArray *imageViewArray;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)UIView *playImageContainView;
@property (nonatomic,strong)UIImageView *playImageView;
@property (nonatomic,assign)BOOL playerIsStop;
@property (nonatomic,assign)BOOL hasLoad;

@end

@implementation AVPSimplePlayScrollView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame dataArray:(NSArray <AVPDemoResponseVideoListModel *>*)array {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.imageViewArray = [NSMutableArray array];
        self.dataArray = [NSMutableArray array];
        
        self.scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        [self addSubview:self.scrollView];
        if (@available(iOS 11.0, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        __weak typeof(self)weakSelf = self;
        self.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            if ([weakSelf.delegate respondsToSelector:@selector(AVPSimplePlayScrollViewHeaderRefreshing:)]) {
                [weakSelf.delegate AVPSimplePlayScrollViewHeaderRefreshing:weakSelf];
            }
        }];
        
        [self addDataArray:array];
        
        self.playView = [[UIView alloc]initWithFrame:self.scrollView.bounds];
        [self.scrollView addSubview:self.playView];
        self.playView.hidden = YES;
                
        CGFloat width = 70;
        self.playImageContainView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, width)];
        self.playImageContainView.layer.cornerRadius = width / 2;
        self.playImageContainView.clipsToBounds = YES;
        self.playImageContainView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        self.playImageContainView.center = self.playView.center;
        [self.playView addSubview:self.playImageContainView];
        self.playImageView = [[UIImageView alloc]initWithImage:[AlivcImage imageInBasicVideoNamed:@"timeShift_play"]];
        self.playImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.playView addSubview:self.playImageView];
        self.playImageView.center = self.playView.center;
        self.showPlayImage = NO;
        
        [self addTapGesture];
        
        UIButton *backButton = [[UIButton alloc]init];
        [backButton addTarget:self action:@selector(backButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setImage:[AlivcImage imageInBasicVideoNamed:@"avcBackIcon"] forState:UIControlStateNormal];
        backButton.frame = CGRectMake(0, 0, 40, 40);
        backButton.center = CGPointMake(15 + backButton.frame.size.width / 2, 20 + 22);
        [self addSubview:backButton];
        
        // 添加检测app进入前台的观察者
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name: UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)applicationDidBecomeActive {
    [self scrollViewDidEndDecelerating:self.scrollView];
}

- (void)backButtonTouched:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(AVPSimplePlayScrollViewBackButtonTouched:)]) {
        [self.delegate AVPSimplePlayScrollViewBackButtonTouched:self];
    }
}

- (void)addTapGesture {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]init];
    tapGesture.numberOfTapsRequired = 1;
    [tapGesture addTarget:self action:@selector(tap)];
    [self addGestureRecognizer:tapGesture];
}

- (void)tap {
    if ([self.delegate respondsToSelector:@selector(AVPSimplePlayScrollViewTapGestureAction:)]) {
        [self.delegate AVPSimplePlayScrollViewTapGestureAction:self];
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    self.scrollView.contentOffset = CGPointMake(0, self.frame.size.height*currentIndex);
    [self resetPlayViewFrame];
}

- (void)resetPlayViewFrame {
    AVPDemoResponseVideoListModel *lastModel = self.dataArray.lastObject;
    CGFloat maxOffsetY = self.scrollView.frame.size.height * lastModel.index;
    if (self.scrollView.contentOffset.y < 0) {
        self.playView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    }else if (self.scrollView.contentOffset.y > maxOffsetY ) {
        self.playView.frame = CGRectMake(0, maxOffsetY, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    }else {
        self.playView.frame = CGRectMake(0, self.scrollView.contentOffset.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    }
}

- (void)setShowPlayImage:(BOOL)showPlayImage {
    _showPlayImage = showPlayImage;
    self.playImageView.hidden = !showPlayImage;
    self.playImageContainView.hidden = !showPlayImage;
}

- (void)showPlayView {
    self.playView.hidden = NO;
    [self.playView bringSubviewToFront:self.playImageContainView];
    [self.playView bringSubviewToFront:self.playImageView];
}

- (void)addDataArray:(NSArray <AVPDemoResponseVideoListModel *>*)array {
    AVPDemoResponseVideoListModel *lastModel = self.dataArray.lastObject;
    int lastIndex = -1;
    if (lastModel) { lastIndex = (int)lastModel.index; }
    AVPDemoResponseVideoListModel *firstMode = array.firstObject;
    if (firstMode.index > lastIndex) {
        [self.dataArray addObjectsFromArray:array];
        CGFloat selfWidth = self.frame.size.width;
        CGFloat selfHeight = self.frame.size.height;
        self.scrollView.contentSize = CGSizeMake(selfWidth, self.scrollView.contentSize.height+selfHeight *array.count);
        for (AVPDemoResponseVideoListModel *model in array) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, selfHeight*model.index, selfWidth, selfHeight)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            if (model.firstFrameUrl.length > 0) {
                [imageView sd_setImageWithURL:[NSURL URLWithString:model.firstFrameUrl]];
            }else {
                [imageView sd_setImageWithURL:[NSURL URLWithString:model.coverUrl]];
            }
            imageView.tag = model.index + 100;
            [self.scrollView addSubview:imageView];
            [self.imageViewArray addObject:imageView];
            [self.scrollView sendSubviewToBack:imageView];
        }
    }
}

- (void)removeDataArray:(NSArray <AVPDemoResponseVideoListModel *>*)array {
    for (AVPDemoResponseVideoListModel *model in array) {
        UIImageView *imageView = [self findImageViewFromIndex:model.index + 100];
        if (imageView) {
            [self.dataArray removeObject:model];
            [imageView removeFromSuperview];
            [self.imageViewArray removeObject:imageView];
        }
    }
    self.scrollView.contentInset = UIEdgeInsetsMake(self.scrollView.contentInset.top - array.count * self.frame.size.height, 0, 0, 0);
}

- (UIImageView *)findImageViewFromIndex:(NSInteger)index {
    for (UIImageView *imageView in self.imageViewArray) {
        if (imageView.tag == index) {
            return imageView;
        }
    }
    return nil;
}

- (void)endRefreshingAndReset:(BOOL)reset {
    if (reset) {
        self.scrollView.contentSize = CGSizeZero;
        self.scrollView.contentOffset = CGPointZero;
    }
    [self.scrollView.mj_header endRefreshing];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat indexFloat = scrollView.contentOffset.y/self.frame.size.height;
    NSInteger index = (NSInteger)indexFloat;
    AVPDemoResponseVideoListModel *firstModel = self.dataArray.firstObject;
    AVPDemoResponseVideoListModel *lastModel = self.dataArray.lastObject;
    if (index < firstModel.index || index > lastModel.index) {
        return;
    }
    if (index != self.currentIndex || self.playerIsStop) {
        self.playView.hidden = YES;
        self.playerIsStop = NO;
        [self resetPlayViewFrame];
        if (index - self.currentIndex == 1) {
            if ([self.delegate respondsToSelector:@selector(AVPSimplePlayScrollView:motoNextAtIndex:)]) {
                [self.delegate AVPSimplePlayScrollView:self motoNextAtIndex:index];
            }
        }else if (self.currentIndex - index == 1){
            if ([self.delegate respondsToSelector:@selector(AVPSimplePlayScrollView:motoPreAtIndex:)]) {
                [self.delegate AVPSimplePlayScrollView:self motoPreAtIndex:index];
            }
        }else {
            if ([self.delegate respondsToSelector:@selector(AVPSimplePlayScrollView:scrollViewDidEndDeceleratingAtIndex:)]) {
                [self.delegate AVPSimplePlayScrollView:self scrollViewDidEndDeceleratingAtIndex:index];
            }
        }
        _currentIndex = index;
        //还有3条进行回调,剩余4-1=3条
        AVPDemoResponseVideoListModel *lastModel = self.dataArray.lastObject;
        if (lastModel.index - index < 4) {
            if ([self.delegate respondsToSelector:@selector(AVPSimplePlayScrollViewNeedNewData:)]) {
                [self.delegate AVPSimplePlayScrollViewNeedNewData:self];
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.hasLoad) {
        self.hasLoad = YES;
        return;
    }
    if (ABS(scrollView.contentOffset.y - self.playView.frame.origin.y)>self.frame.size.height) {
        if (self.playerIsStop == NO) {
            self.playerIsStop = YES;
            if ([self.delegate respondsToSelector:@selector(AVPSimplePlayScrollViewScrollOut:)]) {
                [self.delegate AVPSimplePlayScrollViewScrollOut:self];
            }
        }
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView; {
    return NO;
}

@end








