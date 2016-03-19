//
//  CircleLayer.m
//  AnimationDemo_Circle
//
//  Created by 陈知行 on 16/3/13.
//  Copyright © 2016年 陈知行. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleLayer.h"

typedef NS_ENUM(NSInteger, MovingDrection) {
    MDRight,
    MDLeft
};

static const CGFloat outsideRectSize = 100;

@interface CircleLayer ()

/**
 *  外接矩形
 */
@property (nonatomic, assign) CGRect outsideRect;

/**
 *  前一次的progress，根据差值计算移动方向
 */
@property (nonatomic, assign) CGFloat lastProgress;

/**
 *  实时记录圆在相对layer中心方向
 */
@property (nonatomic, assign) MovingDrection drection;

@end

@implementation CircleLayer {
    
}

- (instancetype)init {
    if (self = [super init]) {
        self.lastProgress = 0.5;
    }
    return self;
}

- (instancetype)initWithLayer:(CircleLayer *)layer {
    if (self = [super initWithLayer:layer]) {
        self.progress = layer.progress;
        self.outsideRect = layer.outsideRect;
        self.lastProgress = layer.lastProgress;
    }
    return self;
}


- (void)drawInContext:(CGContextRef)ctx {
    
    // 3阶贝塞尔曲线拟合1/4的具体数学知识参见 http://blog.csdn.net/nibiewuxuanze/article/details/48103059
    
    // A-P1、B-P2... 的距离，当设置为正方形边长的1/3.6倍时，画出来的圆弧完美贴合圆形
    CGFloat offset = self.outsideRect.size.width / 3.6;
    
    // A.B.C.D实际需要移动的距离.系数为滑块偏离中点0.5的绝对值再乘以2.当滑到两端的时候，movedDistance为最大值：「外接矩形宽度的1/6」
    CGFloat movedDistance = (self.outsideRect.size.width / 6) * fabs(self.progress -  0.5) * 2;
    
    // 外接矩形中心点坐标
    CGPoint rectCenter = CGPointMake(self.outsideRect.origin.x + self.outsideRect.size.width / 2, self.outsideRect.origin.y + self.outsideRect.size.height / 2);
    
    // 各个点坐标,由圆上顶点A开始顺时针分别是A，P1，P2，B，P3，P4，C，P5，P6，D，P7，P8。
    CGPoint pointA = CGPointMake(rectCenter.x, self.outsideRect.origin.y + movedDistance);
    CGPoint pointB = CGPointMake(rectCenter.x + self.outsideRect.size.width / 2 + (self.drection ==  MDRight ? 0 : movedDistance * 2), rectCenter.y);
    CGPoint pointC = CGPointMake(rectCenter.x, rectCenter.y + self.outsideRect.size.height / 2 - movedDistance);
    CGPoint pointD = CGPointMake(rectCenter.x - self.outsideRect.size.width / 2 - (self.drection ==  MDLeft ? 0 : movedDistance * 2), rectCenter.y);
    
    CGPoint P1 = CGPointMake(pointA.x + offset, pointA.y);
    CGPoint P2 = CGPointMake(pointB.x, pointB.y - offset + (self.drection == MDRight ? 0 : movedDistance));
    
    CGPoint P3 = CGPointMake(pointB.x, pointB.y + offset - (self.drection == MDRight ? 0 : movedDistance));
    CGPoint P4 = CGPointMake(pointC.x + offset, pointC.y);
    
    CGPoint P5 = CGPointMake(pointC.x - offset, pointC.y);
    CGPoint P6 = CGPointMake(pointD.x, pointD.y + offset - (self.drection == MDLeft ? 0 : movedDistance));
    
    CGPoint P7 = CGPointMake(pointD.x, pointD.y - offset + (self.drection == MDLeft ? 0 : movedDistance));
    CGPoint P8 = CGPointMake(pointA.x - offset, pointA.y);

    //外接虚线矩形
    UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:self.outsideRect];
    CGContextAddPath(ctx, rectPath.CGPath);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(ctx, 1.0);
    CGFloat dash[] = {5.0, 5.0};
    CGContextSetLineDash(ctx, 0.0, dash, 2); //1
    CGContextStrokePath(ctx); //给线条填充颜色
    
    
    //圆的边界
    UIBezierPath* ovalPath = [UIBezierPath bezierPath];
    [ovalPath moveToPoint: pointA];
    [ovalPath addCurveToPoint:pointB controlPoint1:P1 controlPoint2:P2];
    [ovalPath addCurveToPoint:pointC controlPoint1:P3 controlPoint2:P4];
    [ovalPath addCurveToPoint:pointD controlPoint1:P5 controlPoint2:P6];
    [ovalPath addCurveToPoint:pointA controlPoint1:P7 controlPoint2:P8];
    [ovalPath closePath];
    
    CGContextAddPath(ctx, ovalPath.CGPath);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextSetLineDash(ctx, 0, NULL, 0); //2
    CGContextDrawPath(ctx, kCGPathFillStroke); //同时给线条和线条包围的内部区域填充颜色
    
    
    //标记出每个点并连线，方便观察，给所有关键点染色 -- 白色,辅助线颜色 -- 白色
    //语法糖：字典@{}，数组@[]，基本数据类型封装成对象@234，@12.0，@YES,@(234+12.0)
    CGContextSetFillColorWithColor(ctx, [UIColor yellowColor].CGColor);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    NSArray *points = @[
                        [NSValue valueWithCGPoint:pointA],
                        [NSValue valueWithCGPoint:pointB],
                        [NSValue valueWithCGPoint:pointC],
                        [NSValue valueWithCGPoint:pointD],
                        [NSValue valueWithCGPoint:P1],
                        [NSValue valueWithCGPoint:P2],
                        [NSValue valueWithCGPoint:P3],
                        [NSValue valueWithCGPoint:P4],
                        [NSValue valueWithCGPoint:P5],
                        [NSValue valueWithCGPoint:P6],
                        [NSValue valueWithCGPoint:P7],
                        [NSValue valueWithCGPoint:P8]
                        ];
    [self drawPoint:points withContext:ctx];
    
    //连接辅助线
    UIBezierPath *helperline = [UIBezierPath bezierPath];
    [helperline moveToPoint:pointA];
    [helperline addLineToPoint:P1];
    [helperline addLineToPoint:P2];
    [helperline addLineToPoint:pointB];
    [helperline addLineToPoint:P3];
    [helperline addLineToPoint:P4];
    [helperline addLineToPoint:pointC];
    [helperline addLineToPoint:P5];
    [helperline addLineToPoint:P6];
    [helperline addLineToPoint:pointD];
    [helperline addLineToPoint:P7];
    [helperline addLineToPoint:P8];
    [helperline closePath];
    
    CGContextAddPath(ctx, helperline.CGPath);
    
    CGFloat dash2[] = {2.0, 2.0};
    CGContextSetLineDash(ctx, 0.0, dash2, 2);
    CGContextStrokePath(ctx); //给辅助线条填充颜色
    
}

