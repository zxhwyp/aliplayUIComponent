//
//  AlivcVideoPlayEmptyView.m
//  AlivcLongVideo
//
//  Created by ToT on 2020/1/14.
//

#import "AlivcVideoPlayEmptyView.h"
#import "NSString+AlivcHelper.h"

@implementation AlivcVideoPlayEmptyView

- (void)dealloc {
    NSLog(@"销毁了");
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        imageView.center = CGPointMake(frame.size.width/2, frame.size.height*0.3);
        imageView.image = [AlivcImage imageInBasicVideoNamed:@"network_lost"];
        [self addSubview:imageView];
        
        UIButton *retryButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
        retryButton.center = CGPointMake(frame.size.width/2, frame.size.height*0.7);
        [retryButton setTitle:[@"重试" localString] forState:UIControlStateNormal];
        [retryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        retryButton.titleLabel.font = [UIFont systemFontOfSize:14];
        retryButton.backgroundColor = [UIColor colorWithRed:52/255.0 green:55/255.0 blue:65/255.0 alpha:1];
        [retryButton addTarget:self action:@selector(retryButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:retryButton];
        
        UIButton *backButton = [[UIButton alloc]init];
        [backButton addTarget:self action:@selector(backButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setImage:[AlivcImage imageInBasicVideoNamed:@"avcBackIcon"] forState:UIControlStateNormal];
        backButton.frame = CGRectMake(0, 0, 40, 40);
        backButton.center = CGPointMake(15 + backButton.frame.size.width / 2, 20 + 22);
        [self addSubview:backButton];
        
    }
    return self;
}

- (void)retryButtonAction {
    if (self.callBack) {
        self.callBack();
    }
}

- (void)backButtonTouched:(UIButton *)sender {
    if (self.backCallBack) {
        self.backCallBack();
    }
}

@end
