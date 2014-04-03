//
//  C4WorkSpace.m
//  bg4
//
//  Created by Slant on 2014-04-01.
//

#import "C4Workspace.h"

@implementation C4WorkSpace

-(void)setup {
    for(int x = -self.canvas.height, i = 0; x < self.canvas.width; x += 20, i++) {
        CGPoint pts[2] = {CGPointMake(x, 0),CGPointMake(x + self.canvas.height, self.canvas.height)};
        C4Shape *line = [C4Shape line:pts];
        line.lineWidth = 0.25f;
        [self.canvas addShape:line];
        [self runMethod:@"animate:" withObject:line afterDelay:i * 0.25f];
    }
}

-(void)animate:(C4Shape *)line {
    line.animationDuration = 20.0f;
    line.animationOptions = REPEAT;
    line.rotation = PI;
}

@end
