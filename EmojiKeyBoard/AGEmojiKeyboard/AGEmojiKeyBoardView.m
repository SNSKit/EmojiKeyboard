//
//  AGEmojiKeyboardView.m
//  AGEmojiKeyboard
//
//  Created by Ayush on 09/05/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//
#import "AGEmojiKeyBoardView.h"
#import "AGEmojiPageView.h"

#define kLeftImageViewTag 100
#define kRightImageViewTag 101
#define kButtonTag 102
#define kBottomViewTag 103

static const CGFloat ButtonWidth = 45;
static const CGFloat ButtonHeight = 37;
static const NSUInteger DefaultRecentEmojisMaintainedCount = 50;

static NSString *const segmentRecentName = @"Recent";
NSString *const RecentUsedEmojiCharactersKey = @"RecentUsedEmojiCharactersKey";


@interface AGEmojiKeyboardView () <UIScrollViewDelegate, AGEmojiPageViewDelegate>

@property (nonatomic) UIPageControl *pageControl;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSDictionary *emojis;
@property (nonatomic) NSMutableArray *pageViews;
@property (nonatomic) NSString *category;
@property (nonatomic,strong) UIView *barView;
@property (nonatomic,assign) NSUInteger selectedIndex;

//images
@property (nonatomic,strong) UIImage *selectedBackImage;
@property (nonatomic,strong) UIImage *normalBackImage;
@property (nonatomic,strong) UIImage *leftCornerImage;
@property (nonatomic,strong) UIImage *rightCornerImage;
@property (nonatomic,strong) UIImage *separatorImage;

@end

@implementation AGEmojiKeyboardView

//_bottomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 320, 29)];
//_bottomImageView.image = [UIImage imageNamed:@"tab_bg"];
//
//
//_leftImage = [UIImage imageNamed:@"corner_left"];
//UIEdgeInsets leftInset = UIEdgeInsetsMake(0,0,0,113);
//_leftImage = [_leftImage resizableImageWithCapInsets:leftInset resizingMode:UIImageResizingModeStretch];
//_leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 29)];
//_leftImageView.image = _leftImage;
//[_bottomImageView addSubview:_leftImageView];
//
//_rightImage = [UIImage imageNamed:@"corner_right"];
//UIEdgeInsets rightInset = UIEdgeInsetsMake(0,173,0,0);
//_rightImage = [_rightImage resizableImageWithCapInsets:rightInset resizingMode:UIImageResizingModeStretch];
//UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(140, 0, 180, 29)];
//rightImageView.image = _rightImage;
//[_bottomImageView addSubview:rightImageView];

#pragma mark - View Related Methods

- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<AGEmojiKeyboardViewDataSource>)dataSource {
  self = [super initWithFrame:frame];
  if (self) {
    _dataSource = dataSource;
    _selectedIndex = 1;
    _barView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,CGRectGetWidth(self.bounds), 29)];
    [self addSubview:_barView];
    [self loadAllImages];
    [self buttonsWithImageArray:[self imagesForNonSelectedSegments]];
    
    self.category = [self categoryNameAtIndex:self.defaultSelectedCategory];
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.currentPage = 0;
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor darkGrayColor];
    self.pageControl.backgroundColor = [UIColor clearColor];
    CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:3];
    NSUInteger numberOfPages = [self numberOfPagesForCategory:self.category
                                                  inFrameSize:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetHeight(self.barView.bounds) - pageControlSize.height)];
    self.pageControl.numberOfPages = numberOfPages;
    pageControlSize = [self.pageControl sizeForNumberOfPages:numberOfPages];
    //重设frame,使其为整数避免产生模糊效果
    self.pageControl.frame = CGRectIntegral(CGRectMake((CGRectGetWidth(self.bounds) - pageControlSize.width) / 2,
                                                       CGRectGetHeight(self.bounds) - pageControlSize.height,
                                                       pageControlSize.width,
                                                       pageControlSize.height));
    [self.pageControl addTarget:self action:@selector(pageControlTouched:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_pageControl];
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                 CGRectGetHeight(self.barView.bounds),
                                                                 CGRectGetWidth(self.bounds),
                                                                 CGRectGetHeight(self.bounds) - CGRectGetHeight(self.barView.bounds) - pageControlSize.height)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    self.scrollView.backgroundColor = [UIColor colorWithRed:(float)240/255 green:(float)240/255 blue:(float)240/255 alpha:1.0];
  }
  return self;
}

