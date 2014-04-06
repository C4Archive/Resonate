//
//  C4WorkSpace.m
//  Thanks
//
//  Created by Slant on 2014-03-24.
//

#import "C4Workspace.h"
#import "C4Logo.h"
#import "HoloLogo.h"

@implementation C4WorkSpace {
    CAEmitterCell *emitterCell;
    CAEmitterLayer *emitterLayer;
    NSArray *names;
    C4Shape *current, *nextShape;
    NSInteger nameIndex;
    C4Logo *logo;
    C4Image *canLogo, *resLogo;
    HoloLogo *holoLogo;
}

-(void)restart {
    nameIndex = 0;
    [current removeFromSuperview];
    [nextShape removeFromSuperview];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:current];
    [NSObject cancelPreviousPerformRequestsWithTarget:nextShape];
    [self runMethod:@"showNextName" afterDelay:1.0f];
}

-(void)setup {
    canLogo = [C4Image imageNamed:@"canLogo"];
    canLogo.center = CGPointMake(self.canvas.center.x - 240, self.canvas.center.y);
    canLogo.alpha = 0.0f;
    [self.canvas addImage:canLogo];

    resLogo = [C4Image imageNamed:@"resLogo"];
    resLogo.center = CGPointMake(self.canvas.center.x + 240, self.canvas.center.y);
    resLogo.alpha = 0.0f;
    [self.canvas addImage:resLogo];

    holoLogo = [[HoloLogo alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
    holoLogo.center = self.canvas.center;
    holoLogo.alpha = 0.0f;
    [holoLogo setup];
    [self.canvas addSubview:holoLogo];
    
    [C4Shape defaultStyle].lineWidth = 0.0f;
    
    nameIndex = 0;
    names = @[@"@buza",
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
              @"a-coding.com"
              ];
    
    [self createLogo];
    [self listenFor:@"startNotification" andRunMethod:@"showLogos"];
    [self listenFor:@"restartNotification" andRunMethod:@"restart"];

    [self setupEmitters];
}

-(void)showLogos {
    [self revealCAN];
    [self runMethod:@"revealRES" afterDelay:1.5f];
    [self runMethod:@"revealHOLO" afterDelay:3.0f];
    [self runMethod:@"hideLogos" afterDelay:12.0f];
    [self runMethod:@"showNextName" afterDelay:15.0f];
}

-(void)revealCAN {
    canLogo.animationDuration = 0.5f;
    canLogo.alpha = 1.0f;
}

-(void)revealRES {
    resLogo.animationDuration = 0.5f;
    resLogo.alpha = 1.0f;
}

-(void)revealHOLO {
    holoLogo.animationDuration = 0.5f;
    holoLogo.alpha = 1.0f;
    [holoLogo runMethod:@"startAnimating" afterDelay:0.25f];
}

-(void)hideLogos {
    resLogo.alpha = 0.0f;
    canLogo.alpha = 0.0f;
    holoLogo.alpha = 0.0f;
}

-(void)createLogo {
    logo = [[C4Logo alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    logo.origin = CGPointMake(10, self.canvas.height-logo.height-10);
    [logo setup];
    [self.canvas addSubview:logo];
}

-(void)showNextName {
    C4Font *font = [C4Font fontWithName:@"Menlo-Regular" size:48];
    
    if(nameIndex < names.count) {
        nextShape = [C4Shape shapeFromString:names[nameIndex] withFont:font];
        nextShape.alpha = 0.0f;
        nextShape.center = CGPointMake(self.canvas.center.x, self.canvas.center.y + 100);
        [self.canvas addShape:nextShape];
    }
    [self fadeCurrentRevealNext];
    nameIndex++;
    if (nameIndex <= names.count) {
        [self runMethod:@"showNextName" afterDelay:2.0f];
    }
}

-(void)fadeCurrentRevealNext {
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

-(void)setupEmitters {
    emitterLayer = [CAEmitterLayer new];
    emitterLayer.position = CGPointMake(self.canvas.width - self.canvas.height, self.canvas.height);
    [self.canvas.layer addSublayer:emitterLayer];
    
    NSMutableArray *emitters = [@[] mutableCopy];
    UIColor *c;
    NSString *s;
    for(int i = 0; i < 3; i++) {
        switch (i) {
            case 0:
                s = @"grey";
                c = C4GREY;
                break;
            case 1:
                s = @"red";
                c = C4RED;
                break;
            case 2:
                s = @"blue";
                c = C4BLUE;
                break;
        }
        emitterLayer.emitterSize = CGSizeMake(10, 10);
        emitterLayer.renderMode = kCAEmitterLayerAdditive;
        emitterLayer.transform = CATransform3DMakeRotation(QUARTER_PI * 3, 0.0, 0.0, 1.0);
        NSString *s;
        
        emitterCell = [CAEmitterCell emitterCell];
        emitterCell.birthRate = 10;
        emitterCell.lifetime = 15.0;
        emitterCell.lifetimeRange = 5;
        emitterCell.color = [c CGColor];
        emitterCell.contents = (id) [[UIImage imageNamed:@"red"] CGImage];
        emitterCell.name = s;
        emitterCell.velocity = 100;
        emitterCell.velocityRange = 10;
        emitterCell.emissionRange = QUARTER_PI;
        emitterCell.scale = 1;
        emitterCell.scaleRange = 0;
        emitterCell.scaleSpeed = 0;
        emitterCell.xAcceleration = -20;
        emitterCell.yAcceleration = 0;
        emitterCell.zAcceleration = 0;
        emitterCell.alphaRange = 1.0f;
        emitterCell.alphaSpeed = -.05;
        [emitters addObject:emitterCell];
    }
    emitterLayer.emitterCells = emitters;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}
@end