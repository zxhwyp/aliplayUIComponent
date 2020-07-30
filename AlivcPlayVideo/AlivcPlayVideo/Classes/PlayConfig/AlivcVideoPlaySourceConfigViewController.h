//
//  AlivcVideoPlaySourceConfigViewController.h
//  AlivcLongVideo
//
//  Created by ToT on 2019/12/17.
//

#import <UIKit/UIKit.h>
#import "AlivcVideoPlayPlayerConfig.h"

@interface AlivcVideoPlaySourceConfigViewController : UIViewController

@property (nonatomic,assign)SourceType sourceType;
@property (nonatomic,strong)AlivcVideoPlayPlayerConfig *playerConfig;

@end


