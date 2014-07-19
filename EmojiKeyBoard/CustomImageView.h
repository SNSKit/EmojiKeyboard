//
//  CustomImageView.h
//  Test
//
//  Created by wang on 14-7-19.
//  Copyright (c) 2014年 linptech. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kButtonGap 45
#define kSeperatorGap 45
#define kLeftMargin 8
#define kButtonWidth 30
#define kSeperatorWidth 8
#define kBarHeight  29
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

@protocol ButtonIndexChangedDelegate <NSObject>
@optional
- (void)segButtonDidChanged:(UIButton *)sender;
- (void)backspaceButtonDidPress;

@end

@interface CustomImageView : UIImageView

@property (nonatomic,strong) UIImage *seperatorImage;
@property (nonatomic,strong) NSArray *buttonNormalImages;
@property (nonatomic,strong) NSArray *buttonSelectedImages;
@property (nonatomic,strong) UIImage *leftCornerImage;
@property (nonatomic,strong) UIImage *rightCornerImage;
@property (nonatomic,assign) NSUInteger selectedIndex;
@property (nonatomic,weak) id<ButtonIndexChangedDelegate>indexChangedDelegate;

- (void)initButtonsWithImageArray:(NSArray *)imageArray;

@end
