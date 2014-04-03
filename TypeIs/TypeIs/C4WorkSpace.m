//
//  C4WorkSpace.m
//  TypeIs
//
//  Created by travis on 2014-03-25.
//

#import "C4Workspace.h"

@implementation C4WorkSpace {
    NSArray *rethinkingLetters;
    NSArray *theLetters;
    NSArray *baselineLetters;

    NSMutableArray *rethinking;
    NSMutableArray *the;
    NSMutableArray *baseline;
    
    C4Shape *straightBaseline;
    C4Shape *straightBaselinePoint;
    
    NSMutableArray *points;

    C4Movie *textLandscape;
    NSMutableArray *slides;
    C4Image *currentSlide;
}

-(void)setup {
//    textLandscape = [C4Movie movieNamed:@"textLandscapeiPadShort.mov"];
//    textLandscape.width = self.canvas.width;
//    textLandscape.center = self.canvas.center;
//    textLandscape.shouldAutoplay = YES;
//    [self.canvas addMovie:textLandscape];
//    
//    [self createSlides];
//    [self listenFor:@"reachedEnd" andRunMethod:@"initiateSlideShow"];
    
    [self createStraightLetters];
    [self runMethod:@"createStraightBaseline" afterDelay:0.1];
    [self runMethod:@"createDrawnBaseline" afterDelay:.15];
    [self runMethod:@"createDrawnLetters" afterDelay:0.2];
}

-(void)createSlides {
    slides = [@[] mutableCopy];
    for (int i = 0; i < 12; i++) {
        NSString *name = [NSString stringWithFormat:@"typeis%02d",i];
        C4Image *img = [C4Image imageNamed:name];
        
        img.width = self.canvas.width;
        img.center = self.canvas.center;
        img.alpha = 0.0f;
        [slides addObject:img];
    }
}

-(void)initiateSlideShow {
    [self.canvas addObjects:slides];
    [self revealSlide:slides[0]];
}

-(void)revealSlide:(C4Image *)slide {
    slide.animationDuration = 0.5f;
    slide.alpha = 1.0f;
    
    
    if(currentSlide == nil) {
        [textLandscape runMethod:@"removeFromSuperview" afterDelay:0.6f];
    } else {
        [currentSlide runMethod:@"removeFromSuperview" afterDelay:0.6f];
    }

    NSInteger indexForNextSlide = [slides indexOfObject:slide] + 1;
    currentSlide = slide;
    
    C4Image *nextSlide;
    if(indexForNextSlide < slides.count) {
        nextSlide = slides[indexForNextSlide];
        [self runMethod:@"revealSlide:" withObject:nextSlide afterDelay:3.0f];
    } else {
        [self runMethod:@"fadeSlide:" withObject:currentSlide afterDelay:3.0f];
    }
}

-(void)fadeSlide:(C4Image *)slide {
    slide.animationDuration = 0.5f;
    slide.alpha = 0.0f;
    [slide runMethod:@"removeFromSuperview" afterDelay:0.6f];
}


