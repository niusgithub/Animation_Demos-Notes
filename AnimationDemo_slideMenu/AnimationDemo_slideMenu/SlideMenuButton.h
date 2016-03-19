//
//  SlideMenuButton.h
//  AnimationDemo_slideMenu
//
//  Created by 陈知行 on 16/3/15.
//  Copyright © 2016年 陈知行. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlideMenuButton : UIView

@property (nonatomic, strong) UIColor *buttonColor;
@property (nonatomic, copy) void (^buttonClickBlock)(void);

- (instancetype)initWithTitle:(NSString *)title;

@end
