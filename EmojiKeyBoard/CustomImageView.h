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
@property (nonatomic,weak) id<ButtonIndexChangedDelegate>indexChangedDelegate;

- (instancetype)initWithFrame:(CGRect)frame
           buttonNormalImages:(NSArray *)imageArrary
         buttonSelectedImages:(NSArray *)selectedImageArray
              leftCornerImage:(UIImage *)left
             rightCornerImage:(UIImage *)right
                     delegate:(id<ButtonIndexChangedDelegate>)indexChangedDelegate;

@end
