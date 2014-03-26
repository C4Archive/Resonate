//
//  C4WorkSpace.m
//  Idea
//
//  Created by Slant on 2014-03-24.
//

#import "C4Workspace.h"

@implementation C4WorkSpace {
    C4Shape *idea, *arrow;
    CGPoint holePosition;
}

-(void)setup {
    idea = [C4Shape ellipse:CGRectMake(0, 0, 384, 384)];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddPath(path, nil, idea.path);
    
    C4Shape *title = [C4Shape shapeFromString:@"idea" withFont:[C4Font fontWithName:@"Menlo-Regular" size:36]];
    title.borderWidth = 0.0f;
    CGAffineTransform t = CGAffineTransformMakeTranslation(idea.center.x - title.center.x,
                                                                 idea.center.y - title.center.y);
    CGPathAddPath(path, &t, title.path);
    
    idea.path = path;
    idea.center = self.canvas.center;
    idea.lineWidth = 0.0f;
    idea.fillRule = FILLEVENODD;
    [self.canvas addShape:idea];
    
    [self runMethod:@"animateHole" afterDelay:1.0f];
}

-(void)animateHole {
    C4Shape *hole = [C4Shape ellipse:CGRectMake(0, 0, 6, 6)];
    
    CGFloat r = [C4Math randomIntBetweenA:100 andB:125];
    
    CGFloat randomAngle = DegreesToRadians(45 - [C4Math randomInt:90]) ;
    
    holePosition = CGPointMake(r * cos(randomAngle) + idea.width / 2,
                               r * sin(randomAngle) + idea.height / 2);
    [self createArrow];
    [self addShape:arrow];
    CGAffineTransform t = CGAffineTransformMakeTranslation(holePosition.x,holePosition.y);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddPath(path, nil, idea.path);
    CGPathAddPath(path, &t, hole.path);
    
    idea.animationDuration = 0.50f;
    idea.path = path;
    
    [self runMethod:@"revealArrow:" withObject:arrow afterDelay:2.0f];
}

-(void)createArrow {
    CGMutablePathRef arrowPath = CGPathCreateMutable();
    CGPathMoveToPoint(arrowPath, nil, 218, 15);
    CGPathAddLineToPoint(arrowPath, nil, 190, 28);
    CGPathAddLineToPoint(arrowPath, nil, 192, 20);
    CGPathAddLineToPoint(arrowPath, nil, 0, 20);
    CGPathAddLineToPoint(arrowPath, nil, 0, 15);
    CGPathAddLineToPoint(arrowPath, nil, 0, 10);
    CGPathAddLineToPoint(arrowPath, nil, 192, 10);
    CGPathAddLineToPoint(arrowPath, nil, 190, 2);
    CGPathAddLineToPoint(arrowPath, nil, 218, 15);
    
    CGPathCloseSubpath(arrowPath);
    
    arrow = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    CGAffineTransform t = CGAffineTransformMakeScale(.8, .8);
    arrow.path = CGPathCreateCopyByTransformingPath(arrowPath, &t);
    arrow.anchorPoint = CGPointMake(0, 0.5);
    arrow.lineWidth = 1.0f;
    arrow.fillColor = [UIColor clearColor];
    arrow.strokeColor = C4RED;
    arrow.strokeEnd = 0.5f;
    arrow.strokeStart= 0.5f;
    arrow.anchorPoint = CGPointMake(.005, .425);
//    arrow.center = self.canvas.center;
    arrow.center = [self.canvas convertPoint:holePosition fromView:idea];
    CGPathRelease(arrowPath);
}

-(void)revealArrow:(C4Shape *)anArrow {
    [self.canvas bringSubviewToFront:anArrow];
    anArrow.animationDuration = 0.5f;
    anArrow.animationOptions = EASEOUT;
    anArrow.strokeEnd = 1.0f;
    anArrow.strokeStart = 0.0f;
}


@end
