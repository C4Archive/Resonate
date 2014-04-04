//
//  C4WorkSpace.m
//  EmitterTest
//
//  Created by Slant on 2014-03-24.
//

#import "C4Workspace.h"

@implementation C4WorkSpace {
    CAEmitterCell *emitterCell;
    CAEmitterLayer *emitterLayer;
    C4Shape *aLine;
}

-(void)setup {
    [self setupEmitters];
}

-(void)setupGradients {
    for(int i = 0; i < 31; i++) {
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(-32, i * 32 + 32, self.canvas.width+32, 0.5);
        gradientLayer.startPoint = CGPointMake(0,0.5);
        gradientLayer.endPoint = CGPointMake(1, 0.5);
        gradientLayer.colors = @[C4GREY.CGColor,C4BLUE.CGColor,C4RED.CGColor];
        gradientLayer.locations = @[@(0.25),@(1),@(1)];
        gradientLayer.opacity = 0.8;
        [self.canvas.layer addSublayer:gradientLayer];
        [self runMethod:@"animateGradient:" withObject:gradientLayer afterDelay:i * .32];
    }
}

-(void)animateGradient:(CAGradientLayer *)layer {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"locations"];
    animation.duration = 10;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.autoreverses = YES;
    animation.repeatCount = FOREVER;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;
    animation.fromValue = (id)layer.locations;
    animation.toValue = (id)@[@(0),@(0),@(0.75)];
    [layer addAnimation:animation forKey:@"animateLocations"];
    [CATransaction commit];
}

-(void)setupCircles {
    for(int i = 0; i < 36; i++) {
        C4Shape *s = [C4Shape ellipse:CGRectMake(0, 0, (i+1) * 36, (i+1) * 36)];
        s.fillColor = [UIColor clearColor];
        s.alpha = 0.66f;
        s.lineWidth = .25;
        s.center = self.canvas.center;
        s.rotation = [C4Math randomInt:360]/360.0f * TWO_PI;
        s.alpha = 0.0f;
        switch ([C4Math randomInt:3]) {
            case 0:
                s.strokeColor = C4GREY;
                break;
            case 1:
                s.strokeColor = C4RED;
                break;
            case 2:
                s.strokeColor = C4BLUE;
                break;
        };

        [self.canvas addShape:s];
        
        [self runMethod:@"animateCircleIn:" withObject:s afterDelay:i * .05];
    }
}

-(void)animateCircleIn:(C4Shape *)circle {
    circle.animationDuration = 0.25f;
    circle.alpha = 0.86f;
    [self runMethod:@"animateCircle:" withObject:circle afterDelay:0.25f];
}

-(void)animateCircle:(C4Shape *)circle {
    circle.animationDuration = 20.0f + [C4Math randomInt:10];
    circle.animationOptions = AUTOREVERSE | REPEAT;
    NSInteger direction = [C4Math randomInt:2];
    if(direction == 0) {
        direction = -1;
    }
    circle.rotation = TWO_PI * direction;
    NSInteger strokeDirection = [C4Math randomInt:2];
    if(strokeDirection == 0) {
        circle.strokeEnd = 0.0f;
    } else {
        circle.strokeStart = 1.0f;
    }
}

-(void)setupRandomLines {
    for(int i = 0; i < 50; i++) {
        [self addRandomLine];
    }
}

-(void)addLine:(CGPoint)origin {
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

@end
