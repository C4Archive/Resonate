//
//  C4WorkSpace.m
//  Fields
//
//  Created by Slant on 2014-04-04.
//

#import "C4Workspace.h"
#import "Idea.h"
#import "C4Logo.h"

@implementation C4WorkSpace {
    NSMutableArray *ideas;
    NSInteger touchIndex;
    C4Logo *logo;
}

-(void)createLogo {
    logo = [[C4Logo alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    logo.origin = CGPointMake(10, self.canvas.height-logo.height-10);
    [logo setup];
    [self.canvas addSubview:logo];
}

-(void)setup {
    [self createLogo];
    [self setupRandomLines];

    touchIndex = 0;
    ideas = [@[] mutableCopy];
    NSArray *titles = @[@"KNOWLEDGE",@"NARRATIVE",@"CREATIVITY",@"TYPOGRAPHY"];
    for(int i = 0; i < 4; i++) {
        Idea *idea = [[Idea alloc] initWithFrame:CGRectMake(0, 0, 192, 192)];
        [idea setupWithText:titles[i]];
        idea.center = CGPointMake(self.canvas.width/5 * (i+1),
                                       self.canvas.center.y);
        idea.alpha = 0.0f;
        [ideas addObject:idea];
        [self.canvas addSubview:idea];
    }
}

-(void)touchesBegan {
    switch (touchIndex) {
        case 0:
            [self revealIdeas];
            break;
        case 1:
            [self revealHoles];
            break;
        case 2:
            [self revealPulses];
            break;
    }
    touchIndex++;
}

-(void)revealIdeas {
    for(int i = 0; i < 4; i++) {
        Idea *idea = ideas[i];
        [self runMethod:@"revealIdea:" withObject:idea afterDelay:i * .5 + .25f];
    }
}

-(void)revealIdea:(Idea *)idea {
    idea.animationDuration = 1.0f;
    idea.alpha = 1.0f;
}

-(void)revealHoles {
    for(int i = 0; i < 4; i++) {
        Idea *idea = ideas[i];
        [idea runMethod:@"animateHole" afterDelay:i * .25];
    }
}

-(void)revealPulses {
    for(int i = 0; i < 4; i++) {
        Idea *idea = ideas[i];
        [idea runMethod:@"animatePulse" afterDelay:i * .25];
    }
}

-(void)setupRandomLines {
    for(int i = 0; i < 50; i++) {
        [self addRandomLine];
    }
}

-(void)addLine:(CGPoint)origin {
    C4Shape *aLine;
    CGPoint pts[2] = {origin, CGPointMake(origin.x + self.canvas.height, origin.y + self.canvas.height)};
    aLine = [C4Shape line:pts];
    aLine.lineWidth = 0.0;
    switch ([C4Math randomInt:3]) {
        case 0:
            aLine.strokeColor = C4GREY;
            break;
        case 1:
            aLine.strokeColor = C4RED;
            break;
        case 2:
            aLine.strokeColor = C4BLUE;
            break;
    };
    aLine.strokeEnd = 0.0f;
    [self.canvas addShape:aLine];
    [self animateIn:aLine];
}

-(void)animateIn:(C4Shape *)line {
    line.animationDuration = [C4Math randomInt:5] + 5;
    line.animationOptions = EASEOUT;
    line.strokeEnd = 1.0f;
    line.lineWidth = ([C4Math randomInt:20] + 5.0f) / 100.0f;
    [self runMethod:@"animateOut:" withObject:line afterDelay:1.0];
}

-(void)animateOut:(C4Shape *)line {
    line.animationOptions = EASEIN;
    line.strokeStart = 1.0f;
    [line runMethod:@"removeFromSuperview" afterDelay:line.animationDuration + 1];
    [self runMethod:@"addRandomLine" afterDelay:line.animationDuration];
}

-(void)addRandomLine {
    CGFloat random = [C4Math randomInt:self.canvas.width + self.canvas.height] - self.canvas.height;
    [self addLine:CGPointMake(random, 0)];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

@end
