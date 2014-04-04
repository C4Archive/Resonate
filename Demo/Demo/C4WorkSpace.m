//
//  C4WorkSpace.m
//  Demo
//
//  Created by Slant on 2014-04-04.
//

#import "C4Workspace.h"
#import "C4Logo.h"

@implementation C4WorkSpace {
    C4View *v;
    C4Shape *c1, *c2;
    BOOL allowAnimateOut;
    BOOL allowSpreadOut;
    BOOL allowRotateVY;
    BOOL allowRotateV;
    BOOL allowSwitchToRects;
    BOOL allowStartRotateShapes;
    
    C4Switch *b1,*b2,*b3,*b4,*b5,*b6;
    NSMutableArray *menuItems;
    
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
    allowAnimateOut = NO;
    allowSpreadOut = NO;
    allowRotateVY = NO;
    allowRotateV = NO;
    allowSwitchToRects = NO;
    allowStartRotateShapes = NO;
    
    v = [[C4View alloc]  initWithFrame:CGRectMake(0, 0, 256, 256)];
    v.perspectiveDistance = 300;
    
    [v addGesture:PAN name:@"pan" action:@"move:"];
    
    c1 = [C4Shape ellipse:CGRectMake(0, 0, 128, 128)];
    c1.lineWidth = 20;
    c1.anchorPoint = CGPointMake(1,0.5);
    c1.center = v.center;
    c1.lineJoin = JOINROUND;
    c1.lineCap = CAPROUND;
    
    c2 = [C4Shape ellipse:CGRectMake(0, 0, 128, 128)];
    c2.lineWidth = 20.0f;
    c2.lineCap = CAPROUND;
    c2.lineJoin = JOINROUND;
    c2.anchorPoint = CGPointMake(1, 0.5);
    c2.rotation = PI;
    c2.center = v.center;
    
    [v addObjects:@[c2,c1]];
    [self.canvas addSubview:v];
    v.center = self.canvas.center;
    
    [self runMethod:@"toggleAnimateInOut" afterDelay:2.0f];
    [self runMethod:@"toggleAnimateInOut" afterDelay:4.5f];
    [self runMethod:@"toggleSpread" afterDelay:6.0f];
    [self runMethod:@"toggleSpread" afterDelay:16.0f];
    [self runMethod:@"toggleRotateVY" afterDelay:8.0f];
    [self runMethod:@"toggleRotateVY" afterDelay:16.0f];
    
    [self createMenu];
    [self runMethod:@"revealMenu" afterDelay:16.0f];
}

-(void)createMenu {
    menuItems = [@[] mutableCopy];
    C4Font *font = [C4Font fontWithName:@"Menlo" size:24];
    NSArray *titles = @[@"Fade Animation",@"Spread",@"Rotate",@"Rotate Y",@"Circles / Rects"];
    NSArray *methods = @[@"toggleAnimateInOut",@"toggleSpread",@"toggleRotateV",@"toggleRotateVY",@"toggleCircleRect"];
    
    for(int i = 0; i < titles.count ; i++) {
        C4View *labelView = [[C4View alloc] initWithFrame:CGRectMake(22, self.canvas.height + i * 44, 280, 44)];
        [labelView addSubview:[C4Label labelWithText:titles[i] font:font]];
        
        C4Switch *onOff = [C4Switch switch];
        [onOff runMethod:methods[i] target:self forEvent:VALUECHANGED];
        onOff.origin = CGPointMake(labelView.width - onOff.width, 0);
        [labelView addSubview:onOff];
        [onOff setOn:NO];
        [self.canvas addSubview:labelView];
        [menuItems addObject:labelView];
    }
}

-(void)revealMenu {
    for(int i = 0; i < menuItems.count; i++) {
        C4View *item = (C4View *)menuItems[i];
        [self runMethod:@"revealMenuItem:" withObject:item afterDelay:i*.125f];
    }
}