- (void)layoutSubviews {
  CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:3];
  NSUInteger numberOfPages = [self numberOfPagesForCategory:self.category
                                                inFrameSize:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetHeight(self.barView.bounds) - pageControlSize.height)];
  
  NSInteger currentPage = (self.pageControl.currentPage > numberOfPages) ? numberOfPages : self.pageControl.currentPage;
  
  // if (currentPage > numberOfPages) it is set implicitly to max pageNumber available
  self.pageControl.numberOfPages = numberOfPages;
  pageControlSize = [self.pageControl sizeForNumberOfPages:numberOfPages];
  self.pageControl.frame = CGRectIntegral(CGRectMake((CGRectGetWidth(self.bounds) - pageControlSize.width) / 2,
                                                     CGRectGetHeight(self.bounds) - pageControlSize.height,
                                                     pageControlSize.width,
                                                     pageControlSize.height));
  
  self.scrollView.frame = CGRectMake(0,
                                     CGRectGetHeight(self.barView.bounds),
                                     CGRectGetWidth(self.bounds),
                                     CGRectGetHeight(self.bounds) - CGRectGetHeight(self.barView.bounds) - pageControlSize.height);
  [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.bounds) * currentPage, 0);
  self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds) * numberOfPages, CGRectGetHeight(self.scrollView.bounds));
  [self purgePageViews];
  self.pageViews = [NSMutableArray array];
  [self setPage:currentPage];
}

#pragma mark - Customize SegmentView

- (UIView *)tabViewWithFrame:(CGRect)frame{
  UIView *tabView = [[UIView alloc] initWithFrame:frame];
  
  UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 8, CGRectGetHeight(frame))];
  leftImageView.tag = kLeftImageViewTag;
  [tabView addSubview:leftImageView];
  
  UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) - 8, 0, 8, CGRectGetHeight(frame))];
  rightImageView.tag = kRightImageViewTag;
  [tabView addSubview:rightImageView];
  
  UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
  btn.frame = CGRectMake(CGRectGetWidth(leftImageView.bounds), 0, CGRectGetWidth(frame) - CGRectGetWidth(leftImageView.bounds) - CGRectGetWidth(rightImageView.bounds), CGRectGetHeight(frame));
  [btn addTarget:self action:@selector(barViewButtonChanged:) forControlEvents:UIControlEventTouchUpInside];
  btn.tag = kButtonTag;
  [tabView addSubview:btn];
  
  UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(frame) - 2, CGRectGetWidth(frame), 2)];
  bottomLine.backgroundColor = [UIColor colorWithPatternImage:_normalBackImage];
//  bottomLine.backgroundColor = [UIColor colorWithRed:(float)240/255 green:(float)240/255 blue:(float)240/255 alpha:1.0];
//  bottomLine.tag = kBottomViewTag;
//  bottomLine.hidden = NO;
//  [tabView addSubview:bottomLine];
  
  return tabView;
}

- (void)loadAllImages{
  _selectedBackImage = [UIImage imageNamed:@"tab_bg"];
  _normalBackImage = [UIImage imageNamed:@"unselected_center_bg"];
  _leftCornerImage = [UIImage imageNamed:@"corner_left"];
  _rightCornerImage = [UIImage imageNamed:@"corner_right"];
  _separatorImage = [UIImage imageNamed:@"icons_bg_separator"];
}

