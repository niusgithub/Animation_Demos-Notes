//
//  ViewController.m
//  AnimationDemo_slideMenu
//
//  Created by 陈知行 on 16/3/15.
//  Copyright © 2016年 陈知行. All rights reserved.
//

#import "ViewController.h"
#import "GooeySlideMenu.h"

@interface ViewController ()

@end

@implementation ViewController {
    GooeySlideMenu *menu;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    menu = [[GooeySlideMenu alloc] initWithTitles:@[@"首页",@"消息",@"发布",@"发现",@"个人",@"设置"]];
    menu.menuClickBlock = ^(NSInteger index,NSString *title,NSInteger titleCounts){
        NSLog(@"index:%ld title:%@ titleCounts:%ld",index,title,titleCounts);
    };
}

- (IBAction)pullTheTrigger {
    [menu trigger];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
