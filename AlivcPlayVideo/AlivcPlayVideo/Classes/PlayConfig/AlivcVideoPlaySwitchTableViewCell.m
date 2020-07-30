//
//  AlivcVideoPlaySwitchTableViewCell.m
//  AlivcLongVideo
//
//  Created by ToT on 2019/12/25.
//

#import "AlivcVideoPlaySwitchTableViewCell.h"
#import "AlivcUIConfig.h"

@implementation AlivcVideoPlaySwitchTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
        
        self.titleLabel = [[UILabel alloc]init];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.titleLabel];
        
        self.insideSwitch = [[UISwitch alloc]init];
        [self.insideSwitch addTarget:self action:@selector(switchValueChanged) forControlEvents:UIControlEventValueChanged];
        self.insideSwitch.onTintColor = [AlivcUIConfig shared].kAVCThemeColor;
        [self addSubview:self.insideSwitch];
    }
    return self;
}

- (void)setLeaderText:(NSString *)leaderText {
    _leaderText = leaderText;
    
    self.titleLabel.text = leaderText;
    [self.titleLabel sizeToFit];
    self.titleLabel.center = CGPointMake(self.titleLabel.center.x, self.frame.size.height/2);
    self.insideSwitch.center = CGPointMake(CGRectGetMaxX(self.titleLabel.frame)+self.insideSwitch.frame.size.width/2 + 20, self.titleLabel.center.y);
}

- (void)switchValueChanged {
    if (self.callBack) {
        self.callBack(self.leaderText, self.leaderTextKey, self.insideSwitch.isOn);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
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