- (void)buttonsWithImageArray:(NSArray *)imageArray{
  for (int i = 0; i < imageArray.count; i++) {
    CGRect frame = CGRectMake(i*53, 0, 53, CGRectGetHeight(_barView.frame));
    UIView *segView = [self tabViewWithFrame:frame];
    UIImageView *left = (UIImageView *)[segView viewWithTag:kLeftImageViewTag];
    UIImageView *right = (UIImageView *)[segView viewWithTag:kRightImageViewTag];
    UIButton *btn = (UIButton *)[segView viewWithTag:kButtonTag];
//    UIView *bottomView = (UIView *)[segView viewWithTag:kBottomViewTag];
    if (i == 0) {
//      left.backgroundColor = [UIColor colorWithPatternImage:_selectedBackImage];
      [self setLeftImageView:left withImage:_selectedBackImage rightImageView:right rightImage:_rightCornerImage];
      [self setImage:[self imagesForSelectedSegments][i] andBackImage:_selectedBackImage forButton:btn];
//      bottomView.hidden = YES;
    }else if (i == imageArray.count - 1){
//      right.backgroundColor = [UIColor colorWithPatternImage:_normalBackImage];
//      left.backgroundColor = [UIColor colorWithPatternImage:_normalBackImage];
      [self setLeftImageView:left withImage:_normalBackImage rightImageView:right rightImage:_normalBackImage];
      [self setImage:imageArray[i] andBackImage:_normalBackImage forButton:btn];
    }else{
//      left.backgroundColor = [UIColor colorWithPatternImage:_normalBackImage];
      [self setLeftImageView:left withImage:_normalBackImage rightImageView:right rightImage:_separatorImage];
      [self setImage:imageArray[i] andBackImage:_normalBackImage forButton:btn];
    }
    [btn addTarget:self action:@selector(barViewButtonChanged:) forControlEvents:UIControlEventTouchUpInside];
    segView.tag = i+1;
    [_barView addSubview:segView];
  }
}

- (void)setSegViewAtIndex:(NSUInteger)index isSelected:(BOOL)isSelected{
  if (isSelected) {
    //当前选中的
    UIView *selectedView = [_barView viewWithTag:index];
    UIImageView *selectedLeft = (UIImageView *)[selectedView viewWithTag:kLeftImageViewTag];
    UIImageView *selectedRight = (UIImageView *)[selectedView viewWithTag:kRightImageViewTag];
    UIButton *btn = (UIButton *)[selectedView viewWithTag:kButtonTag];
//    UIView *bottomView = (UIView *)[selectedView viewWithTag:kBottomViewTag];
//    bottomView.hidden = YES;
    //选中的左边
    if (index != 1) {
      UIView *preSegView = [_barView viewWithTag:index - 1];
      UIImageView *preRight = (UIImageView *)[preSegView viewWithTag:kRightImageViewTag];
      preRight.image = _normalBackImage;
//      preRight.backgroundColor = [UIColor colorWithPatternImage:_normalBackImage];
    }
    
    if (index == 1) {
//      selectedLeft.backgroundColor = [UIColor colorWithPatternImage:_selectedBackImage];
      [self setLeftImageView:selectedLeft withImage:_selectedBackImage rightImageView:selectedRight rightImage:_rightCornerImage];
      [self setImage:[self imagesForSelectedSegments][index-1] andBackImage:_selectedBackImage forButton:btn];
    }else if (index == 6){
      selectedRight.backgroundColor = [UIColor colorWithPatternImage:_selectedBackImage];
      [self setLeftImageView:selectedLeft withImage:_leftCornerImage rightImageView:selectedRight rightImage:nil];
      [self setImage:[self imagesForSelectedSegments][index-1] andBackImage:_selectedBackImage forButton:btn];
    }else{
      [self setLeftImageView:selectedLeft withImage:_leftCornerImage rightImageView:selectedRight rightImage:_rightCornerImage];
      [self setImage:[self imagesForSelectedSegments][index-1] andBackImage:_selectedBackImage forButton:btn];
    }
  }else{
    //取消上一次的选择
    UIView *segView = [_barView viewWithTag:index];
    UIImageView *left = (UIImageView *)[segView viewWithTag:kLeftImageViewTag];
    UIImageView *right = (UIImageView *)[segView viewWithTag:kRightImageViewTag];
    UIButton *btn = (UIButton *)[segView viewWithTag:kButtonTag];
//    UIView *bottomView = (UIView *)[segView viewWithTag:kBottomViewTag];
//    bottomView.hidden = NO;
    if (index != 1) {
      UIView *preSegView = [_barView viewWithTag:index - 1];
      UIImageView *preRight = (UIImageView *)[preSegView viewWithTag:kRightImageViewTag];
      preRight.image = _separatorImage;
    }
    if (_selectedIndex == 1) {
//      left.backgroundColor = [UIColor colorWithPatternImage:_normalBackImage];
      [self setLeftImageView:left withImage:_normalBackImage rightImageView:right rightImage:_separatorImage];
      [self setImage:[self imagesForNonSelectedSegments][index-1] andBackImage:_normalBackImage forButton:btn];
    }else if (_selectedIndex == 6){
//      right.backgroundColor = [UIColor colorWithPatternImage:_normalBackImage];
//      left.backgroundColor = [UIColor colorWithPatternImage:_normalBackImage];
      [self setLeftImageView:left withImage:_normalBackImage rightImageView:right rightImage:_normalBackImage];
      [self setImage:[self imagesForNonSelectedSegments][index-1] andBackImage:_normalBackImage forButton:btn];
    }else{
//      left.backgroundColor = [UIColor colorWithPatternImage:_normalBackImage];
      [self setLeftImageView:left withImage:_normalBackImage rightImageView:right rightImage:_separatorImage];
      [self setImage:[self imagesForNonSelectedSegments][index-1] andBackImage:_normalBackImage forButton:btn];
    }
  }
  
}

