//
//  C4WorkSpace.m
//  EverythingCollapses
//
//  Created by travis on 2014-03-17.
//

#import "C4Workspace.h"
#import "C4Logo.h"

@implementation C4WorkSpace {
    NSMutableArray *nodes, *bridges;
    NSMutableDictionary *allBridges, *directions;
    NSMutableArray *paths;
    C4View *v;
    NSInteger animationStep;
    C4Logo *logo;
}

-(void)setup {
    animationStep = 0;
    [self setupRandomLines];
    
    v = [[C4View alloc] initWithFrame:CGRectMake(0, 0, 330, 400)];
    [self createBridges];
    [self createDirectionsDictionary];
    [self createNodes];
    [v addObjects:bridges];
    [v addObjects:nodes];
    v.center = self.canvas.center;
    [self.canvas addSubview:v];
    
    [self createLogo];

    [self listenFor:@"startNotification" andRunMethod:@"start"];
    [self addGesture:LONGPRESS name:@"long" action:@"revealWords"];
}

-(void)revealWords {
    C4Font *font = [C4Font fontWithName:@"Menlo-Bold" size:48];
    C4Label *rep = [C4Label labelWithText:@"EXPLORE\nPLAY" font:font];
    rep.numberOfLines = 2;
    rep.textAlignment = ALIGNTEXTCENTER;
    rep.alpha = 0;
    [rep sizeToFit];
    rep.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.66];
    rep.center = self.canvas.center;
    
    C4Label *stat = [C4Label labelWithText:@"MOMENTS OF \nCHOICE" font:font];
    stat.numberOfLines = 2;
    stat.textAlignment = ALIGNTEXTCENTER;
    stat.alpha = 0;
    stat.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.66];
    [stat sizeToFit];
    stat.center = self.canvas.center;
    
    [self runMethod:@"revealLabel:" withObject:rep afterDelay:0.25f];
    [self runMethod:@"hideLabel:" withObject:rep afterDelay:5.25f];
    [self runMethod:@"revealLabel:" withObject:stat afterDelay:6.5f];
    [self runMethod:@"hideLabel:" withObject:stat afterDelay:11.5f];
}

-(void)revealLabel:(C4Label *)label {
    [self.canvas addLabel:label];
    label.animationDuration = 1.0f;
    label.alpha = 1.0f;
}

-(void)hideLabel:(C4Label *)label {
    label.animationDuration = 1.0f;
    label.alpha = 0.0f;
    [label runMethod:@"removeFromSuperview" afterDelay:1.1f];
}

-(void)start {
    animationStep = 0;
    [self fadeNodesIn];
    [self runMethod:@"fadeBridgesIn" afterDelay:1.0f];
}

