//
//  GooeySlideMenu.m
//  AnimationDemo_slideMenu
//
//  Created by 陈知行 on 16/3/15.
//  Copyright © 2016年 陈知行. All rights reserved.
//

#import "GooeySlideMenu.h"
#import "SlideMenuButton.h"

static const CGFloat menuBlankWidth = 50;
static const CGFloat buttonSpace = 30;

@interface GooeySlideMenu ()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSInteger animationCount; // 动画计数器

@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIView *helperSideView; // 边际辅助视图
@property (nonatomic, strong) UIView *helperCenterView; // 中央辅助视图
@property (nonatomic, strong) UIWindow *kWindow;
@property (nonatomic, assign) BOOL triggered;
@property (nonatomic, assign) CGFloat delta;
@property (nonatomic, strong) UIColor *menuColor;
@property (nonatomic, assign) CGFloat menuButtonHeight;

@end

@implementation GooeySlideMenu

- (instancetype)initWithTitles:(NSArray *)titles {
    return [self initWithTitles:titles buttonHeight:40.f menuColor:[UIColor colorWithRed:0 green:0.722 blue:1 alpha:1] backBlurStyle:UIBlurEffectStyleDark];
}

- (instancetype)initWithTitles:(NSArray *)titles
                  buttonHeight:(CGFloat)height
                     menuColor:(UIColor *)menuColor
                 backBlurStyle:(UIBlurEffectStyle)style {
    if (self = [super init]) {
        // 直接在storyBoard中的ViewControlller添加trigger按钮使用时，AppDelegate未调用makeKeyAndVisible获取不到keywindow
        // 解决办法将当前ViewController添加进一个NavigationController
        self.kWindow = [[UIApplication sharedApplication] keyWindow];
        self.blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:style]];
        self.blurView.frame = self.kWindow.frame;
        self.blurView.alpha = 0.0f;
        
        // 边际辅助视图
        _helperSideView = [[UIView alloc] initWithFrame:CGRectMake(-20, 0, 20, 20)];
        _helperSideView.backgroundColor = [UIColor redColor];
//        _helperSideView.hidden = YES;
        [_kWindow addSubview:_helperSideView];
        
        // 中央辅助视图
        _helperCenterView = [[UIView alloc] initWithFrame:CGRectMake(-20, CGRectGetHeight(_kWindow.frame) / 2 - 10, 20, 20)];
        _helperCenterView.backgroundColor = [UIColor yellowColor];
//        _helperCenterView.hidden = YES;
        [_kWindow addSubview:_helperCenterView];
        
        self.frame = CGRectMake(- _kWindow.frame.size.width / 2 - menuBlankWidth, 0, _kWindow.frame.size.width / 2 + menuBlankWidth, _kWindow.frame.size.height);
        self.backgroundColor = [UIColor clearColor];
        [_kWindow insertSubview:self belowSubview:_helperSideView];
        
        self.menuColor = menuColor;
        self.menuButtonHeight = height;
        
        [self addButtons:titles];
    }
    return self;
}

- (void)addButtons:(NSArray *)titles {
    if (titles.count % 2 == 0) { // 按钮数为偶数时的布局
        NSInteger index_down = titles.count / 2;
        NSInteger index_up = -1;
        
        // 另一种遍历方式
        //[titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //
        //}];
        
        for (NSInteger i = 0; i < titles.count; ++i) {
            NSString *title = titles[i];
            SlideMenuButton *home_button = [[SlideMenuButton alloc]initWithTitle:title];
            if (i >= titles.count / 2) {
                index_up ++;
                home_button.center = CGPointMake(_kWindow.frame.size.width/4, _kWindow.frame.size.height/2 + _menuButtonHeight*index_up + buttonSpace*index_up + buttonSpace/2 + _menuButtonHeight/2);
            }else{
                index_down --;
                home_button.center = CGPointMake(_kWindow.frame.size.width/4, _kWindow.frame.size.height/2 - _menuButtonHeight*index_down - buttonSpace*index_down - buttonSpace/2 - _menuButtonHeight/2);
            }
            
            home_button.bounds = CGRectMake(0, 0, _kWindow.frame.size.width/2 - 20*2, _menuButtonHeight);
            home_button.buttonColor = _menuColor;
            [self addSubview:home_button];
            
            __weak typeof(self) WeakSelf = self;
            home_button.buttonClickBlock = ^(){
                [WeakSelf tapToUntrigger];
                WeakSelf.menuClickBlock(i,title,titles.count);
            };
        }
        
    }else{
        NSInteger index = (titles.count - 1) /2 +1;
        for (NSInteger i = 0; i < titles.count; i++) {
            index --;
            NSString *title = titles[i];
            SlideMenuButton *home_button = [[SlideMenuButton alloc]initWithTitle:title];
            home_button.center = CGPointMake(_kWindow.frame.size.width/4, _kWindow.frame.size.height/2 - _menuButtonHeight*index - 20*index);
            home_button.bounds = CGRectMake(0, 0, _kWindow.frame.size.width/2 - 20*2, _menuButtonHeight);
            home_button.buttonColor = _menuColor;
            [self addSubview:home_button];
            
            __weak typeof(self) WeakSelf = self;
            home_button.buttonClickBlock = ^(){
                [WeakSelf tapToUntrigger];
                WeakSelf.menuClickBlock(i,title,titles.count);
            };
        }
    }
    
}