- (void)setImage:(UIImage *)image andBackImage:(UIImage *)backimage forButton:(UIButton *)btn{
  [btn setImage:image forState:UIControlStateNormal];
  [btn setBackgroundImage:backimage forState:UIControlStateNormal];
}
- (void)setLeftImageView:(UIImageView *)left
               withImage:(UIImage *)leftimage
          rightImageView:(UIImageView *)right
              rightImage:(UIImage *)rightimage
{
  left.image = leftimage;
  right.image = rightimage;
}

#pragma mark - Setter And Getter Methods

- (NSDictionary *)emojis {
  if (!_emojis) {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"EmojisList"
                                                          ofType:@"plist"];
    _emojis = [[NSDictionary dictionaryWithContentsOfFile:plistPath] copy];
  }
  return _emojis;
}

- (NSString *)categoryNameAtIndex:(NSUInteger)index {
  NSArray *categoryList = @[segmentRecentName, @"People", @"Objects", @"Nature", @"Places", @"Symbols"];
  return categoryList[index];
}

- (AGEmojiKeyboardViewCategoryImage)defaultSelectedCategory {
  if ([self.dataSource respondsToSelector:@selector(defaultCategoryForEmojiKeyboardView:)]) {
    return [self.dataSource defaultCategoryForEmojiKeyboardView:self];
  }
  return AGEmojiKeyboardViewCategoryImageRecent;
}

- (NSUInteger)recentEmojisMaintainedCount {
  if ([self.dataSource respondsToSelector:@selector(recentEmojisMaintainedCountForEmojiKeyboardView:)]) {
    return [self.dataSource recentEmojisMaintainedCountForEmojiKeyboardView:self];
  }
  return DefaultRecentEmojisMaintainedCount;
}

- (NSArray *)imagesForSelectedSegments {
  static NSMutableArray *array;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    array = [NSMutableArray array];
    for (AGEmojiKeyboardViewCategoryImage i = AGEmojiKeyboardViewCategoryImageRecent;
         i <= AGEmojiKeyboardViewCategoryImageCharacters;
         ++i) {
      [array addObject:[self.dataSource emojiKeyboardView:self imageForSelectedCategory:i]];
    }
  });
  return array;
}

- (NSArray *)imagesForNonSelectedSegments {
  static NSMutableArray *array;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    array = [NSMutableArray array];
    for (AGEmojiKeyboardViewCategoryImage i = AGEmojiKeyboardViewCategoryImageRecent;
         i <= AGEmojiKeyboardViewCategoryImageCharacters;
         ++i) {
      [array addObject:[self.dataSource emojiKeyboardView:self imageForNonSelectedCategory:i]];
    }
  });
  return array;
}