-(void)createLogo {
    logo = [[C4Logo alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    logo.origin = CGPointMake(10, self.canvas.height-logo.height-10);
    [logo setup];
    [self.canvas addSubview:logo];
}

-(void)touchesBegan {
    switch (animationStep) {
        case 1:
            [self fadeBridgesOut];
            [self runMethod:@"buildRandomPath3" afterDelay:1.0f];
            break;
        case 2:
            [self buildAllPaths];
            break;
    }
    animationStep ++;
}

-(void)buildAllPaths {
    for(int x = 1; x < 3; x ++) {
        for(int i = 1; i < 7; i++) {
            NSString *methodName = [@"buildRandomPath" stringByAppendingFormat:@"%d",i];
            [self runMethod:methodName afterDelay:((CGFloat)i * .25)*x];
        }
    }
}

-(void)fadeBridgesIn {
    for(int i = 0; i < bridges.count; i++) {
        C4Shape *bridge = bridges[i];
        
        bridge.animationDuration = 0.33f;
        bridge.animationDelay = i * .05;
        bridge.alpha = 1.0f;
    }
}

-(void)fadeBridgesOut {
    for(int i = 0; i < bridges.count; i++) {
        C4Shape *bridge = bridges[i];
        
        bridge.animationDuration = 0.25f;
        bridge.animationDelay = i * .05;
        bridge.alpha = .05;
    }
}

-(C4Shape *)createShape:(CGPathRef)path {
    C4Shape *shape = [C4Shape rect:CGRectMake(0, 0, 10, 10)];
    shape.path = path;
    shape.lineJoin = JOINBEVEL;
    shape.lineCap = CAPBUTT;
    NSInteger i = [C4Math randomInt:3];
    switch (i) {
        case 0:
            shape.strokeColor = C4GREY;
            break;
        case 1:
            shape.strokeColor = C4RED;
            break;
        case 2:
            shape.strokeColor = C4BLUE;
            break;
    }
    shape.fillColor = [UIColor clearColor];
    shape.lineWidth = 2;
    shape.strokeEnd = 0;
    shape.lineJoin = JOINROUND;
    [v addShape:shape];
    [v sendSubviewToBack:shape];
    return shape;
}

-(void)fadeNodesIn {
    for(int i = 0; i < nodes.count; i++) {
        C4Shape *node = nodes[i];
        node.animationDuration = 0.33f;
        node.animationDelay = .1 * i;
        node.alpha = 1.0f;
    }
}

-(void)buildRandomPath6{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 60, 0);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"IN_A0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A0_A1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A1_B0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B0_B1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B1_B3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B3_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_B0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B0_B1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B1_B3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B3_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_B0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B0_B2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B2_B3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B3_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_B0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B0_B1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B1_B3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B3_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_A0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A0_A1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A1_A2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A2_A3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A3_A4"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A4_IN"]).path);

    C4Shape *shape = [self createShape:path];
    shape.origin = CGPointMake(shape.origin.x-4,shape.origin.y);
    
    [self runMethod:@"beginAnimating:" withObject:@{@"shape":shape,@"time":@(26)} afterDelay:0.1f];
    [self runMethod:@"buildRandomPath6" afterDelay:26.25f];
}

-(void)createRandomPath {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 60, 0);
    
    NSString *currentNode = @"IN";
    NSString *nextNode;
    NSInteger count = [C4Math randomInt:30]+ 20;
    for(int i = 0; i < count; i++) {
        NSArray *nodeDirections = directions[currentNode];
        NSInteger index = [C4Math randomInt:nodeDirections.count];
        nextNode = nodeDirections[index];
        NSString *bridgeKey = [NSString stringWithFormat:@"%@_%@",currentNode,nextNode];
        CGPathAddPath(path, nil, ((C4Shape *)allBridges[bridgeKey]).path);
        C4Log(@"CGPathAddPath(path, nil, ((C4Shape *)allBridges[@\"%@\"]).path);",bridgeKey);
        currentNode = nextNode;
    }
    
    C4Shape *shape = [C4Shape rect:CGRectMake(0, 0, 10, 10)];
    shape.path = path;
    shape.fillColor = [UIColor clearColor];
    shape.strokeEnd = 0;
    [v addShape:shape];
    
    [self runMethod:@"beginAnimating:" withObject:@{@"shape":shape,@"time":@(count)} afterDelay:0.1f];
}

-(void)buildRandomPath5 {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 60, 0);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"IN_A0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A0_A1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A1_A2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A2_A3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A3_B0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B0_B1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B1_B3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B3_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_A0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A0_A1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A1_A2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A2_A3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A3_A4"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A4_A0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A0_A1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A1_A2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A2_B0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B0_B2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B2_B3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B3_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_A0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A0_A1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A1_A2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A2_A3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A3_A4"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A4_IN"]).path);
    
    C4Shape *shape = [self createShape:path];
    shape.origin = CGPointMake(shape.origin.x-4,shape.origin.y);
    
    [self runMethod:@"beginAnimating:" withObject:@{@"shape":shape,@"time":@(11)} afterDelay:0.1f];
    [self runMethod:@"buildRandomPath5" afterDelay:11.25f];
}

