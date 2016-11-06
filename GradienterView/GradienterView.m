//
//  GradienterView.m
//  S2iPhone
//
//  Created by Pai Peng on 04/11/2016.
//  Copyright © 2016 paipeng.com All rights reserved.
//

#import "GradienterView.h"
#import <CoreMotion/CoreMotion.h>

#define MUL 20
#define TIME 10.0
#define S2iColorAlpha(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

@interface GradienterView ()
{
    CMMotionManager *cmManager;
}
@end

@implementation GradienterView


- (id) initWithFrame: (CGRect) frame {
    self = [super initWithFrame:frame];
    NSLog(@"initWithFrame %@", NSStringFromCGRect(frame));
    //UIView* helpView = [[UIView alloc] initWithFrame:frame];
    [self setBackgroundColor:S2iColorAlpha(0, 0, 0, 0.2)];
    
    cmManager = [[CMMotionManager alloc] init];
    if ([cmManager isAccelerometerAvailable]) {
        cmManager.accelerometerUpdateInterval = 1.0/TIME;
        [cmManager startAccelerometerUpdates];
        //accelerometerLabel.text = @"Accelerometer Available!";
    }
    [NSTimer scheduledTimerWithTimeInterval:1.0/TIME
                                     target:self
                                   selector:@selector(cmTime:)
                                   userInfo:nil
                                    repeats:YES];
    return self;
}

- (void)cmTime:(NSTimer *) theTime
{
    
    // informacoes do acelerometro
    CMAccelerometerData *accelerometer = [cmManager accelerometerData];
    
    
    _point = [self calculateGradienterPoint:accelerometer.acceleration];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

- (CGPoint) calculateGradienterPoint: (CMAcceleration) acceleration {
    CGPoint gradienterPoint;
    
    NSInteger factor = 4;
    gradienterPoint.x = self.bounds.size.width/2.0 - self.bounds.size.width/2.0*factor * acceleration.x;
    gradienterPoint.y = self.bounds.size.height/2 + self.bounds.size.height/2.0*factor * acceleration.y;
    
    if ( gradienterPoint.x < 0) {
        gradienterPoint.x = 0;
    } else if (gradienterPoint.x > self.bounds.size.width) {
        gradienterPoint.x = self.bounds.size.width;
    }
    if (gradienterPoint.y < 0) {
        gradienterPoint.y = 0;
    } else if (gradienterPoint.y > self.bounds.size.height) {
        gradienterPoint.y = self.bounds.size.height;
    }
    
    return gradienterPoint;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // Drawing code
    
    //获得处理的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    //指定直线样式
    CGContextSetLineCap(context, kCGLineCapButt);
    
    //直线宽度
    CGContextSetLineWidth(context, 1.0);
    
    
    // draw rect line
    //设置颜色
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.3);
    CGPoint aPoints[5];//坐标点
    aPoints[0] =CGPointMake(0, 0);//坐标1
    aPoints[1] =CGPointMake(rect.size.width, 0);//坐标2
    aPoints[2] =CGPointMake(rect.size.width, rect.size.height);//坐标2
    aPoints[3] =CGPointMake(0, rect.size.height);//坐标2
    aPoints[4] =CGPointMake(0, 0);//坐标1
    
    
    //CGContextAddLines(CGContextRef c, const CGPoint points[],size_t count)
    //points[]坐标数组，和count大小
    CGContextAddLines(context, aPoints, 5);//添加线
    CGContextDrawPath(context, kCGPathStroke); //根据坐标绘制路径
    
    
    
    aPoints[0] =CGPointMake(rect.size.width/2, 0);//坐标1
    aPoints[1] =CGPointMake(rect.size.width/2, rect.size.height);//坐标2
    CGContextAddLines(context, aPoints, 2);//添加线
    CGContextDrawPath(context, kCGPathStroke); //根据坐标绘制路径
    
    
    aPoints[0] =CGPointMake(0, rect.size.height/2);//坐标1
    aPoints[1] =CGPointMake(rect.size.width, rect.size.height/2);//坐标2
    CGContextAddLines(context, aPoints, 2);//添加线
    CGContextDrawPath(context, kCGPathStroke); //根据坐标绘制路径
    
    // draw point
    CGContextAddArc(context, _point.x, _point.y, 4, 0, 2*3.1415926, 0); //添加一个圆
    //CGContextDrawPath(context, kCGPathStroke); //绘制路径
    //CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
    //
    UIColor*aColor = [UIColor colorWithRed:40/255.0 green:175/255.0 blue:99/255.0 alpha:1];
    CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
    CGContextDrawPath(context, kCGPathFill);//绘制填充
    
    //填充圆，无边框
    //CGContextAddArc(context, 150, 20, 30, 0, 2*3.1415926, 0); //添加一个圆
    //CGContextDrawPath(context, kCGPathFill);//绘制填充
    
    //绘制完成
    CGContextStrokePath(context);
}

@end