- (void)drawRect:(CGRect)rect {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(self.frame.size.width-menuBlankWidth, 0)];
    [path addQuadCurveToPoint:CGPointMake(self.frame.size.width-menuBlankWidth, self.frame.size.height) controlPoint:CGPointMake(_kWindow.frame.size.width / 2 + _delta, _kWindow.frame.size.height/2)];
    [path addLineToPoint:CGPointMake(0, self.frame.size.height)];
    [path closePath];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddPath(context, path.CGPath);
    [_menuColor set];
    CGContextFillPath(context);
}

-(void)trigger{
    if (!_triggered) {
        [_kWindow insertSubview:_blurView belowSubview:self];
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = self.bounds;
        }];
        
        [self beforeAnimation];
        [UIView animateWithDuration:0.7 delay:0.0f usingSpringWithDamping:0.5f initialSpringVelocity:0.9f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
            _helperSideView.center = CGPointMake(_kWindow.center.x, _helperSideView.frame.size.height/2);
        } completion:^(BOOL finished) {
            [self finishAnimation];
        }];
        
        [UIView animateWithDuration:0.3 animations:^{
            _blurView.alpha = 1.0f;
        }];
        
        [self beforeAnimation];
        [UIView animateWithDuration:0.7 delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:2.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
            _helperCenterView.center = _kWindow.center;
        } completion:^(BOOL finished) {
            if (finished) {
                UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToUntrigger)];
                [_blurView addGestureRecognizer:tapGes];
                [self finishAnimation];
            }
        }];
        [self animateButtons];
        _triggered = YES;
    }else{
        [self tapToUntrigger];
    }
}

-(void)animateButtons{
    for (NSInteger i = 0; i < self.subviews.count; i++) {
        
        UIView *menuButton = self.subviews[i];
        menuButton.transform = CGAffineTransformMakeTranslation(-90, 0);
        [UIView animateWithDuration:0.7 delay:i*(0.3/self.subviews.count) usingSpringWithDamping:0.6f initialSpringVelocity:0.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
            menuButton.transform =  CGAffineTransformIdentity;
        } completion:NULL];
    }
    
}

-(void)tapToUntrigger{
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(-_kWindow.frame.size.width/2-menuBlankWidth, 0, _kWindow.frame.size.width/2+menuBlankWidth, _kWindow.frame.size.height);
    }];
    
    [self beforeAnimation];
    [UIView animateWithDuration:0.7 delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:0.9f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
        _helperSideView.center = CGPointMake(-_helperSideView.frame.size.height/2, _helperSideView.frame.size.height/2);
    } completion:^(BOOL finished) {
        [self finishAnimation];
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        _blurView.alpha = 0.0f;
    }];
    
    [self beforeAnimation];
    [UIView animateWithDuration:0.7 delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:2.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction animations:^{
        _helperCenterView.center = CGPointMake(-_helperSideView.frame.size.height/2, CGRectGetHeight(_kWindow.frame)/2);
    } completion:^(BOOL finished) {
        [self finishAnimation];
    }];
    
    _triggered = NO;
    
}

//动画之前调用
-(void)beforeAnimation{
    if (self.displayLink == nil) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    self.animationCount ++;
}

//动画完成之后调用
-(void)finishAnimation{
    self.animationCount --;
    if (self.animationCount == 0) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

-(void)displayLinkAction:(CADisplayLink *)dis{
    
    CALayer *sideHelperPresentationLayer   =  (CALayer *)[_helperSideView.layer presentationLayer];
    CALayer *centerHelperPresentationLayer =  (CALayer *)[_helperCenterView.layer presentationLayer];
    
    CGRect centerRect = [[centerHelperPresentationLayer valueForKeyPath:@"frame"]CGRectValue];
    CGRect sideRect = [[sideHelperPresentationLayer valueForKeyPath:@"frame"]CGRectValue];
    
    _delta = sideRect.origin.x - centerRect.origin.x;
    
    [self setNeedsDisplay];
    
}

@end