-(void)buildRandomPath4 {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 60, 0);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"IN_A0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A0_A1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A1_A2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A2_B0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B0_B1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B1_B3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B3_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_A0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A0_A1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A1_A2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A2_A3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A3_A4"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A4_A0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A0_A1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A1_B0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B0_B1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B1_B3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B3_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_B0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B0_B2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B2_B3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B3_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_A0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A0_A1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A1_A2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A2_A3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A3_A4"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A4_IN"]).path);
    
    C4Shape *shape = [self createShape:path];
    shape.origin = CGPointMake(shape.origin.x-2,shape.origin.y);

    [self runMethod:@"beginAnimating:" withObject:@{@"shape":shape,@"time":@(18)} afterDelay:0.1f];
    [self runMethod:@"buildRandomPath4" afterDelay:18.25f];
}

-(void)buildRandomPath3 {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 60, 0);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"IN_A0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A0_A1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A1_A2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A2_A3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A3_B0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B0_B1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B1_B3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B3_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_B0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B0_B2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B2_B3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B3_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_A0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A0_A1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A1_A2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A2_A3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A3_A4"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A4_IN"]).path);

    C4Shape *shape = [self createShape:path];
    [self runMethod:@"beginAnimating:" withObject:@{@"shape":shape,@"time":@(17.5)} afterDelay:0.1f];
    [self runMethod:@"buildRandomPath3" afterDelay:17.75f];
}

-(void)buildRandomPath2 {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 60, 0);
    
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"IN_A0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A0_A1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A1_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_B0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B0_B2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B2_B3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B3_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_B0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B0_B1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B1_B3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B3_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_A0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A0_A1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A1_A2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A2_A3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A3_A4"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A4_IN"]).path);

    C4Shape *shape = [self createShape:path];
    shape.origin = CGPointMake(shape.origin.x+2,shape.origin.y);

    [self runMethod:@"beginAnimating:" withObject:@{@"shape":shape,@"time":@(19.5)} afterDelay:0.1f];
    [self runMethod:@"buildRandomPath2" afterDelay:19.75f];
}

-(void)buildRandomPath1 {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 60, 0);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"IN_A0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A0_B0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B0_B1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B1_B3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B3_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_B0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B0_B1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B1_B3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B3_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_B0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B0_B2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B2_B3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B3_C2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C2_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_A0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A0_A1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A1_A2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A2_A3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A3_A4"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A4_IN"]).path);

    C4Shape *shape = [self createShape:path];
    shape.origin = CGPointMake(shape.origin.x+4,shape.origin.y);

    [self runMethod:@"beginAnimating:" withObject:@{@"shape":shape,@"time":@(13.5)} afterDelay:0.1f];
    [self runMethod:@"buildRandomPath1" afterDelay:13.75f];
}

-(void)createPath {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, 60, 0);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"IN_A0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A0_A1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A1_A2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A2_B0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B0_B2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B2_B3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"B3_C0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C0_C1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"C1_A0"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A0_A1"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A1_A2"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A2_A3"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A3_A4"]).path);
    CGPathAddPath(path, nil, ((C4Shape *)allBridges[@"A4_IN"]).path);
    
    C4Shape *shape = [C4Shape rect:CGRectMake(0, 0, 10, 10)];
    shape.path = path;
    shape.fillColor = [UIColor clearColor];
    NSInteger i = [C4Math randomInt:3];
    switch (i) {
        case 0:
            shape.strokeColor = C4GREY;
            break;
        case 1:
            shape.strokeColor = C4RED;
            break;
        case 2:
            shape.strokeColor = C4BLUE;
            break;
    }
    shape.strokeEnd = 0;
    [v addShape:shape];
    [v sendSubviewToBack:shape];
    
    [self runMethod:@"beginAnimating:" withObject:shape afterDelay:0.1f];
}

-(void)beginAnimating:(NSDictionary *)dict {
    C4Shape *shape = dict[@"shape"];
    
    shape.animationDuration = [dict[@"time"] floatValue];
    shape.animationOptions = LINEAR;
    shape.strokeEnd = 1.0;
    
    [self runMethod:@"beginAnimatingOut:" withObject:dict afterDelay:1.0f];
}