//标记每一个点，方便观察运动情况
- (void)drawPoint:(NSArray *)points withContext:(CGContextRef)ctx {
    for (NSValue *pointValue in points) {
        CGPoint point = [pointValue CGPointValue];
        CGContextFillRect(ctx, CGRectMake(point.x - 2, point.y - 2, 4, 4));
    }
}


- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    
    if (progress <= 0.5) {
        self.drection = MDLeft;
    } else {
        self.drection = MDRight;
    }
    
    /**
     *  outsideRectSize 表示圆外接矩形的边长
     *
     *  以外接矩形的左上角的点为原点
     *
     *  self.position.x - outsideRectSize/2 表示圆外接矩形的原点当progress ＝ 0.5，即在layer中心时的坐标
     *
     *  self.frame.size.width - outsideRectSize 为progress在0～1之间变化时可以移动的范围，progress ＝0时原点在左边界上，progress ＝ 1时外接矩形右边界与layer的右边界重合，原点X坐标为self.frame.size.width - oustsideRectSize
     *
     *
     *  原点Y坐标同理可求，由于圆只是水平移动故无需考虑progress的值
     */
    
    self.lastProgress = progress;
    
    CGFloat outsideRectX = self.position.x - outsideRectSize / 2 + (progress - 0.5) * (self.frame.size.width - outsideRectSize);
    
    CGFloat outsideRectY = self.position.y - outsideRectSize / 2;
    
    self.outsideRect = CGRectMake(outsideRectX, outsideRectY, outsideRectSize, outsideRectSize);
    
    /**
     *  当progress值改变时时调用setNeedDisplay会调用 -(void)drawInContext:(CGContextRef)ctx 方法重绘圆
     */
    [self setNeedsDisplay];
}


@end
