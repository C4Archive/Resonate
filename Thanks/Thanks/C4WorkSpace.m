//
//  C4WorkSpace.m
//  Thanks
//
//  Created by Slant on 2014-03-24.
//

#import "C4Workspace.h"

#import "C4Workspace.h"

@implementation C4WorkSpace {
    NSArray *names;
    C4Shape *current;
    NSInteger nameIndex;
}

-(void)setup {
    [C4Shape defaultStyle].lineWidth = 0.0f;
    
    nameIndex = 0;
    names = @[@"buza",
              @"@gregtemp",
              @"@adamtindale",
              @"@kulturlab",
              @"@jaymecochrane",
              @"@_brady",
              @"@davidpenuelab",
              @"sheelagh carpendale",
              @"@dominikus",
              @"@sebastianboring",
              @"@vidkidlinds",
              @"jakemakes.com",
              @"@tangibleint",
              @"@nickpagee",
              @"a-coding.com",
              ];
    
    [self runMethod:@"showNextName" afterDelay:1.0f];
}

-(void)showNextName {
    C4Font *font = [C4Font fontWithName:@"Menlo-Bold" size:48];
    C4Shape *nextShape;
    
    if(nameIndex < names.count) {
        nextShape = [C4Shape shapeFromString:names[nameIndex] withFont:font];
        nextShape.alpha = 0.0f;
        nextShape.center = CGPointMake(self.canvas.center.x, self.canvas.center.y + 100);
        [self.canvas addShape:nextShape];
    }
    [self fadeCurrentRevealNext:nextShape];
    nameIndex++;
    if (nameIndex <= names.count) {
        [self runMethod:@"showNextName" afterDelay:2.0f];
    }
}

-(void)fadeCurrentRevealNext:(C4Shape *)nextShape {
    if(current != nil) {
        current.animationDuration = 1.0f;
        current.center = CGPointMake(self.canvas.center.x, self.canvas.center.y - 100);
        current.alpha = 0.0f;
        [current runMethod:@"removeFromSuperview" afterDelay:1.1f];
        current = nil;
    }
    
    if(nextShape != nil) {
        nextShape.animationDuration = 1.0f;
        nextShape.center = self.canvas.center;
        nextShape.alpha = 1.0f;
        current = nextShape;
    }
}

@end