-(void)beginAnimatingOut:(NSDictionary *)dict {
    C4Shape *shape = dict[@"shape"];
    shape.animationDuration = [dict[@"time"] floatValue];
    shape.animationOptions = LINEAR;
    shape.strokeStart = 1.0;
    
    [shape runMethod:@"removeFromSuperview" afterDelay:shape.animationDuration+.25f];
}

-(void)createNodes {
    nodes = [@[] mutableCopy];
    //A column
    [self createNodeAt:(CGPoint){6,0}];
    [self createNodeAt:(CGPoint){6,8}];
    [self createNodeAt:(CGPoint){6,16}];
    [self createNodeAt:(CGPoint){6,24}];
    [self createNodeAt:(CGPoint){6,32}];
    [self createNodeAt:(CGPoint){6,40}];
    
    //B column
    [self createNodeAt:(CGPoint){18,8}];
    [self createNodeAt:(CGPoint){14,16}];
    [self createNodeAt:(CGPoint){22,16}];
    [self createNodeAt:(CGPoint){18,24}];

    //B column
    [self createNodeAt:(CGPoint){30,8}];
    [self createNodeAt:(CGPoint){30,16}];
    [self createNodeAt:(CGPoint){30,24}];
}

-(void)createNodeAt:(CGPoint)p {
    C4Shape *s = [C4Shape ellipse:CGRectMake(0, 0, 8, 8)];
//    s.rotation = QUARTER_PI;
    s.lineWidth = 2;
    s.strokeColor = C4GREY;
    s.fillColor = [UIColor whiteColor];
    s.alpha = 0.0f;
    p.x *= 10;
    p.y *= 10;
    s.center = p;
    [nodes addObject:s];
}

