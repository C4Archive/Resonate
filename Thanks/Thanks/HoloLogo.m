//
//  HoloLogo.m
//  Thanks
//
//  Created by Slant on 2014-04-03.
//  Copyright (c) 2014 Slant. All rights reserved.
//

#import "HoloLogo.h"

@implementation HoloLogo {
    NSMutableArray *lines;
}

-(void)setup {
    C4Shape *s;
    s = [C4Shape rect:CGRectMake(0, 0, 160, 160)];
    s.fillColor = [UIColor clearColor];
    s.lineWidth = 0;
    
    [self addShape:s];
    CGFloat a = 0;
    CGFloat r = 140;
    CGPoint pts[8];
    for (int i = 0; i < 8; i++) {
        a = i * TWO_PI / 8.0;
        pts[i] = CGPointMake(r * [C4Math cos:a], r * [C4Math sin:a]);
    }
    C4Shape *poly = [C4Shape polygon:pts pointCount:8];
    [poly closeShape];
    poly.center = s.center;
    s.mask = poly;
    s.center = self.center;
    
    CGPoint p[64] = {
        CGPointMake(150.00,75.00),
        CGPointMake(148.58,59.28),
        CGPointMake(144.32,44.92),
        CGPointMake(137.53,32.16),
        CGPointMake(128.60,21.32),
        CGPointMake(117.65,12.50),
        CGPointMake(104.80,5.88),
        CGPointMake(90.40,1.77),
        CGPointMake(74.80,0.40),
        CGPointMake(59.23,1.77),
        CGPointMake(44.92,5.88),
        CGPointMake(32.13,12.50),
        CGPointMake(21.20,21.32),
        CGPointMake(12.30,32.16),
        CGPointMake(5.60,44.92),
        CGPointMake(1.40,59.28),
        CGPointMake(0.00,75.00),
        CGPointMake(1.40,90.88),
        CGPointMake(5.60,105.32),
        CGPointMake(12.30,118.01),
        CGPointMake(21.20,128.72),
        CGPointMake(32.13,137.33),
        CGPointMake(44.92,143.80),
        CGPointMake(59.23,147.85),
        CGPointMake(74.80,149.20),
        CGPointMake(90.40,147.85),
        CGPointMake(104.80,143.80),
        CGPointMake(117.65,137.33),
        CGPointMake(128.60,128.72),
        CGPointMake(137.53,118.01),
        CGPointMake(144.32,105.32),
        CGPointMake(148.58,90.88),
        CGPointMake(128.60,75.00),
        CGPointMake(127.65,86.28),
        CGPointMake(124.80,96.92),
        CGPointMake(120.20,106.58),
        CGPointMake(114.00,115.00),
        CGPointMake(106.27,121.98),
        CGPointMake(97.08,127.32),
        CGPointMake(86.57,130.68),
        CGPointMake(74.80,131.80),
        CGPointMake(63.18,130.68),
        CGPointMake(52.72,127.32),
        CGPointMake(43.56,121.98),
        CGPointMake(35.92,115.00),
        CGPointMake(29.78,106.58),
        CGPointMake(25.20,96.92),
        CGPointMake(22.35,86.28),
        CGPointMake(21.40,75.00),
        CGPointMake(22.35,63.55),
        CGPointMake(25.20,52.80),
        CGPointMake(29.80,43.08),
        CGPointMake(36.00,34.72),
        CGPointMake(43.70,27.83),
        CGPointMake(52.80,22.60),
        CGPointMake(63.20,19.30),
        CGPointMake(74.80,18.20),
        CGPointMake(86.45,19.30),
        CGPointMake(97.00,22.60),
        CGPointMake(106.25,27.83),
        CGPointMake(114.00,34.72),
        CGPointMake(120.20,43.08),
        CGPointMake(124.80,52.80),
        CGPointMake(127.65,63.55),
    };
    
    lines = [@[] mutableCopy];
    for(int i = 0; i < 64; i++) {
        int step = i;
        if( step >= 64) step -= 64;
        CGFloat angle = step / 64.0f;
        angle = TWO_PI * angle - PI;
        
        CGFloat r = 300;
        CGFloat x = r * [C4Math cos:angle];
        CGFloat y = r * [C4Math sin:angle];
        x += s.width / 2;
        y += s.height / 2;
        
        CGPoint pts[2] = {p[i], CGPointMake(x, y)};
        C4Shape *line = [C4Shape line:pts];
        line.strokeColor = [UIColor blackColor];
        line.lineWidth = 1.f;
        CGPoint anchorPoint = CGPointMake(0, 0);
        anchorPoint.x = line.pointA.x > line.pointB.x ? 1 : 0;
        anchorPoint.y = line.pointA.y > line.pointB.y ? 1 : 0;
        line.anchorPoint = anchorPoint;
        [lines addObject:line];
        [s addShape: line];
    }
}

-(void)startAnimating {
    for(C4Shape *sub in lines ) {
        sub.animationDuration = 15.0f + (lines.count - [lines indexOfObject:sub]) * 2.0 / lines.count;
        sub.animationOptions = LINEAR | REPEAT;
        sub.rotation = TWO_PI;
    }
}

@end
