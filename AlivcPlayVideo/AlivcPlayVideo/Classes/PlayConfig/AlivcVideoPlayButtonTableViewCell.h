//
//  AlivcVideoPlayButtonTableViewCell.h
//  AlivcLongVideo
//
//  Created by ToT on 2020/1/7.
//

#import <UIKit/UIKit.h>

typedef void(^buttonClickCallBack)(void);

@interface AlivcVideoPlayButtonTableViewCell : UITableViewCell

@property (nonatomic,strong)buttonClickCallBack callBack;
@property (nonatomic,strong)UIButton *centerButton;

@end