-(void)createBridges {
    bridges = [@[] mutableCopy];
    allBridges = [@{} mutableCopy];
    
    //in to a0
    CGPoint p2[2];
    p2[0] = CGPointMake(6, 0);
    p2[1] = CGPointMake(6, 8);
    [self createBridge:p2 pointCount:2];
    allBridges[@"IN_A0"] = [bridges lastObject];
    
    //a0 to a1
    p2[0] = CGPointMake(6, 8);
    p2[1] = CGPointMake(6, 16);
    [self createBridge:p2 pointCount:2];
    allBridges[@"A0_A1"] = [bridges lastObject];

    //a1 to a2
    p2[0] = CGPointMake(6, 16);
    p2[1] = CGPointMake(6, 24);
    [self createBridge:p2 pointCount:2];
    allBridges[@"A1_A2"] = [bridges lastObject];

    //a2 to a3
    p2[0] = CGPointMake(6, 24);
    p2[1] = CGPointMake(6, 32);
    [self createBridge:p2 pointCount:2];
    allBridges[@"A2_A3"] = [bridges lastObject];

    //a3 to a4
    p2[0] = CGPointMake(6, 32);
    p2[1] = CGPointMake(6, 40);
    [self createBridge:p2 pointCount:2];
    allBridges[@"A3_A4"] = [bridges lastObject];

    //a4 to in
    CGPoint p4[4];
    p4[0] = CGPointMake(6,40);
    p4[1] = CGPointMake(0,40);
    p4[2] = CGPointMake(0,0);
    p4[3] = CGPointMake(6,0);
    [self createBridge:p4 pointCount:4];
    allBridges[@"A4_IN"] = [bridges lastObject];

    //a4 to a0
    p4[0] = CGPointMake(6,40);
    p4[1] = CGPointMake(3,40);
    p4[2] = CGPointMake(3,8);
    p4[3] = CGPointMake(6,8);
    [self createBridge:p4 pointCount:4];
    allBridges[@"A4_A0"] = [bridges lastObject];

    //a0 to b0
    p2[0] = CGPointMake(6,8);
    p2[1] = CGPointMake(18, 8);
    [self createBridge:p2 pointCount:2];
    allBridges[@"A0_B0"] = [bridges lastObject];
    
    //a1 to b0
    p4[0] = CGPointMake(6,16);
    p4[1] = CGPointMake(9,16);
    p4[2] = CGPointMake(9,8);
    p4[3] = CGPointMake(18,8);
    [self createBridge:p4 pointCount:4];
    allBridges[@"A1_B0"] = [bridges lastObject];

    //a2 to b0
    p4[0] = CGPointMake(6,24);
    p4[1] = CGPointMake(9,24);
    p4[2] = CGPointMake(9,8);
    p4[3] = CGPointMake(18,8);
    [self createBridge:p4 pointCount:4];
    allBridges[@"A2_B0"] = [bridges lastObject];

    //a3 to b0
    p4[0] = CGPointMake(6,32);
    p4[1] = CGPointMake(9,32);
    p4[2] = CGPointMake(9,8);
    p4[3] = CGPointMake(18,8);
    [self createBridge:p4 pointCount:4];
    allBridges[@"A3_B0"] = [bridges lastObject];

    //a1 to c0
    CGPoint p5[5];
    p5[0] = CGPointMake(6, 16);
    p5[1] = CGPointMake(11, 16);
    p5[2] = CGPointMake(11, 11);
    p5[3] = CGPointMake(30, 11);
    p5[4] = CGPointMake(30, 8);
    [self createBridge:p5 pointCount:5];
    allBridges[@"A1_C0"] = [bridges lastObject];

    //a1 to c2
    p5[0] = CGPointMake(6, 16);
    p5[1] = CGPointMake(11, 16);
    p5[2] = CGPointMake(11, 21);
    p5[3] = CGPointMake(30, 21);
    p5[4] = CGPointMake(30, 24);
    [self createBridge:p5 pointCount:5];
    allBridges[@"A1_C2"] = [bridges lastObject];

    //b0 to b1
    p4[0] = CGPointMake(18,8);
    p4[1] = CGPointMake(18,13);
    p4[2] = CGPointMake(14,13);
    p4[3] = CGPointMake(14,16);
    [self createBridge:p4 pointCount:4];
    allBridges[@"B0_B1"] = [bridges lastObject];

    //b0 to b2
    p4[0] = CGPointMake(18,8);
    p4[1] = CGPointMake(18,13);
    p4[2] = CGPointMake(22,13);
    p4[3] = CGPointMake(22,16);
    [self createBridge:p4 pointCount:4];
    allBridges[@"B0_B2"] = [bridges lastObject];

    //b1 to b3
    p4[0] = CGPointMake(14,16);
    p4[1] = CGPointMake(14,19);
    p4[2] = CGPointMake(18,19);
    p4[3] = CGPointMake(18,24);
    [self createBridge:p4 pointCount:4];
    allBridges[@"B1_B3"] = [bridges lastObject];

    //b2 to b3
    p4[0] = CGPointMake(22,16);
    p4[1] = CGPointMake(22,19);
    p4[2] = CGPointMake(18,19);
    p4[3] = CGPointMake(18,24);
    [self createBridge:p4 pointCount:4];
    allBridges[@"B2_B3"] = [bridges lastObject];

    //b3 to c2
    p4[0] = CGPointMake(18,24);
    p4[1] = CGPointMake(18,27);
    p4[2] = CGPointMake(30,27);
    p4[3] = CGPointMake(30,24);
    [self createBridge:p4 pointCount:4];
    allBridges[@"B3_C2"] = [bridges lastObject];

    //b3 to c0
    p5[0] = CGPointMake(18,24);
    p5[1] = CGPointMake(18,27);
    p5[2] = CGPointMake(33,27);
    p5[3] = CGPointMake(33,8);
    p5[4] = CGPointMake(30,8);
    [self createBridge:p5 pointCount:5];
    allBridges[@"B3_C0"] = [bridges lastObject];

    //c0 to c1
    p4[0] = CGPointMake(30, 8);
    p4[1] = CGPointMake(32, 10);
    p4[2] = CGPointMake(32, 14);
    p4[3] = CGPointMake(30, 16);
    [self createBridge:p4 pointCount:4];
    allBridges[@"C0_C1"] = [bridges lastObject];

    //c1 to c0
    p4[0] = CGPointMake(30, 16);
    p4[1] = CGPointMake(28, 14);
    p4[2] = CGPointMake(28, 10);
    p4[3] = CGPointMake(30, 8);
    [self createBridge:p4 pointCount:4];
    allBridges[@"C1_C0"] = [bridges lastObject];

    //c1 to A0
    p5[0] = CGPointMake(30, 16);
    p5[1] = CGPointMake(26, 16);
    p5[2] = CGPointMake(26, 5);
    p5[3] = CGPointMake(6, 5);
    p5[4] = CGPointMake(6, 8);
    [self createBridge:p5 pointCount:5];
    allBridges[@"C1_A0"] = [bridges lastObject];

    //c1 to B0
    p4[0] = CGPointMake(30, 16);
    p4[1] = CGPointMake(26, 16);
    p4[2] = CGPointMake(26, 8);
    p4[3] = CGPointMake(18, 8);
    [self createBridge:p4 pointCount:4];
    allBridges[@"C1_B0"] = [bridges lastObject];

    //c0 to c2
    p4[0] = CGPointMake(30, 8);
    p4[1] = CGPointMake(32, 10);
    p4[2] = CGPointMake(32, 22);
    p4[3] = CGPointMake(30, 24);
    [self createBridge:p4 pointCount:4];
    allBridges[@"C0_C2"] = [bridges lastObject];

    //c2 to c0
    p4[0] = CGPointMake(30, 24);
    p4[1] = CGPointMake(28, 22);
    p4[2] = CGPointMake(28, 10);
    p4[3] = CGPointMake(30, 8);
    [self createBridge:p4 pointCount:4];
    allBridges[@"C2_C0"] = [bridges lastObject];

    //c1 to c2
    p4[0] = CGPointMake(30, 16);
    p4[1] = CGPointMake(32, 18);
    p4[2] = CGPointMake(32, 22);
    p4[3] = CGPointMake(30, 24);
    [self createBridge:p4 pointCount:4];
    allBridges[@"C1_C2"] = [bridges lastObject];

    //c2 to c1
    p4[0] = CGPointMake(30, 24);
    p4[1] = CGPointMake(28, 22);
    p4[2] = CGPointMake(28, 18);
    p4[3] = CGPointMake(30, 16);
    [self createBridge:p4 pointCount:4];
    allBridges[@"C2_C1"] = [bridges lastObject];
}