-(void)hideMenu {
    for(int i = 0; i < menuItems.count; i++) {
        C4View *item = (C4View *)menuItems[i];
        [self runMethod:@"hideMenuItem:" withObject:item afterDelay:(menuItems.count - i)*.125f];
    }
}

-(void)revealMenuItem:(C4View *)menuItem {
    CGPoint center = menuItem.center;
    NSInteger index = [menuItems indexOfObject:menuItem];
    center.y = self.canvas.height - ((menuItems.count - index + 1) * 44);
    menuItem.animationDuration = .5f;
    menuItem.animationOptions = EASEOUT;
    menuItem.center = center;
}

-(void)hideMenuItem:(C4View *)menuItem {
    CGPoint center = menuItem.center;
    center.y += 240;
    menuItem.animationDuration = .5f;
    menuItem.animationOptions = EASEIN;
    menuItem.origin = center;
}

-(void)toggleAnimateInOut {
    if(allowAnimateOut == NO) [self animateLeftOut];
    allowAnimateOut = !allowAnimateOut;
}

-(void)toggleRotateV {
    allowRotateV = !allowRotateV;
    if(allowRotateV == YES) [self rotateV];
    else [self stopRotateV];
}

-(void)toggleRotateVY {
    allowRotateVY = !allowRotateVY;
    if(allowRotateVY == YES) [self rotateVY];
    else [self stopRotateVY];
}

-(void)toggleCircleRect {
    if(allowSwitchToRects == NO) [self switchToRects];
    else [self switchToCircles];
    allowSwitchToRects = !allowSwitchToRects;
}

-(void)toggleRotateShapes {
    if(allowRotateVY == NO) [self rotateVY];
    allowRotateVY = !allowRotateVY;
}

-(void)toggleSpread {
    allowSpreadOut = !allowSpreadOut;
    if(allowSpreadOut == YES) [self spreadOut];
    else [self spreadIn];
}

-(void)stopAnimateOut {
    if(allowAnimateOut == NO) [self animateLeftOut];
    allowAnimateOut = !allowAnimateOut;
}

-(void)spreadOut {
    c1.animationDuration = 1.0f;
    c1.center = CGPointMake(0,v.height/2);
    
    c2.animationDuration = 1.0f;
    c2.center = CGPointMake(v.width,v.height/2);
}

-(void)spreadIn {
    c1.animationDuration = 1.0f;
    c1.center = CGPointMake(v.width/2,v.height/2);
    
    c2.animationDuration = 1.0f;
    c2.center = CGPointMake(v.width/2,v.height/2);
}

-(void)rotateV {
    if(allowRotateV == YES) {
        v.animationDuration = 4.0f;
        v.perspectiveDistance = 300;
        v.animationOptions = 0;
        v.animationOptions = LINEAR;
        v.rotation += TWO_PI;
        [self runMethod:@"rotateV" afterDelay:4.01f];
    }
}

-(void)stopRotateV {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rotateV) object:nil];
}

-(void)rotateVY {
    if(allowRotateVY == YES) {
        v.animationDuration = 4.0f;
        v.perspectiveDistance = 300;
        v.animationOptions = 0;
        v.animationOptions = LINEAR;
        v.rotation += TWO_PI;
        v.rotationY += TWO_PI;
        [self runMethod:@"rotateVY" afterDelay:4.01f];
    }
}

-(void)stopRotateVY {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(rotateVY) object:nil];
}

-(void)animateLeftIn {
    [self switchIn];
    c1.animationDuration = 1.0f;
    c1.strokeEnd = 1.0f;
    c1.fillColor = C4GREY;
    c1.strokeColor = C4BLUE;
    [self runMethod:@"hideRight" afterDelay:0.];
    [self runMethod:@"resetRight" afterDelay:0.1];
    [self runMethod:@"revealRight" afterDelay:0.2];
    [self runMethod:@"animateRightIn" afterDelay:1.0f];
}

-(void)switchToCircles {
    c1.animationDuration = 1.0f;
    [c1 ellipse:c1.frame];
    
    c2.animationDuration = 1.0f;
    [c2 ellipse:c2.frame];
}

