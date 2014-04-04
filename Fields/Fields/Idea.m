    //
//  Idea.m
//  Fields
//
//  Created by Slant on 2014-04-04.
//  Copyright (c) 2014 Slant. All rights reserved.
//

#import "Idea.h"

@implementation Idea {
    C4Shape *idea, *arrow, *pulse;
    CGPoint holePosition, holePositionInCanvas;
}

-(void)setupWithText:(NSString *)text {
    idea = [C4Shape ellipse:self.bounds];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddPath(path, nil, idea.path);
    
    C4Shape *title = [C4Shape shapeFromString:text withFont:[C4Font fontWithName:@"Menlo-Regular" size:28]];
    title.borderWidth = 0.0f;
    CGAffineTransform t = CGAffineTransformMakeTranslation(idea.center.x - title.center.x,
                                                           idea.center.y - title.center.y);
    CGPathAddPath(path, &t, title.path);
    
    idea.path = path;
    idea.center = self.center;
    idea.lineWidth = 0.0f;
    idea.fillRule = FILLEVENODD;
    idea.clipsToBounds = YES;
    [self addShape:idea];
}

-(void)animateHole {
    C4Shape *hole = [C4Shape ellipse:CGRectMake(0, 0, 6, 6)];
    
    CGFloat r = [C4Math randomIntBetweenA:45 andB:60];
    
    CGFloat randomAngle = DegreesToRadians(45 + [C4Math randomInt:90]) ;
    
    holePosition = CGPointMake(r * cos(randomAngle),
                               r * sin(randomAngle));
    holePositionInCanvas.x = holePosition.x + idea.width / 2;
    holePositionInCanvas.y = holePosition.y + idea.height / 2;
    CGAffineTransform t = CGAffineTransformMakeTranslation(holePositionInCanvas.x,holePositionInCanvas.y);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddPath(path, nil, idea.path);
    CGPathAddPath(path, &t, hole.path);
    
    idea.animationDuration = 0.50f;
    idea.path = path;
    
    [self runMethod:@"createPulse" afterDelay:1.0f];
}

-(void)createPulse {
    pulse = [C4Shape ellipse:CGRectMake(holePositionInCanvas.x, holePositionInCanvas.y, 4, 4)];
    pulse.fillColor = [UIColor clearColor];
    pulse.lineWidth = 5.0f;
    pulse.strokeColor = [UIColor whiteColor];
    pulse.alpha = 0.0f;
    [idea addShape:pulse];
}

-(void)animatePulse {
    pulse.animationDuration = 2.0f;
    pulse.animationOptions = EASEIN | REPEAT;
    [pulse ellipse:CGRectMake(0, 0, 280, 280)];
    pulse.center = holePositionInCanvas;
    pulse.lineWidth = 0.0f;
    pulse.alpha = 1.0f;
}

@end