- (NSMutableArray *)recentEmojis {
  NSArray *emojis = [[NSUserDefaults standardUserDefaults] arrayForKey:RecentUsedEmojiCharactersKey];
  NSMutableArray *recentEmojis = [emojis mutableCopy];
  if (recentEmojis == nil) {
    recentEmojis = [NSMutableArray array];
  }
  return recentEmojis;
}

- (void)setRecentEmojis:(NSMutableArray *)recentEmojis {
  if ([recentEmojis count] > self.recentEmojisMaintainedCount) {
    NSIndexSet *indexesToBeRemoved = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.recentEmojisMaintainedCount, [recentEmojis count] - self.recentEmojisMaintainedCount)];
    [recentEmojis removeObjectsAtIndexes:indexesToBeRemoved];
  }
  [[NSUserDefaults standardUserDefaults] setObject:recentEmojis forKey:RecentUsedEmojiCharactersKey];
}

#pragma mark event handlers

- (void)barViewButtonChanged:(UIButton *)sender{
  if (_selectedIndex == sender.superview.tag) {
    return;
  }
  //取消上一次的选择
  [self setSegViewAtIndex:_selectedIndex isSelected:NO];
  //显示这一次的选择
  _selectedIndex = sender.superview.tag;
  [self setSegViewAtIndex:_selectedIndex isSelected:YES];
  
  self.category = [self categoryNameAtIndex:_selectedIndex - 1];
  self.pageControl.currentPage = 0;
  [self setNeedsLayout];
  
}

- (void)pageControlTouched:(UIPageControl *)sender {
  NSLog(@"currentPage:%@", @( sender.currentPage ));
  CGRect bounds = self.scrollView.bounds;
  bounds.origin.x = CGRectGetWidth(bounds) * sender.currentPage;
  bounds.origin.y = 0;
  [self.scrollView scrollRectToVisible:bounds animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
  NSInteger newPageNumber = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
  if (self.pageControl.currentPage == newPageNumber) {
    return;
  }
  self.pageControl.currentPage = newPageNumber;
  [self setPage:self.pageControl.currentPage];
}

#pragma mark change a page on scrollView

- (BOOL)requireToSetPageViewForIndex:(NSUInteger)index {
  if (index >= self.pageControl.numberOfPages) {
    return NO;
  }
  for (AGEmojiPageView *page in self.pageViews) {
    if ((page.frame.origin.x / CGRectGetWidth(self.scrollView.bounds)) == index) {
      return NO;
    }
  }
  return YES;
}

- (AGEmojiPageView *)synthesizeEmojiPageView {
  NSUInteger rows = [self numberOfRowsForFrameSize:self.scrollView.bounds.size];
  NSUInteger columns = [self numberOfColumnsForFrameSize:self.scrollView.bounds.size];
  AGEmojiPageView *pageView = [[AGEmojiPageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds))
                                                backSpaceButtonImage:[self.dataSource backSpaceButtonImageForEmojiKeyboardView:self]
                                                          buttonSize:CGSizeMake(ButtonWidth, ButtonHeight)
                                                                rows:rows
                                                             columns:columns];
  pageView.delegate = self;
  [self.pageViews addObject:pageView];
  [self.scrollView addSubview:pageView];
  return pageView;
}

- (AGEmojiPageView *)usableEmojiPageView {
  AGEmojiPageView *pageView = nil;
  for (AGEmojiPageView *page in self.pageViews) {
    NSUInteger pageNumber = page.frame.origin.x / CGRectGetWidth(self.scrollView.bounds);
    if (abs((int)(pageNumber - self.pageControl.currentPage)) > 1) {
      pageView = page;
      break;
    }
  }
  if (!pageView) {
    pageView = [self synthesizeEmojiPageView];
  }
  return pageView;
}

