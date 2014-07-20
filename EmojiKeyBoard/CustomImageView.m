//
//  CustomImageView.m
//  Test
//
//  Created by wang on 14-7-19.
//  Copyright (c) 2014年 linptech. All rights reserved.
//

#import "CustomImageView.h"

@interface CustomImageView()

@property (nonatomic,strong) UIImageView *leftImageView;
@property (nonatomic,strong) UIImageView *rightImageView;
@property (nonatomic,strong) NSArray *buttonNormalImages;
@property (nonatomic,strong) NSArray *buttonSelectedImages;
@property (nonatomic,strong) UIImage *leftCornerImage;
@property (nonatomic,strong) UIImage *rightCornerImage;
@property (nonatomic,assign) NSUInteger selectedIndex;

@end

@implementation CustomImageView

- (instancetype)initWithFrame:(CGRect)frame
           buttonNormalImages:(NSArray *)imageArrary
         buttonSelectedImages:(NSArray *)selectedImageArray
              leftCornerImage:(UIImage *)left
             rightCornerImage:(UIImage *)right
                     delegate:(id<ButtonIndexChangedDelegate>)indexChangedDelegate
{
  self = [super initWithFrame:frame];
  if (self) {
    _buttonNormalImages = imageArrary;
    _buttonSelectedImages = selectedImageArray;
    _leftCornerImage = left;
    _rightCornerImage = right;
    _selectedIndex = 1;
    _indexChangedDelegate = indexChangedDelegate;
    [self initButtonsWithImageArray:_buttonNormalImages];
  }
  return self;
}

- (void)initButtonsWithImageArray:(NSArray *)imageArray{
    
    for (int i = 0; i < imageArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(kLeftMargin + kButtonGap * i, 0, kButtonWidth, kBarHeight);
        if (i == 0) {
            _rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kButtonGap, 0, kScreenWidth - kButtonGap, kBarHeight)];
            UIEdgeInsets rightInset = UIEdgeInsetsMake(0,8,0,0);
            UIImage *iamge = [_rightCornerImage resizableImageWithCapInsets:rightInset resizingMode:UIImageResizingModeStretch];
            _rightImageView.image = iamge;
            [self addSubview:_rightImageView];
            
            _leftImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
            [self addSubview:_leftImageView];
            
            NSString *imgName = _buttonSelectedImages[0];
            [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
            [self showSeperatorAtIndex:i + 1];
        }
        else{
            [btn setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
        }
        btn.tag = i + 1;
        if (i == imageArray.count - 1) {
            [btn addTarget:self action:@selector(backspacePressed) forControlEvents:UIControlEventTouchDown];
        }else{
            [btn addTarget:self action:@selector(segButtonChanged:) forControlEvents:UIControlEventTouchDown];
        }
        
        [self addSubview:btn];
    }
}

- (void)segButtonChanged:(UIButton *)sender{
    if (_selectedIndex == sender.tag) {
        return;
    }
    
    //取消上一次的选择
    [self setSegButtonAtIndex:_selectedIndex isSelected:NO];
    
    //显示这一次的选择
    _selectedIndex = sender.tag;
    [self setSegButtonAtIndex:_selectedIndex isSelected:YES];
    [self showSeperatorAtIndex:_selectedIndex];
    if ([_indexChangedDelegate respondsToSelector:@selector(segButtonDidChanged:)]) {
        [_indexChangedDelegate segButtonDidChanged:sender];
    }
}

- (void)backspacePressed{
    if ([_indexChangedDelegate respondsToSelector:@selector(backspaceButtonDidPress)]) {
        [_indexChangedDelegate backspaceButtonDidPress];
    }
}

