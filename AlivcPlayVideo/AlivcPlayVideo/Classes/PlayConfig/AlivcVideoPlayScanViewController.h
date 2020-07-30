//
//  AlivcVideoPlayScanViewController.h
//  AlivcBasicVideo
//
//  Created by ToT on 2020/3/18.
//

#import <UIKit/UIKit.h>

typedef void(^scanTextCallBack)(NSString *text);

@interface AlivcVideoPlayScanViewController : UIViewController

@property (nonatomic,strong)scanTextCallBack scanedTextCallBack;

@end

