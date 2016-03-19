//
//  ViewController.m
//  AnimationDemo_Circle
//
//  Created by 陈知行 on 16/3/13.
//  Copyright © 2016年 陈知行. All rights reserved.
//

#import "ViewController.h"
#import "CircleView.h"
#import "CircleLayer.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *currentValue;
@property (weak, nonatomic) IBOutlet UISlider *valueSlider;
@property (nonatomic, strong) CircleView *cv;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.valueSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.cv = [[CircleView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 300/2, self.view.frame.size.height/2 - 300/2, 300, 300)];
    [self.cv setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:self.cv];
    
    //首次进入
    self.cv.circleLayer.progress = _valueSlider.value;
}

- (void)valueChanged:(UISlider *)sender {
    self.currentValue.text = [NSString stringWithFormat:@"Current:  %f",sender.value];
    self.cv.circleLayer.progress = sender.value;
}

@end