- (void)setSegButtonAtIndex:(NSUInteger)index isSelected:(BOOL)isSelected{
    if (isSelected) {
        UIButton *btn = (UIButton *)[self viewWithTag:index];
        [btn setImage:[UIImage imageNamed:_buttonSelectedImages[index - 1]] forState:UIControlStateNormal];
        
        _leftImageView.frame = CGRectMake(0, 0, (index - 1) * kButtonGap, kBarHeight);
        UIEdgeInsets leftInset = UIEdgeInsetsMake(0,0,0,8);
        UIImage *leftIamge = [_leftCornerImage resizableImageWithCapInsets:leftInset resizingMode:UIImageResizingModeStretch];
        _leftImageView.image = leftIamge;
        
        _rightImageView.frame = CGRectMake(kButtonGap + (index - 1) * kButtonGap, 0, kScreenWidth - kButtonGap + (index - 1) * kButtonGap, kBarHeight);
        UIEdgeInsets rightInset = UIEdgeInsetsMake(0,8,0,0);
        UIImage *rightIamge = [_rightCornerImage resizableImageWithCapInsets:rightInset resizingMode:UIImageResizingModeStretch];
        _rightImageView.image = rightIamge;
        if (index == 1) {
            _leftImageView.frame = CGRectZero;
        }
    }else{
        UIButton *btn = (UIButton *)[self viewWithTag:index];
        [btn setImage:[UIImage imageNamed:_buttonNormalImages[index - 1]] forState:UIControlStateNormal];
    }
}

- (void)showSeperatorAtIndex:(NSUInteger)index{
    [_rightImageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_leftImageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    switch (index) {
        case 1:
            //左0右5
            for (int i = 0; i < 5; i++) {
                UIImageView *seperator = [[UIImageView alloc] initWithFrame:CGRectMake(kSeperatorGap * (i + 1), 0, 8, kBarHeight)];
                seperator.image = [UIImage imageNamed:@"icons_bg_separator"];
                [_rightImageView addSubview:seperator];
            }
            break;
        case 2:
            //左0右4
            for (int i = 0; i < 4; i++) {
                UIImageView *seperator = [[UIImageView alloc] initWithFrame:CGRectMake(kSeperatorGap * (i + 1), 0, 8, kBarHeight)];
                seperator.image = [UIImage imageNamed:@"icons_bg_separator"];
                [_rightImageView addSubview:seperator];
            }
            break;
        case 3:
            //左1右3
        {
            for (int i = 0; i < 2; i++) {
                UIImageView *seperator = [[UIImageView alloc] initWithFrame:CGRectMake(kSeperatorGap * (i + 1), 0, 8, kBarHeight)];
                seperator.image = [UIImage imageNamed:@"icons_bg_separator"];
                [_rightImageView addSubview:seperator];
            }
            UIImageView *seperator = [[UIImageView alloc] initWithFrame:CGRectMake(kSeperatorGap, 0, 8, kBarHeight)];
            seperator.image = [UIImage imageNamed:@"icons_bg_separator"];
            [_leftImageView addSubview:seperator];
        }
            break;
        case 4:
            //左2右2
        {
            for (int i = 0; i < 2; i++) {
                UIImageView *seperator = [[UIImageView alloc] initWithFrame:CGRectMake(kSeperatorGap * (i + 1), 0, 8, kBarHeight)];
                seperator.image = [UIImage imageNamed:@"icons_bg_separator"];
                [_rightImageView addSubview:seperator];
            }
            for (int i = 0; i < 2; i++) {
                UIImageView *seperator = [[UIImageView alloc] initWithFrame:CGRectMake(kSeperatorGap * (i + 1), 0, 8, kBarHeight)];
                seperator.image = [UIImage imageNamed:@"icons_bg_separator"];
                [_leftImageView addSubview:seperator];
            }
        }
            break;
        case 5:
            //左3右1
        {
            for (int i = 0; i < 3; i++) {
                UIImageView *seperator = [[UIImageView alloc] initWithFrame:CGRectMake(kSeperatorGap * (i + 1), 0, 8, kBarHeight)];
                seperator.image = [UIImage imageNamed:@"icons_bg_separator"];
                [_leftImageView addSubview:seperator];
            }
            UIImageView *seperator = [[UIImageView alloc] initWithFrame:CGRectMake(kSeperatorGap, 0, 8, kBarHeight)];
            seperator.image = [UIImage imageNamed:@"icons_bg_separator"];
            [_rightImageView addSubview:seperator];
        }
            break;
        case 6:
            //左4右0
            for (int i = 0; i < 4; i++) {
                UIImageView *seperator = [[UIImageView alloc] initWithFrame:CGRectMake(kSeperatorGap * (i + 1), 0, 8, kBarHeight)];
                seperator.image = [UIImage imageNamed:@"icons_bg_separator"];
                [_leftImageView addSubview:seperator];
            }
            break;
        default:
            break;
    }
}

@end
