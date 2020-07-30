//
//  AlivcVideoPlayButtonSelectView.h
//  AlivcLongVideo
//
//  Created by ToT on 2019/12/20.
//

#import <UIKit/UIKit.h>
#import "AlivcUIConfig.h"

typedef void(^selectChangedCallBack)(NSInteger index);

@interface AlivcVideoPlayButtonSelectView : UIView

@property (nonatomic,assign)NSInteger selectIndex;
@property (nonatomic,assign)CGFloat viewHeight;
@property (nonatomic,strong)selectChangedCallBack callBack;

- (instancetype)initWithTitle:(NSString *)title sourceArray:(NSArray <NSString *>*)array width:(CGFloat)width;

- (instancetype)initWithTitle:(NSString *)title sourceArray:(NSArray <NSString *>*)array width:(CGFloat)width lineContain:(NSInteger)count;

@end


