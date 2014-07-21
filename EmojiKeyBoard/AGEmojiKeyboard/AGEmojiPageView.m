//
//  AGEmojiPageView.m
//  AGEmojiKeyboard
//
//  Created by Ayush on 09/05/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//

#import "AGEmojiPageView.h"
#import "AGEmojiKeyBoardView.h"

#define BUTTON_FONT_SIZE 32

@interface AGEmojiPageView ()

@property (nonatomic) CGSize buttonSize;
@property (nonatomic) NSMutableArray *buttons;
@property (nonatomic) NSUInteger columns;
@property (nonatomic) NSUInteger rows;
@property (nonatomic) UIImage *backSpaceButtonImage;
@property (nonatomic,strong) UILongPressGestureRecognizer *longPress;

@end

@implementation AGEmojiPageView

- (id)initWithFrame:(CGRect)frame
         buttonSize:(CGSize)buttonSize
               rows:(NSUInteger)rows
            columns:(NSUInteger)columns {
  self = [super initWithFrame:frame];
  if (self) {
    _buttonSize = buttonSize;
    _columns = columns;
    _rows = rows;
    _buttons = [[NSMutableArray alloc] initWithCapacity:rows * columns];
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpressHandler:)];
      self.userInteractionEnabled = YES;
      [self addGestureRecognizer:_longPress];
      _longPress.minimumPressDuration = 0.20f;
  }
  return self;
}

- (void)setButtonTexts:(NSMutableArray *)buttonTexts {
    
    NSAssert(buttonTexts != nil, @"Array containing texts to be set on buttons is nil");
    
    if (([self.buttons count] - 1) == [buttonTexts count]) {
        // just reset text on each button
        for (NSUInteger i = 0; i < [buttonTexts count]; ++i) {
            [self.buttons[i] setTitle:buttonTexts[i] forState:UIControlStateNormal];
        }
    } else {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.buttons = nil;
        self.buttons = [NSMutableArray arrayWithCapacity:self.rows * self.columns];
        for (NSUInteger i = 0; i < [buttonTexts count]; ++i) {
            UIButton *button = [self createButtonAtIndex:i];
            [button setTitle:buttonTexts[i] forState:UIControlStateNormal];
            [self addToViewButton:button];
            AGEmojiKeyboardView *keyboardView = (AGEmojiKeyboardView *)_delegate;
            [keyboardView.scrollView.panGestureRecognizer requireGestureRecognizerToFail:_longPress];
        }
    }
}

- (void)addToViewButton:(UIButton *)button {
    
    NSAssert(button != nil, @"Button to be added is nil");
    
    [self.buttons addObject:button];
    [self addSubview:button];
}

- (CGFloat)XMarginForButtonInColumn:(NSInteger)column {
    CGFloat padding = ((CGRectGetWidth(self.bounds) - self.columns * self.buttonSize.width) / self.columns);
    return (padding / 2 + column * (padding + self.buttonSize.width));
}

- (CGFloat)YMarginForButtonInRow:(NSInteger)rowNumber {
    CGFloat padding = ((CGRectGetHeight(self.bounds) - self.rows * self.buttonSize.height) / self.rows);
    return (padding / 2 + rowNumber * (padding + self.buttonSize.height)) - 8;
}

- (UIButton *)createButtonAtIndex:(NSUInteger)index {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont fontWithName:@"Apple color emoji" size:BUTTON_FONT_SIZE];
    NSInteger row = (NSInteger)(index / self.columns);
    NSInteger column = (NSInteger)(index % self.columns);
    button.frame = CGRectIntegral(CGRectMake([self XMarginForButtonInColumn:column],
                                             [self YMarginForButtonInRow:row],
                                             self.buttonSize.width,
                                             self.buttonSize.height));
    [button addTarget:self action:@selector(emojiButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}


- (void)emojiButtonPressed:(UIButton *)button {
  [self.delegate emojiPageView:self didUseEmoji:button.titleLabel.text];
}

- (void)longpressHandler:(UILongPressGestureRecognizer *)longGesture{
    
    
    if(longGesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [longGesture locationInView:self];
        NSLog(@"%@",NSStringFromCGPoint(point));
    }
    CGPoint point = [longGesture locationInView:self];
    NSLog(@"%@",NSStringFromCGPoint(point));
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [[event allTouches] anyObject];
    NSLog(@"begin:%@",NSStringFromCGPoint([touch locationInView:self]));
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [[event allTouches] anyObject];
    NSLog(@"move:%@",NSStringFromCGPoint([touch locationInView:self]));
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [[event allTouches] anyObject];
    NSLog(@"end:%@",NSStringFromCGPoint([touch locationInView:self]));
}

@end
