//
//  AlivcVideoPlayTextFieldTableViewCell.m
//  AlivcLongVideo
//
//  Created by ToT on 2019/12/25.
//

#import "AlivcVideoPlayTextFieldTableViewCell.h"
#import "AlivcUIConfig.h"

@interface AlivcVideoPlayTextFieldTableViewCell()<UITextFieldDelegate>

@property (nonatomic,strong)UIButton *scanButton;

@end


@implementation AlivcVideoPlayTextFieldTableViewCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
                
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 250, 18)];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.titleLabel];
        
        self.inputTextField = [[UITextField alloc]init];
        self.inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.inputTextField.layer.cornerRadius = 3;
        self.inputTextField.delegate = self;
        self.inputTextField.font = [UIFont systemFontOfSize:14];
        self.inputTextField.backgroundColor = [UIColor colorWithRed:52/255.0 green:55/255.0 blue:65/255.0 alpha:1];
        UIView*leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 88)];
        self.inputTextField.leftView = leftView;
        self.inputTextField.leftViewMode = UITextFieldViewModeAlways;
        self.inputTextField.textColor = [UIColor whiteColor];
        [self addSubview:self.inputTextField];
        
        self.scanButton = [[UIButton alloc]init];
        [self.scanButton setImage:[AlivcImage imageInBasicVideoNamed:@"avcScan"] forState:UIControlStateNormal];
        [self.scanButton addTarget:self action:@selector(scanButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.scanButton];
        self.scanButton.hidden = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged) name:UITextFieldTextDidChangeNotification object:self.inputTextField];
    }
    return self;
}

- (void)setShowScanButton:(BOOL)showScanButton {
    _showScanButton = showScanButton;
    if (showScanButton) {
        self.scanButton.hidden = NO;
    }else {
        self.scanButton.hidden = YES;
    }
}

- (void)textFieldChanged {
    if (self.callBack) {
        self.callBack(self.leaderText, self.inputTextField.text);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.showScanButton) {
        self.inputTextField.frame = CGRectMake(0, 28, self.frame.size.width-50, 50);
        self.scanButton.frame = CGRectMake(self.frame.size.width-50, 28, 50, 50);
    }else {
        self.inputTextField.frame = CGRectMake(0, 28, self.frame.size.width, 50);
    }
    NSLog(@"layoutSubviews");
}

- (void)scanButtonAction {
    if (self.toScanCallBack) {
        self.toScanCallBack();
    }
}

- (void)setLeaderText:(NSString *)leaderText {
    _leaderText = leaderText;
    
    self.titleLabel.text = leaderText;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
