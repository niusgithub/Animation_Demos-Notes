//
//  SlideMenuButton.m
//  AnimationDemo_slideMenu
//
//  Created by 陈知行 on 16/3/15.
//  Copyright © 2016年 陈知行. All rights reserved.
//

#import "SlideMenuButton.h"

@interface SlideMenuButton ()
@property (nonatomic, copy) NSString *buttonTitle;
@end

@implementation SlideMenuButton

- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        self.buttonTitle = title;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddRect(context, rect);
    [self.buttonColor set];
    CGContextFillPath(context);
    
    // 添加圆角和白色边框
    UIBezierPath *roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 1, 1) cornerRadius:rect.size.height / 4];
    // 填充色
    [self.buttonColor setFill];
    [roundedRectanglePath fill];
    
    [[UIColor whiteColor] setStroke];
    roundedRectanglePath.lineWidth = 1;
    [roundedRectanglePath stroke];
    
    // CoreText 设置按钮的文字样式
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attr = @{
                           NSParagraphStyleAttributeName : paragraphStyle,
                           NSFontAttributeName : [UIFont systemFontOfSize:24.f],
                           NSForegroundColorAttributeName : [UIColor whiteColor]
                           };
    CGSize size = [self.buttonTitle sizeWithAttributes:attr];
    
    CGRect r = CGRectMake(rect.origin.x, rect.origin.y + (rect.size.height - size.height) / 2.0, rect.size.width, size.height);
    
    [self.buttonTitle drawInRect:r withAttributes:attr];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    NSUInteger tapCount = touch.tapCount;
    switch (tapCount) {
        case 1:
            self.buttonClickBlock();
            break;
            
        default:
            break;
    }
}

@end