-(void)switchToRects {
    c1.animationDuration = 1.0f;
    [c1 rect:c1.frame];
    
    c2.animationDuration = 1.0f;
    [c2 rect:c2.frame];
}

-(void)startRotateShapes {
    c1.animationDuration = 2.0f;
    c1.animationOptions = REPEAT;
    c1.rotationX = PI;
    
    c2.animationDuration = 2.0f;
    c2.animationOptions = REPEAT;
    c2.rotationX = PI;
}

-(void)stopRotateShapes {
    
}

-(void)hideLeft {
    c1.animationDuration = 0.01;
    c1.alpha = 0.0f;
}

-(void)resetLeft {
    c1.strokeStart = 0.0f;
    c1.strokeEnd = 0.0f;
}

-(void)revealLeft {
    c1.animationDuration = 0.01;
    c1.alpha = 1.0f;
}

-(void)hideStrokes {
    c2.animationDuration = 0.01;
    c2.alpha = 0.0f;
}

-(void)hideRight {
    c2.animationDuration = 0.01;
    c2.alpha = 0.0f;
}

-(void)resetRight {
    c2.strokeStart = 1.0f;
    c2.strokeEnd = 1.0f;
}

-(void)revealRight {
    c2.animationDuration = 0.01;
    c2.alpha = 1.0f;
}

-(void)revealStrokes {
    c1.animationDuration = 0;
    c1.alpha = 1.0f;
    c2.animationDuration = 0;
    c2.alpha = 1.0f;
}

-(void)animateRightIn {
    c2.animationDuration = 1.0f;
    c2.strokeStart = 0.0f;
    c2.strokeColor = C4BLUE;
    c2.fillColor = C4GREY;
    if(allowAnimateOut == YES) {
        [self runMethod:@"animateLeftOut" afterDelay:1.0f];
    }
}

-(void)switchIn {
    c1.animationDuration = 0;
    c1.zPosition = 1;
    c2.animationDuration = 0;
    c2.zPosition = 0;
}

-(void)switchOut {
    c1.animationDuration = 0;
    c1.zPosition = 0;
    c2.animationDuration = 0;
    c2.zPosition = 1;
}

-(void)animateLeftOut {
    [self switchOut];
    c1.animationDuration = 1.0f;
    c1.strokeStart = 1.0f;
    c1.fillColor = [UIColor clearColor];
    c1.strokeColor = C4RED;
    [self runMethod:@"animateRightOut" afterDelay:1.0f];
}

-(void)animateRightOut {
    c2.animationDuration = 1.0f;
    c2.strokeEnd = 0.0f;
    c2.strokeColor = C4RED;
    c2.fillColor = [UIColor clearColor];
    [self runMethod:@"hideLeft" afterDelay:0.];
    [self runMethod:@"resetLeft" afterDelay:0.1];
    [self runMethod:@"revealLeft" afterDelay:0.2];
    [self runMethod:@"animateLeftIn" afterDelay:1.0f];
}

-(void)createLines {
    for(int x = -self.canvas.height, i = 0; x < self.canvas.width; x += 20, i++) {
        CGPoint pts[2] = {CGPointMake(x, 0),CGPointMake(x + self.canvas.height, self.canvas.height)};
        C4Shape *line = [C4Shape line:pts];
        line.lineWidth = 0.25f;
        switch ([C4Math randomInt:3]) {
            case 0:
                line.strokeColor = C4BLUE;
                break;
            case 1:
                line.strokeColor = C4RED;
                break;
            case 2:
                line.strokeColor = C4GREY;
                break;
        }
        [self.canvas addShape:line];
        [self runMethod:@"animateLine:" withObject:line afterDelay:i * 0.25f];
    }
}

-(void)animateLine:(C4Shape *)line {
    line.animationDuration = 30.0f;
    line.animationOptions = REPEAT;
    line.rotation = PI;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}
@end
