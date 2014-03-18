//
//  NOSKPoint.m
//  NOSK
//
//  Created by travis on 2014-03-17.
//  Copyright (c) 2014 Slant. All rights reserved.
//

#import "NOSKPoint.h"

@implementation NOSKPoint {
    NSMutableArray *points;
}
-(id)init {
    return [[NOSKPoint alloc] initWithFrame:CGRectMake(0, 0, 52, 44)];
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self != nil) {
        
        CGFloat yMod = self.height - 13;
        yMod /= 2;
        [self rect:self.frame];
        self.fillColor = [UIColor clearColor];
        self.lineWidth = 0;
        
        CGPoint pts[2] = {CGPointMake(4, 13+yMod),CGPointMake(4, 5+yMod)};
        [C4Shape defaultStyle].lineWidth = 2.0f;
        [C4Shape defaultStyle].strokeColor = C4GREY;
        [self addShape:[C4Shape line:pts]];
        pts[0].x = 0;
        pts[0].y = 9+yMod;
        pts[1].x = 8;
        pts[1].y = 9+yMod;
        [self addShape:[C4Shape line:pts]];
        
        [C4Shape defaultStyle].lineWidth = 0.0f;
        C4Shape *info = [C4Shape shapeFromString:@"INFO" withFont:[C4Font fontWithName:@"helvetica-bold" size:10]];
        info.origin = CGPointMake(10, 12-info.height+yMod);
        info.lineWidth = 0;
        [self addShape:info];
        
        points = [@[] mutableCopy];
        C4Shape *s = [C4Shape ellipse:CGRectMake(0, 0, 6, 6)];
        s.center = CGPointMake(40, 9+yMod);
        [points addObject:s];
        s = [C4Shape ellipse:CGRectMake(0, 0, 6, 6)];
        s.center = CGPointMake(48, 9+yMod);
        [points addObject:s];
        s = [C4Shape ellipse:CGRectMake(0, 0, 6, 6)];
        s.center = CGPointMake(36, 3+yMod);
        [points addObject:s];
        s = [C4Shape ellipse:CGRectMake(0, 0, 6, 6)];
        s.center = CGPointMake(44, 3+yMod);
        [points addObject:s];
        
        [self addObjects:points];
    }
   
    for(C4Shape *s in self.subviews) {
        s.userInteractionEnabled = NO;
    }
    [self randomColors];
    return self;
}

-(void)randomColors {
    for(C4Shape *s in points) {
        s.animationDuration = [C4Math randomInt:4]+6;
        switch ([C4Math randomInt:3]) {
            case 0:
                s.fillColor = C4GREY;
                break;
            case 1:
                s.fillColor = C4BLUE;
                break;
            case 2:
                s.fillColor = C4RED;
                break;
        }
    }
    [self runMethod:@"randomColors" afterDelay:12.0f];
}


-(void)touchesBegan {
    [self postNotification:@"newPoint"];
}

@end
