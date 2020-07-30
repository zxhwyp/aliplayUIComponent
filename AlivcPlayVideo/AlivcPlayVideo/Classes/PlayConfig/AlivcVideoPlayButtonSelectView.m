//
//  AlivcVideoPlayButtonSelectView.m
//  AlivcLongVideo
//
//  Created by ToT on 2019/12/20.
//

#import "AlivcVideoPlayButtonSelectView.h"

@interface AlivcVideoPlayButtonSelectView()

@property (nonatomic,strong)NSArray *sourceArray;
@property (nonatomic,strong)NSMutableArray *buttonsArray;

@end

@implementation AlivcVideoPlayButtonSelectView

- (instancetype)initWithTitle:(NSString *)title sourceArray:(NSArray <NSString *>*)array width:(CGFloat)width {
    return [self initWithTitle:title sourceArray:array width:width lineContain:3];
}

- (instancetype)initWithTitle:(NSString *)title sourceArray:(NSArray <NSString *>*)array width:(CGFloat)width lineContain:(NSInteger)count {
    self = [super init];
    if (self) {
                
        self.sourceArray = array;
        self.buttonsArray = [NSMutableArray array];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, 18)];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.text = title;
        titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:titleLabel];
        
        CGFloat buttonEdge = 15;
        CGFloat buttonWidth = (width - buttonEdge*(count-1))/count;
        CGFloat buttonHeight = (width - buttonEdge*2)/3*0.36;
        CGFloat buttonStartY = CGRectGetMaxY(titleLabel.frame) + 20;
        
        for (int i = 0; i<array.count; i++) {
            NSInteger indexCount = i%count;
            NSInteger line = i/count;
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(indexCount *(buttonWidth+buttonEdge) , buttonStartY + line *(buttonHeight+buttonEdge), buttonWidth, buttonHeight)];
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = 3;
            button.tag = i;
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            [button setTitle:array[i] forState:UIControlStateNormal];
            if ( i == 0) {
                button.backgroundColor = [self buttonColorIsSelected:YES];
            }else {
                button.backgroundColor = [self buttonColorIsSelected:NO];
            }
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            [self.buttonsArray addObject:button];
            if (i == array.count -1) {
                self.viewHeight = CGRectGetMaxY(button.frame);
            }
        }
    }
    return self;
}

- (void)buttonClickAction:(UIButton *)sender {
    self.selectIndex = sender.tag;
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    if (_selectIndex == selectIndex) {
        return;
    }
    if (_selectIndex >= 0 && _selectIndex < self.buttonsArray.count) {
        UIButton *lastButton = self.buttonsArray[_selectIndex];
        lastButton.backgroundColor = [self buttonColorIsSelected:NO];
    }
    if (selectIndex >= 0 && selectIndex < self.buttonsArray.count) {
        UIButton *currentButton = self.buttonsArray[selectIndex];
        currentButton.backgroundColor = [self buttonColorIsSelected:YES];
        _selectIndex = selectIndex;
        if (self.callBack) {
            self.callBack(selectIndex);
        }
    }
}

- (UIColor *)buttonColorIsSelected:(BOOL)isSelected {
    if (isSelected) {
        return [AlivcUIConfig shared].kAVCThemeColor;
    }else {
        return [UIColor colorWithRed:52/255.0 green:55/255.0 blue:65/255.0 alpha:1];
    }
}

@end
