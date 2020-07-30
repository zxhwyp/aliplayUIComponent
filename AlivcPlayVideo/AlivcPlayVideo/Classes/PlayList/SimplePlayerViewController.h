//
//  SimplePlayerViewController.h
//  AliPlayerDemo
//
//  Created by 郦立 on 2019/1/9.
//  Copyright © 2019年 com.alibaba. All rights reserved.
//

#import <AliyunPlayer/AliyunPlayer.h>
#import "AVPDemoServerManager.h"

@interface SimplePlayerViewController : UIViewController

/**
 当前播放model
 */
@property (nonatomic,strong)AVPDemoResponseVideoListModel *currentModel;

/**
 数据源
 */
@property (nonatomic,strong)NSMutableArray *dataArray;

/**
 数据源类型
 */
@property (nonatomic,assign)AVPPlaySourceType PlaySourceType;

/**
 播放器
 */
@property (nonatomic,strong)AliListPlayer *listPlayer;

/**
 是否全部服务器数据都被加载完了
 */
@property (nonatomic,assign)BOOL isAllData;

@end




