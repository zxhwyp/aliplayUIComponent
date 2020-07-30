//
//  AlivcVideoPlayButtonTableViewCell.m
//  AlivcLongVideo
//
//  Created by ToT on 2020/1/7.
//

#import "AlivcVideoPlayButtonTableViewCell.h"
#import "AlivcUIConfig.h"
#import "NSString+AlivcHelper.h"

@implementation AlivcVideoPlayButtonTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
                
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
        
        self.centerButton = [[UIButton alloc]init];
        self.centerButton.backgroundColor = [UIColor colorWithRed:52/255.0 green:55/255.0 blue:65/255.0 alpha:1];
        self.centerButton.layer.masksToBounds = YES;
        self.centerButton.layer.cornerRadius = 20;
        [self.centerButton setTitle:[@"根据vid刷新鉴权数据" localString] forState:UIControlStateNormal];
        self.centerButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.centerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.centerButton addTarget:self action:@selector(centerButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.centerButton];

    }
    return self;
}

- (void)centerButtonAction {
    if (self.callBack) {
        self.callBack();
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.centerButton.frame = CGRectMake(0, 0, self.frame.size.width/2, 40);
    self.centerButton.center = CGPointMake(self.frame.size.width/2, 40);
    NSLog(@"layoutSubviews");
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