-(void)createDirectionsDictionary {
    directions = [@{} mutableCopy];
    directions[@"IN"] = @[@"A0"];
    directions[@"A0"] = @[@"A1",@"B0"];
    directions[@"A1"] = @[@"A2",@"B0",@"C0",@"C1"];
    directions[@"A2"] = @[@"A3",@"B0"];
    directions[@"A3"] = @[@"A4",@"B0"];
    directions[@"A4"] = @[@"A0",@"IN"];
    directions[@"B0"] = @[@"B1",@"B2"];
    directions[@"B1"] = @[@"B3"];
    directions[@"B2"] = @[@"B3"];
    directions[@"B3"] = @[@"C0",@"C2"];
    directions[@"C0"] = @[@"C1",@"C2"];
    directions[@"C1"] = @[@"B0",@"C0",@"C2"];
    directions[@"C2"] = @[@"C0",@"C1"];
}

-(void)createBridge:(CGPoint *)pts pointCount:(NSInteger)count {
    for(int i = 0; i < count; i++) {
        pts[i].x *= 10;
        pts[i].y *= 10;
    }
    
    C4Shape *bridge;
        bridge = [C4Shape polygon:pts pointCount:count];
        bridge.fillColor = [UIColor clearColor];
    bridge.alpha = 0.0f;
    bridge.lineWidth = 2;
    bridge.strokeColor = C4GREY;
    [bridges addObject:bridge];
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
