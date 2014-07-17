//
//  ViewController.m
//  EmojiKeyBoard
//
//  Created by WangMac on 14-7-17.
//  Copyright (c) 2014年 Meitu. All rights reserved.
//

#import "ViewController.h"
#import "AGEmojiKeyBoardView.h"

@interface ViewController ()<AGEmojiKeyboardViewDelegate, AGEmojiKeyboardViewDataSource>

@property (nonatomic) UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor grayColor];
  self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 60, 320, 200)];
  self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  AGEmojiKeyboardView *emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 245) dataSource:self];
  emojiKeyboardView.delegate = self;
  [self.view addSubview:self.textView];
  self.textView.inputView = emojiKeyboardView;
}

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
  self.textView.text = [self.textView.text stringByAppendingString:emoji];
}


//http://www.cocoachina.com/bbs/read.php?tid=213384
//http://stackoverflow.com/questions/11750450/how-to-delete-one-emoji-in-nsstring
//http://www.raywenderlich.com/forums/viewtopic.php?f=2&t=9562
//http://www.apkbus.com/android-125998-1-1.html
- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
  if (self.textView.text.length >=2) {
    NSRange cursorPosition = [self.textView selectedRange];
    NSInteger index = cursorPosition.location;
    if (index == self.textView.text.length) {
      self.textView.text = [self.textView.text substringToIndex:index - 2];
    }else{
      NSString *leftStr = [self.textView.text substringToIndex:index];
      NSString *rightStr = [self.textView.text substringFromIndex:index];
      if (leftStr.length>=2) {
        leftStr = [leftStr substringToIndex:index - 2];
        self.textView.text = [leftStr stringByAppendingString:rightStr];
        self.textView.selectedRange = NSMakeRange(index - 2, 0);
      }
    }
  }
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
  UIImage *selectedIamge;
  switch (category) {
    case AGEmojiKeyboardViewCategoryImageRecent:
      selectedIamge = [UIImage imageNamed:@"recent_s"];
      break;
    case AGEmojiKeyboardViewCategoryImageFace:
      selectedIamge = [UIImage imageNamed:@"face_s"];
      break;
    case AGEmojiKeyboardViewCategoryImageBell:
      selectedIamge = [UIImage imageNamed:@"bell_s"];
      break;
    case AGEmojiKeyboardViewCategoryImageFlower:
      selectedIamge = [UIImage imageNamed:@"flower_s"];
      break;
    case AGEmojiKeyboardViewCategoryImageCar:
      selectedIamge = [UIImage imageNamed:@"car_s"];
      break;
    case AGEmojiKeyboardViewCategoryImageCharacters:
      selectedIamge = [UIImage imageNamed:@"characters_s"];
      break;
    default:
      break;
  }
  return selectedIamge;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
  UIImage *noneSelectedIamge;
  switch (category) {
    case AGEmojiKeyboardViewCategoryImageRecent:
      noneSelectedIamge = [UIImage imageNamed:@"recent_n"];
      break;
    case AGEmojiKeyboardViewCategoryImageFace:
      noneSelectedIamge = [UIImage imageNamed:@"face_n"];
      break;
    case AGEmojiKeyboardViewCategoryImageBell:
      noneSelectedIamge = [UIImage imageNamed:@"bell_n"];
      break;
    case AGEmojiKeyboardViewCategoryImageFlower:
      noneSelectedIamge = [UIImage imageNamed:@"flower_n"];
      break;
    case AGEmojiKeyboardViewCategoryImageCar:
      noneSelectedIamge = [UIImage imageNamed:@"car_n"];
      break;
    case AGEmojiKeyboardViewCategoryImageCharacters:
      noneSelectedIamge = [UIImage imageNamed:@"characters_n"];
      break;
    default:
      break;
  }
  return noneSelectedIamge;
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView {
  UIImage *deleteImage = [UIImage imageNamed:@"backspace_n"];
  return deleteImage;
}

@end
