//
//  C4WorkSpace.m
//  EverythingCollapses
//
//  Created by travis on 2014-03-17.
//

#import "C4Workspace.h"

@implementation C4WorkSpace {
    NSMutableArray *nodes, *bridges;
}

-(void)setup {
    C4View *v = [[C4View alloc] initWithFrame:CGRectMake(0, 0, 330, 400)];

    
    [self createBridges];
    [v addObjects:bridges];
    
    [self createNodes];
    [v addObjects:nodes];
    v.borderWidth = 1;
    v.center = self.canvas.center;
    [self.canvas addSubview:v];
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
    C4Shape *s = [C4Shape ellipse:CGRectMake(0, 0, 20, 20)];
    s.lineWidth = 4;
    s.strokeColor = C4GREY;
    s.fillColor = [UIColor whiteColor];
    p.x *= 10;
    p.y *= 10;
    s.center = p;
    [nodes addObject:s];
}

-(void)createBridges {
    bridges = [@[] mutableCopy];
    
    //in to a0
    CGPoint p2[2];
    p2[0] = CGPointMake(6, 0);
    p2[1] = CGPointMake(6, 8);
    [self createBridge:p2 pointCount:2];
    
    //a0 to a1
    p2[0] = CGPointMake(6, 8);
    p2[1] = CGPointMake(6, 16);
    [self createBridge:p2 pointCount:2];

    //a1 to a2
    p2[0] = CGPointMake(6, 16);
    p2[1] = CGPointMake(6, 24);
    [self createBridge:p2 pointCount:2];

    //a2 to a3
    p2[0] = CGPointMake(6, 24);
    p2[1] = CGPointMake(6, 32);
    [self createBridge:p2 pointCount:2];

    //a3 to a4
    p2[0] = CGPointMake(6, 32);
    p2[1] = CGPointMake(6, 40);
    [self createBridge:p2 pointCount:2];
    
    //a4 to in
    CGPoint p4[4];
    p4[0] = CGPointMake(6,40);
    p4[1] = CGPointMake(0,40);
    p4[2] = CGPointMake(0,0);
    p4[3] = CGPointMake(6,0);
    [self createBridge:p4 pointCount:4];

    //a4 to a0
    p4[0] = CGPointMake(6,40);
    p4[1] = CGPointMake(3,40);
    p4[2] = CGPointMake(3,8);
    p4[3] = CGPointMake(6,8);
    [self createBridge:p4 pointCount:4];

    //a0 to b0
    p2[0] = CGPointMake(6,8);
    p2[1] = CGPointMake(18, 8);
    [self createBridge:p2 pointCount:2];
    
    //a1 to b0
    p4[0] = CGPointMake(6,16);
    p4[1] = CGPointMake(9,16);
    p4[2] = CGPointMake(9,8);
    p4[3] = CGPointMake(18,8);
    [self createBridge:p4 pointCount:4];

    //a2 to b0
    p4[0] = CGPointMake(6,24);
    p4[1] = CGPointMake(9,24);
    p4[2] = CGPointMake(9,8);
    p4[3] = CGPointMake(18,8);
    [self createBridge:p4 pointCount:4];

    //a3 to b0
    p4[0] = CGPointMake(6,32);
    p4[1] = CGPointMake(9,32);
    p4[2] = CGPointMake(9,8);
    p4[3] = CGPointMake(18,8);
    [self createBridge:p4 pointCount:4];

    //a4 to b0
    p4[0] = CGPointMake(6,40);
    p4[1] = CGPointMake(9,40);
    p4[2] = CGPointMake(9,8);
    p4[3] = CGPointMake(18,8);
    [self createBridge:p4 pointCount:4];

    //a1 to c0
    CGPoint p5[5];
    p5[0] = CGPointMake(6, 16);
    p5[1] = CGPointMake(11, 16);
    p5[2] = CGPointMake(11, 11);
    p5[3] = CGPointMake(30, 11);
    p5[4] = CGPointMake(30, 8);
    [self createBridge:p5 pointCount:5];

    //a1 to c2
    p5[0] = CGPointMake(6, 16);
    p5[1] = CGPointMake(11, 16);
    p5[2] = CGPointMake(11, 21);
    p5[3] = CGPointMake(30, 21);
    p5[4] = CGPointMake(30, 24);
    [self createBridge:p5 pointCount:5];

    //b0 to b1
    p4[0] = CGPointMake(18,8);
    p4[1] = CGPointMake(18,13);
    p4[2] = CGPointMake(14,13);
    p4[3] = CGPointMake(14,16);
    [self createBridge:p4 pointCount:4];

    //b0 to b2
    p4[0] = CGPointMake(18,8);
    p4[1] = CGPointMake(18,13);
    p4[2] = CGPointMake(22,13);
    p4[3] = CGPointMake(22,16);
    [self createBridge:p4 pointCount:4];

    //b1 to b3
    p4[0] = CGPointMake(14,16);
    p4[1] = CGPointMake(14,19);
    p4[2] = CGPointMake(18,19);
    p4[3] = CGPointMake(18,24);
    [self createBridge:p4 pointCount:4];

    //b2 to b3
    p4[0] = CGPointMake(22,16);
    p4[1] = CGPointMake(22,19);
    p4[2] = CGPointMake(18,19);
    p4[3] = CGPointMake(18,24);
    [self createBridge:p4 pointCount:4];
}

-(void)createBridge:(CGPoint *)pts pointCount:(NSInteger)count {
    for(int i = 0; i < count; i++) {
        pts[i].x *= 10;
        pts[i].y *= 10;
    }
    
    C4Shape *bridge;
    if(count == 2) {
        bridge = [C4Shape line:pts];
    } else {
        bridge = [C4Shape polygon:pts pointCount:count];
        bridge.fillColor = [UIColor clearColor];
    }
    
    bridge.lineWidth = 4;
    bridge.strokeColor = C4GREY;
    [bridges addObject:bridge];
}
@end
