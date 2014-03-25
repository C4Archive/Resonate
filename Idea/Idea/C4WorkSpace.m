//
//  C4WorkSpace.m
//  Idea
//
//  Created by Slant on 2014-03-24.
//

#import "C4Workspace.h"

@implementation C4WorkSpace {
    C4Shape *idea;
}

-(void)setup {
    idea = [C4Shape ellipse:CGRectMake(0, 0, 200, 200)];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddPath(path, nil, idea.path);
    
    C4Shape *title = [C4Shape shapeFromString:@"idea" withFont:[C4Font fontWithName:@"Menlo-Bold" size:36]];
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
    C4Shape *hole = [C4Shape ellipse:CGRectMake(0, 0, 10, 10)];
    
    CGFloat r = [C4Math randomIntBetweenA:50 andB:75];
    
    CGFloat randomAngle = DegreesToRadians(45 - [C4Math randomInt:90]) ;
    
    CGAffineTransform t = CGAffineTransformMakeTranslation(r * cos(randomAngle) + idea.width / 2,
                                                           r * sin(randomAngle) + idea.height / 2);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddPath(path, nil, idea.path);
    CGPathAddPath(path, &t, hole.path);
    
    idea.animationDuration = 0.50f;
    idea.path = path;
    [self runMethod:@"animateHole" afterDelay:1.0f];
}

@end
