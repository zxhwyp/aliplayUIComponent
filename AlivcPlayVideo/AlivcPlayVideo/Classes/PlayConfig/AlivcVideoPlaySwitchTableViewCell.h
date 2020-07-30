//
//  AlivcVideoPlaySwitchTableViewCell.h
//  AlivcLongVideo
//
//  Created by ToT on 2019/12/25.
//

#import <UIKit/UIKit.h>

typedef void(^switchChangedCallBack)(NSString *leaderText,NSString *leaderTextKey,BOOL isOn);

@interface AlivcVideoPlaySwitchTableViewCell : UITableViewCell

@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UISwitch *insideSwitch;

@property (nonatomic,strong)NSString *leaderText;
@property (nonatomic,strong)NSString *leaderTextKey;

@property (nonatomic,strong)switchChangedCallBack callBack;

@end