- (void)setEmojiPageViewInScrollView:(UIScrollView *)scrollView atIndex:(NSUInteger)index {
  
  if (![self requireToSetPageViewForIndex:index]) {
    return;
  }
  
  AGEmojiPageView *pageView = [self usableEmojiPageView];
  
  NSUInteger rows = [self numberOfRowsForFrameSize:scrollView.bounds.size];
  NSUInteger columns = [self numberOfColumnsForFrameSize:scrollView.bounds.size];
  NSUInteger startingIndex = index * (rows * columns - 1);
  NSUInteger endingIndex = (index + 1) * (rows * columns - 1);
  NSMutableArray *buttonTexts = [self emojiTextsForCategory:self.category
                                                  fromIndex:startingIndex
                                                    toIndex:endingIndex];
  NSLog(@"Setting page at index %@", @( index ));
  [pageView setButtonTexts:buttonTexts];
  pageView.frame = CGRectMake(index * CGRectGetWidth(scrollView.bounds), 0, CGRectGetWidth(scrollView.bounds), CGRectGetHeight(scrollView.bounds));
}

- (void)setPage:(NSInteger)page {
  [self setEmojiPageViewInScrollView:self.scrollView atIndex:page - 1];
  [self setEmojiPageViewInScrollView:self.scrollView atIndex:page];
  [self setEmojiPageViewInScrollView:self.scrollView atIndex:page + 1];
}

- (void)purgePageViews {
  for (AGEmojiPageView *page in self.pageViews) {
    page.delegate = nil;
  }
  self.pageViews = nil;
}

#pragma mark data methods

- (NSUInteger)numberOfColumnsForFrameSize:(CGSize)frameSize {
  return (NSUInteger)floor(frameSize.width / ButtonWidth);
}

- (NSUInteger)numberOfRowsForFrameSize:(CGSize)frameSize {
  //向下取整
  return (NSUInteger)floor(frameSize.height / ButtonHeight);
}

- (NSArray *)emojiListForCategory:(NSString *)category {
  if ([category isEqualToString:segmentRecentName]) {
    return [self recentEmojis];
  }
  return [self.emojis objectForKey:category];
}

- (NSUInteger)numberOfPagesForCategory:(NSString *)category inFrameSize:(CGSize)frameSize {
  
  if ([category isEqualToString:segmentRecentName]) {
    return 1;
  }
  
  NSUInteger emojiCount = [[self emojiListForCategory:category] count];
  NSUInteger numberOfRows = [self numberOfRowsForFrameSize:frameSize];
  NSUInteger numberOfColumns = [self numberOfColumnsForFrameSize:frameSize];
  NSUInteger numberOfEmojisOnAPage = (numberOfRows * numberOfColumns) - 1;
  //ceil:返回不小于给定实数的最小整数
  NSUInteger numberOfPages = (NSUInteger)ceil((float)emojiCount / numberOfEmojisOnAPage);
  NSLog(@"%@ %@ %@ :: %@", @( numberOfRows ), @( numberOfColumns ), @( emojiCount ), @( numberOfPages ));
  return numberOfPages;
}


- (NSMutableArray *)emojiTextsForCategory:(NSString *)category fromIndex:(NSUInteger)start toIndex:(NSUInteger)end {
  NSArray *emojis = [self emojiListForCategory:category];
  end = ([emojis count] > end)? end : [emojis count];
  NSIndexSet *index = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(start, end-start)];
  return [[emojis objectsAtIndexes:index] mutableCopy];
}

#pragma mark EmojiPageViewDelegate

- (void)setInRecentsEmoji:(NSString *)emoji {
  NSAssert(emoji != nil, @"Emoji can't be nil");
  
  NSMutableArray *recentEmojis = [self recentEmojis];
  for (int i = 0; i < [recentEmojis count]; ++i) {
    if ([recentEmojis[i] isEqualToString:emoji]) {
      [recentEmojis removeObjectAtIndex:i];
    }
  }
  [recentEmojis insertObject:emoji atIndex:0];
  [self setRecentEmojis:recentEmojis];
}

- (void)emojiPageView:(AGEmojiPageView *)emojiPageView didUseEmoji:(NSString *)emoji {
  [self setInRecentsEmoji:emoji];
  [self.delegate emojiKeyBoardView:self didUseEmoji:emoji];
}

- (void)emojiPageViewDidPressBackSpace:(AGEmojiPageView *)emojiPageView {
  NSLog(@"Back button pressed");
  [self.delegate emojiKeyBoardViewDidPressBackSpace:self];
}

@end