-(void)createStraightLetters {
    C4Font *f = [C4Font fontWithName:@"Menlo-Regular" size:48];
    rethinkingLetters = @[@"r",@"e",@"t",@"h",@"i",@"n",@"k",@"i",@"n",@"g"];
    theLetters = @[@"t",@"h",@"e"];
    baselineLetters = @[@"b",@"a",@"s",@"e",@"l",@"i",@"n",@"e"];
    
    rethinking = [@[] mutableCopy];
    [C4Shape defaultStyle].lineWidth = 0.0f;
    for(int i = 0; i < rethinkingLetters.count; i++) {
        C4Shape *s = [C4Shape shapeFromString:[rethinkingLetters[i] uppercaseString] withFont:f];
        if(i == 0) s.origin = CGPointMake(200, self.canvas.height - 200);
        else {
            C4Shape *prevLetter = rethinking[i-1];
            s.origin = CGPointMake(CGRectGetMaxX(prevLetter.frame)+4, CGRectGetMaxY(prevLetter.frame) - s.height);
        }
        [rethinking addObject:s];
    }
    [self.canvas addObjects:rethinking];

    the = [@[] mutableCopy];
    [C4Shape defaultStyle].lineWidth = 0.0f;
    for(int i = 0; i < theLetters.count; i++) {
        C4Shape *s = [C4Shape shapeFromString:[theLetters[i] uppercaseString] withFont:f];
        if(i == 0) s.origin = CGPointMake(500, self.canvas.height - 200);
        else {
            C4Shape *prevLetter = the[i-1];
            s.origin = CGPointMake(CGRectGetMaxX(prevLetter.frame)+4, CGRectGetMaxY(prevLetter.frame) - s.height);
        }
        [the addObject:s];
    }
    [self.canvas addObjects:the];

    baseline = [@[] mutableCopy];
    [C4Shape defaultStyle].lineWidth = 0.0f;
    for(int i = 0; i < baselineLetters.count; i++) {
        C4Shape *s = [C4Shape shapeFromString:[baselineLetters[i] uppercaseString] withFont:f];
        if(i == 0) s.origin = CGPointMake(612,  self.canvas.height - 200);
        else {
            C4Shape *prevLetter = baseline[i-1];
            s.origin = CGPointMake(CGRectGetMaxX(prevLetter.frame)+4, CGRectGetMaxY(prevLetter.frame) - s.height);
        }
        [baseline addObject:s];
    }
    [self.canvas addObjects:baseline];
    
}

-(void)createStraightBaseline {
    CGPoint pts[2] = {
        CGPointMake(192, self.canvas.height - 160),
        CGPointMake(822, self.canvas.height - 160)
    };
    [C4Shape defaultStyle].lineWidth = 2.0f;
    [C4Shape defaultStyle].fillColor = [UIColor whiteColor];
    [C4Shape defaultStyle].strokeColor = C4RED;
    straightBaseline = [C4Shape line:pts];
    [self.canvas addShape:straightBaseline];
    
    straightBaselinePoint = [C4Shape ellipse:CGRectMake(0, 0, 8, 8)];
    straightBaselinePoint.center = pts[0];
    [self.canvas addShape:straightBaselinePoint];
}

-(void)createDrawnBaseline {
    CGPoint pts[28] = {
    CGPointMake(192.00,368.00),
    CGPointMake(206.00,357.00),
    CGPointMake(219.00,347.50),
    CGPointMake(237.00,334.00),
    CGPointMake(255.00,322.00),
    CGPointMake(276.50,308.50),
    CGPointMake(300.00,296.50),
    CGPointMake(324.50,284.00),
    CGPointMake(351.00,274.50),
    CGPointMake(378.00,267.50),
    CGPointMake(404.50,262.50),
    CGPointMake(431.00,260.00),
    CGPointMake(457.00,260.00),
    CGPointMake(483.00,263.00),
    CGPointMake(508.50,269.00),
    CGPointMake(534.00,276.50),
    CGPointMake(559.50,286.50),
    CGPointMake(584.00,296.50),
    CGPointMake(608.50,307.00),
    CGPointMake(632.50,318.00),
    CGPointMake(657.50,326.50),
    CGPointMake(682.50,333.00),
    CGPointMake(707.00,339.50),
    CGPointMake(729.50,344.00),
    CGPointMake(750.50,346.00),
    CGPointMake(778.50,346.00),
    CGPointMake(803.00,339.50),
    CGPointMake(822.00,329.50),
    };

    C4Shape *s = [C4Shape polygon:pts pointCount:28];
    s.lineJoin = JOINROUND;
    [self.canvas addShape:s];
    
    for (int i = 0; i < 28; i++) {
        C4Shape *s = [C4Shape ellipse:CGRectMake(0, 0, 8, 8)];
        s.center = pts[i];
        [self.canvas addShape:s];
    }
}

