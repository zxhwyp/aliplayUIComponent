//
//  AlivcVideoPlayEmptyView.h
//  AlivcLongVideo
//
//  Created by ToT on 2020/1/14.
//

#import <UIKit/UIKit.h>

typedef void(^retryCallBack)(void);
typedef void(^backButtonCallBack)(void);

@interface AlivcVideoPlayEmptyView : UIView

@property (nonatomic,strong)retryCallBack callBack;
@property (nonatomic,strong)backButtonCallBack backCallBack;

@end


