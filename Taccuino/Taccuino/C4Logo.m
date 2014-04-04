//
//  C4Logo.m
//  Thanks
//
//  Created by Slant on 2014-04-03.
//  Copyright (c) 2014 Slant. All rights reserved.
//

#import "C4Logo.h"

@implementation C4Logo {
    NSArray *colors;
    BOOL hasStarted;
}

-(void)setup {
    colors = @[C4GREY,C4BLUE,C4RED];
    
    CGPoint cPoints[8] = {
        CGPointMake(0, 0),
        CGPointMake(20, 0),
        CGPointMake(20,10),
        CGPointMake(10, 10),
        CGPointMake(10, 30),
        CGPointMake(30, 30),
        CGPointMake(30, 40),
        CGPointMake(0, 40)
    };
    
    C4Shape *c = [C4Shape polygon:cPoints pointCount:8];
    c.fillColor = C4GREY;
    c.lineWidth = 0;
    
    CGPoint pts[4] = {
        CGPointMake(20, 0),
        CGPointMake(30, 0),
        CGPointMake(30, 10),
        CGPointMake(20, 10)
    };
    C4Shape *pt = [C4Shape polygon:pts pointCount:4];
    pt.fillColor = C4BLUE;
    pt.lineWidth = 0;
    
    CGPoint fourPts[14] = {
        CGPointMake(20, 10),
        CGPointMake(30, 10),
        CGPointMake(30, 20),
        CGPointMake(40, 20),
        CGPointMake(40, 0),
        CGPointMake(50, 0),
        CGPointMake(50, 20),
        CGPointMake(60, 20),
        CGPointMake(60, 30),
        CGPointMake(50, 30),
        CGPointMake(50, 40),
        CGPointMake(40, 40),
        CGPointMake(40, 30),
        CGPointMake(20, 30)
    };
    C4Shape *four = [C4Shape polygon:fourPts pointCount:14];
    four.fillColor = C4RED;
    four.lineWidth = 0;
    
    [self addObjects:@[c, pt, four]];
    c.userInteractionEnabled = NO;
    pt.userInteractionEnabled = NO;
    four.userInteractionEnabled = NO;
    
    [self runMethod:@"randomColors" afterDelay:1.0f];
}

-(void)randomColors {
    for(C4Shape *s in self.subviews) {
        s.animationDuration = [C4Math randomInt:4]+6;
        s.fillColor = colors[[C4Math randomInt:3]];
    }
    [self runMethod:@"randomColors" afterDelay:10.0f];
}

-(void)touchesBegan {
    if(!hasStarted) {
        [self postNotification:@"startNotification"];
        hasStarted = YES;
    } else {
        [self postNotification:@"restartNotification"];
    }
}

@end