-(void)createDrawnLetters {
    [C4Shape defaultStyle].lineWidth = 0.0f;
    [C4Shape defaultStyle].fillColor = C4GREY;

    NSMutableArray *rethinkingDrawn = [rethinking mutableCopy];
    
    C4Shape *letter;
    
    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    CGAffineTransform t;
    t = CGAffineTransformMakeScale(2.2, 2.2);
    CGPathRef scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)rethinkingDrawn[0]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(186.00,360.00);
    letter.rotation = -.64;
    //192.00,368.00, -.64
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);
    
    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(2.0, 2.0);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)rethinkingDrawn[1]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(242.00,320.00);
    letter.rotation = -.56;
    //192.00,368.00, -.64
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(1.8, 1.8);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)rethinkingDrawn[2]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(280.00,296.00);
    letter.rotation = -.45;
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(1.6, 1.6);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)rethinkingDrawn[3]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(324.00,274.00);
    letter.rotation = -.32;
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(1.4, 1.4);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)rethinkingDrawn[4]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(364.00,262.00);
    letter.rotation = -.22;
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(1.2,1.2);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)rethinkingDrawn[5]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(396.00,256.00);
    letter.rotation = -.12;
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);
    
    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(1.0,1.0);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)rethinkingDrawn[6]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(430.00,252.00);
    letter.rotation = -.0;
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);
    
    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.8,0.8);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)rethinkingDrawn[7]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(458.00,252.00);
    letter.rotation = .12;
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.6,0.6);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)rethinkingDrawn[8]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(478.00,255.00);
    letter.rotation = .18;
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.4,0.4);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)rethinkingDrawn[9]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(495.00,259.00);
    letter.rotation = .26;
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    //THE
    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.3,0.3);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)the[0]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(510,262.00);
    letter.rotation = .28;
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.36,0.36);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)the[1]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(519,265.00);
    letter.rotation = .29;
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.42,0.42);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)the[2]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(528,268.00);
    letter.rotation = .30;
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    //BASELINE
    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.48,0.48);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)baseline[0]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(548,276.00);
    letter.rotation = .36;
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.54,0.54);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)baseline[1]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(560,280.00);
    letter.rotation = .36;
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.6,0.6);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)baseline[2]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(575,286.00);
    letter.rotation = .36;
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.66,0.66);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)baseline[3]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(589,292.00);
    letter.rotation = .4;
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.72,0.72);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)baseline[4]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(605,299.00);
    letter.rotation = .42;
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);
    
    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.78,0.78);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)baseline[5]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(622,306.00);
    letter.rotation = .42;
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);
    
    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.84,0.84);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)baseline[6]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(640,314.00);
    letter.rotation = .32;
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.9,0.9);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)baseline[7]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(664,322.00);
    letter.rotation = .26;
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [points removeAllObjects];
    points = [@[] mutableCopy];

    CGPoint p = [[touches anyObject] locationInView:self.canvas];
    NSValue *v = [NSValue valueWithCGPoint:p];
    [points addObject:v];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint p = [[touches anyObject] locationInView:self.canvas];
    NSValue *v = [NSValue valueWithCGPoint:p];
    [points addObject:v];
}

-(void)touchesEnded {
    CGPoint pts[points.count];

    for(int i = 0; i < points.count; i++) {
        NSValue *v = points[i];
        CGPoint p = [v CGPointValue];
        pts[i] = p;
    }
    
    for(int i = 0; i < points.count; i++) {
        C4Log(@"CGPointMake(%4.2f,%4.2f),",pts[i]);
    }
    
    C4Shape *s = [C4Shape polygon:pts pointCount:points.count];
    [self.canvas addShape:s];

    for(int i = 0; i < points.count; i++) {
        C4Shape *s = [C4Shape ellipse:CGRectMake(0, 0, 8, 8)];
        s.center = pts[i];
        [self.canvas addShape:s];
    }
}

@end
