//
//  C4WorkSpace.m
//  NOSK
//
//  Created by travis on 2014-03-17.
//

#import "C4Workspace.h"
#import "NOSKPoint.h"

@implementation C4WorkSpace {
    CGPoint innerTargets[36];
    CGPoint outerTargets[72];
    NSMutableArray *allShapes;
    NSMutableArray *remainingInnerLocations, *remainingOuterLocations;
    NSMutableArray *connections;
}

-(void)setup {
    allShapes = [@[] mutableCopy];
    
    [self createConnections];
    
    [self createTargetPoints];
    [C4Shape defaultStyle].lineWidth = 0;
    for(int i = 0; i < 37; i++) {
        NOSKPoint *p = [NOSKPoint new];
        p.center = self.canvas.center;
        p.userInteractionEnabled = YES;
        p.tag = i;
        [allShapes addObject:p];
    }
    [self.canvas addObjects:allShapes];
    
    [self listenFor:@"newPoint" andRunMethod:@"goTo:"];
    
    for(int i = 0; i < allShapes.count; i++) {
        NOSKPoint *p = allShapes[i];
        [p runMethod:@"randomColors" afterDelay:0.02 * i];
    }
}

-(void)createConnections {
    connections = [@[] mutableCopy];
    connections[0]=@[@(1),@(2),@(3),@(36)];
    connections[1]=@[@(0),@(2),@(12),@(13),@(26),@(36)];
    connections[2]=@[@(0),@(1),@(12),@(14),@(26)];
    connections[3]=@[@(0),@(4)];
    connections[4]=@[@(3),@(5),@(6),@(7),@(8),@(24),@(28)];
    connections[5]=@[@(4),@(6),@(22),@(24),@(23),@(36)];
    connections[6]=@[@(4),@(5),@(13),@(14),@(23),@(24),@(30),@(36)];
    connections[7]=@[@(4),@(8),@(9),@(36)];
    connections[8]=@[@(4),@(7),@(9),@(10)];
    connections[9]=@[@(7),@(8),@(10)];
    connections[10]=@[@(8),@(9),@(11)];
    connections[11]=@[@(10),@(12),@(13),@(14)];
    connections[12]=@[@(1),@(2),@(11),@(13),@(14)];
    connections[13]=@[@(1),@(6),@(11),@(12),@(14),@(15)];
    connections[14]=@[@(1),@(2),@(6),@(12),@(13),@(15),@(16),@(17),@(18),@(19)];
    connections[15]=@[@(13),@(14),@(16),@(17),@(18),@(19)];
    connections[16]=@[@(14),@(15),@(17),@(18),@(19)];
    connections[17]=@[@(14),@(15),@(16),@(18),@(19)];
    connections[18]=@[@(14),@(15),@(16),@(17),@(19)];
    connections[19]=@[@(14),@(15),@(16),@(17),@(18)];
    connections[20]=@[@(21),@(22),@(24),@(25),@(26),@(27),@(35)];
    connections[21]=@[@(20),@(25),@(27),@(35)];
    connections[22]=@[@(5),@(20),@(23),@(24)];
    connections[23]=@[@(5),@(6),@(22)];
    connections[24]=@[@(4),@(5),@(6),@(14),@(20),@(22),@(25),@(32)];
    connections[25]=@[@(20),@(21),@(24),@(26),@(27),@(35)];
    connections[26]=@[@(1),@(20),@(25),@(28),@(35)];
    connections[27]=@[@(20),@(21),@(25),@(28),@(35)];
    connections[28]=@[@(4),@(26),@(29),@(30),@(31),@(33)];
    connections[29]=@[@(28)];
    connections[30]=@[@(6),@(28)];
    connections[31]=@[@(28),@(32)];
    connections[32]=@[@(24),@(31)];
    connections[33]=@[@(28),@(34)];
    connections[34]=@[@(5),@(6),@(22),@(33)];
    connections[35]=@[@(20),@(21),@(25),@(26),@(27)];
    connections[36]=@[@(0),@(2),@(5),@(6),@(23)];
}

-(void)goTo:(NSNotification *)notification {
    NOSKPoint *nextPoint = [notification object];
    [self switchTo:[allShapes indexOfObject:nextPoint]];
}

