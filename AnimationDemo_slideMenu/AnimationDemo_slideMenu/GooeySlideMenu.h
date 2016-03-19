//
//  GooeySlideMenu.h
//  AnimationDemo_slideMenu
//
//  Created by 陈知行 on 16/3/15.
//  Copyright © 2016年 陈知行. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^MenuButtonClickBlock)(NSInteger index, NSString *title, NSInteger titleCounts);

@interface GooeySlideMenu : UIView

@property (nonatomic, copy) MenuButtonClickBlock menuClickBlock;

- (instancetype)initWithTitles:(NSArray *)titles;

- (instancetype)initWithTitles:(NSArray *)titles buttonHeight:(CGFloat)height menuColor:(UIColor *)menuColor backBlurStyle:(UIBlurEffectStyle)style;

/**
 *  弹出侧边菜单
 */
- (void)trigger;

@end
