//
//  AVPSimplePlayScrollView.h
//  AliPlayerDemo
//
//  Created by 郦立 on 2019/1/9.
//  Copyright © 2019年 com.alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVPDemoResponseModel.h"

@class AVPSimplePlayScrollView;

@protocol AVPSimplePlayScrollViewDelegate <NSObject>

@optional

/**
 返回按钮点击事件

 @param simplePlayScrollView simplePlayScrollView
 */
- (void)AVPSimplePlayScrollViewBackButtonTouched:(AVPSimplePlayScrollView *)simplePlayScrollView;

/**
 全屏点击事件

 @param simplePlayScrollView simplePlayScrollView
 */
- (void)AVPSimplePlayScrollViewTapGestureAction:(AVPSimplePlayScrollView *)simplePlayScrollView;

/**
 滚动事件,移动位置超过一个
 
 @param simplePlayScrollView simplePlayScrollView
 @param index 移动到第几个
 */
- (void)AVPSimplePlayScrollView:(AVPSimplePlayScrollView *)simplePlayScrollView scrollViewDidEndDeceleratingAtIndex:(NSInteger)index;

/**
 移动到下一个

 @param simplePlayScrollView simplePlayScrollView
 @param index 第几个
 */
- (void)AVPSimplePlayScrollView:(AVPSimplePlayScrollView *)simplePlayScrollView motoNextAtIndex:(NSInteger)index;

/**
 移动到上一个

 @param simplePlayScrollView simplePlayScrollView
 @param index 第几个
 */
- (void)AVPSimplePlayScrollView:(AVPSimplePlayScrollView *)simplePlayScrollView motoPreAtIndex:(NSInteger)index;

/**
 当前播放视图移除屏幕

 @param simplePlayScrollView simplePlayScrollView
 */
- (void)AVPSimplePlayScrollViewScrollOut:(AVPSimplePlayScrollView *)simplePlayScrollView;

/**
 需要新数据回调

 @param simplePlayScrollView simplePlayScrollView
 */
- (void)AVPSimplePlayScrollViewNeedNewData:(AVPSimplePlayScrollView *)simplePlayScrollView;

/**
 下拉刷新回调

 @param simplePlayScrollView simplePlayScrollView
 */
- (void)AVPSimplePlayScrollViewHeaderRefreshing:(AVPSimplePlayScrollView *)simplePlayScrollView;

@end

@interface AVPSimplePlayScrollView : UIView

/**
 代理
 */
@property (nonatomic,weak) id <AVPSimplePlayScrollViewDelegate> delegate;

/**
 滚动视图当前位置
 */
@property (nonatomic,assign)NSInteger currentIndex;

/**
 是否显示中间的播放按钮
 */
@property (nonatomic,assign)BOOL showPlayImage;

/**
 播放的视图
 */
@property (nonatomic,strong)UIView *playView;

/**
 初始化方法

 @param frame frame
 @param array 内容数组
 @return simplePlayScrollView
 */
- (instancetype)initWithFrame:(CGRect)frame dataArray:(NSArray <AVPDemoResponseVideoListModel *>*)array;

/**
 展示播放视图
 */
- (void)showPlayView;

/**
 添加数据源

 @param array 数据源
 */
- (void)addDataArray:(NSArray <AVPDemoResponseVideoListModel *>*)array;

/**
 移除数据源
 
 @param array 数据源
 */
- (void)removeDataArray:(NSArray <AVPDemoResponseVideoListModel *>*)array;

/**
结束刷新
 
@param reset 是否重置界面
*/
- (void)endRefreshingAndReset:(BOOL)reset;

@end