-(void)switchTo:(NSInteger)nextPoint {
    NOSKPoint *p = allShapes[nextPoint];
    p.animationDuration = 1.0f;
    p.animationDelay = 0;
    p.alpha = 1.0f;
    p.center = self.canvas.center;
    NSArray *innerCircle = connections[nextPoint];
    
    [self resetRemainingInnerLocations];
    for(int i = 0; i < innerCircle.count; i++) {
        NSInteger shapeIndex = [innerCircle[i] integerValue];
        NOSKPoint *innerPoint = allShapes[shapeIndex];
        
        NSInteger targetIndex = [C4Math randomInt:remainingInnerLocations.count];
        NSNumber *targetIndexValue = remainingInnerLocations[targetIndex];
        CGPoint target = innerTargets[[targetIndexValue integerValue]];
        innerPoint.animationDuration = 2.0f + [C4Math randomInt:30]/100.0f;
        innerPoint.animationDelay = [C4Math randomInt:30]/100.0f;
        innerPoint.alpha = 1.0f;
        innerPoint.center = target;
        [remainingInnerLocations removeObject:targetIndexValue];
    }
    
    NSMutableArray *outerCircle = [@[] mutableCopy];
    for(int i = 0; i < allShapes.count; i++) outerCircle[i] = @(i);
    [outerCircle removeObjectsInArray:innerCircle];
    [outerCircle removeObject:@(nextPoint)];
    
    [self resetRemainingOuterLocations];
    for(int i = 0; i < outerCircle.count; i++) {
        NSInteger shapeIndex = [outerCircle[i] integerValue];
        NOSKPoint *outerPoint = allShapes[shapeIndex];
        
        if(CGRectContainsPoint(self.canvas.bounds, outerPoint.center)) {
            NSInteger targetIndex = [C4Math randomInt:remainingOuterLocations.count];
            NSNumber *targetIndexValue = remainingOuterLocations[targetIndex];
            CGPoint target = outerTargets[[targetIndexValue integerValue]];
            outerPoint.animationDuration = 2.0f + [C4Math randomInt:30]/100.0f;
            outerPoint.animationDelay = [C4Math randomInt:30]/100.0f;
            outerPoint.alpha = 1.0f;
            outerPoint.center = target;
            [remainingInnerLocations removeObject:targetIndexValue];
        }
    }
}

-(void)createTargetPoints {
    CGFloat r = 240.0f;
    CGFloat dt =  TWO_PI / 36.0f;
    for(int i = 0; i < 36; i++) {
        CGFloat theta =  dt * i;
        innerTargets[i] = CGPointMake(r*[C4Math cos:theta] + self.canvas.center.x,
                                      r*[C4Math sin:theta] + self.canvas.center.y);
    }

    r = 700;
    dt = TWO_PI / 72;
    for(int i = 0; i < 72; i++) {
        CGFloat theta =  dt * i;
        outerTargets[i] = CGPointMake(r*[C4Math cos:theta] + self.canvas.center.x,
                                      r*[C4Math sin:theta] + self.canvas.center.y);
    }
}

-(void)animateAllIn {
    [self resetRemainingInnerLocations];
    for(int i = 0; i < allShapes.count; i++) {
        C4Shape *s = allShapes[i];
        NSInteger index = [C4Math randomInt:remainingInnerLocations.count];
        CGPoint target = innerTargets[[remainingInnerLocations[index] integerValue]];
        [remainingInnerLocations removeObjectAtIndex:index];
        s.animationDuration = 2.0f + [C4Math randomInt:30]/100.0f;
        s.animationDelay = [C4Math randomInt:30]/100.0f;
        s.alpha = 1.0f;
        s.center = target;
    }
    
    [self runMethod:@"animateOut" afterDelay:3.0f];
}

-(void)animateAllOut {
    [self resetRemainingOuterLocations];
    for(int i = 0; i < allShapes.count; i++) {
        C4Shape *s = allShapes[i];
        NSInteger index = [C4Math randomInt:remainingOuterLocations.count];
        CGPoint target = outerTargets[[remainingOuterLocations[index] integerValue]];
        [remainingOuterLocations removeObjectAtIndex:index];
        s.animationDuration = 2.0f + [C4Math randomInt:30]/100.0f;
        s.animationDelay = [C4Math randomInt:30]/100.0f;
        s.alpha = 0;
        s.center = target;
    }
    [self runMethod:@"animateIn" afterDelay:3.0f];
}

-(void)resetRemainingInnerLocations {
    if(remainingInnerLocations == nil) remainingInnerLocations = [@[] mutableCopy];
    else [remainingInnerLocations removeAllObjects];
    
    for(int i = 0; i < 36; i++) {
        remainingInnerLocations[i] = @(i);
    }
}

-(void)resetRemainingOuterLocations {
    if(remainingOuterLocations == nil) remainingOuterLocations = [@[] mutableCopy];
    else [remainingOuterLocations removeAllObjects];
    
    for(int i = 0; i < 72; i++) {
        remainingOuterLocations[i] = @(i);
    }
}

@end
