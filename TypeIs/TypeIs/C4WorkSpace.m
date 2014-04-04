//
//  C4WorkSpace.m
//  TypeIs
//
//  Created by travis on 2014-03-25.
//

#import "C4Workspace.h"
#import "C4Logo.h"

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
    NSMutableArray *rethinkingDrawn;
    C4Logo *logo;
    
    NSInteger touchIndex;
}

-(void)setup {
    touchIndex = 0;
    [self createLogo];
    [self setupRandomLines];
    
    textLandscape = [C4Movie movieNamed:@"textLandscapeiPadShort.mov"];
    textLandscape.width = self.canvas.width;
    textLandscape.center = self.canvas.center;
    textLandscape.alpha = 0.0f;
    [self.canvas addMovie:textLandscape];
    
    [self createSlides];
    [self listenFor:@"reachedEnd" andRunMethod:@"initiateSlideShow"];
    [self listenFor:@"startNotification" andRunMethod:@"start"];
}

-(void)touchesBegan {
    switch (touchIndex) {
        case 1:
            [self createStraightLetters];
            break;
        case 2:
            [self createStraightBaseline];
            break;
        case 3:
            [self createDrawnBaseline];
            break;
        case 4:
            [self createDrawnLetters];
            break;
    }
    touchIndex++;
}

-(void)start {
    textLandscape.animationDuration = 1.0f;
    textLandscape.alpha = 1.0f;
    [textLandscape play];
}

-(void)createLogo {
    logo = [[C4Logo alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    logo.origin = CGPointMake(10, self.canvas.height-logo.height-10);
    [logo setup];
    [self.canvas addSubview:logo];
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
    [self runMethod:@"revealSlide:" withObject:slides[0] afterDelay:1.0f];
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
        s.alpha = 0.0f;
        [rethinking addObject:s];
    }

    the = [@[] mutableCopy];
    [C4Shape defaultStyle].lineWidth = 0.0f;
    for(int i = 0; i < theLetters.count; i++) {
        C4Shape *s = [C4Shape shapeFromString:[theLetters[i] uppercaseString] withFont:f];
        if(i == 0) s.origin = CGPointMake(500, self.canvas.height - 200);
        else {
            C4Shape *prevLetter = the[i-1];
            s.origin = CGPointMake(CGRectGetMaxX(prevLetter.frame)+4, CGRectGetMaxY(prevLetter.frame) - s.height);
        }
        s.alpha = 0.0f;
        [the addObject:s];
    }

    baseline = [@[] mutableCopy];
    [C4Shape defaultStyle].lineWidth = 0.0f;
    for(int i = 0; i < baselineLetters.count; i++) {
        C4Shape *s = [C4Shape shapeFromString:[baselineLetters[i] uppercaseString] withFont:f];
        if(i == 0) s.origin = CGPointMake(612,  self.canvas.height - 200);
        else {
            C4Shape *prevLetter = baseline[i-1];
            s.origin = CGPointMake(CGRectGetMaxX(prevLetter.frame)+4, CGRectGetMaxY(prevLetter.frame) - s.height);
        }
        s.alpha = 0.0f;
        [baseline addObject:s];
    }
    [self revealStraightBaselineLetters];
}

-(void)revealStraightBaselineLetters {
    [self.canvas addObjects:rethinking];
    [self.canvas addObjects:the];
    [self.canvas addObjects:baseline];

    NSMutableArray *allLetters = [@[] mutableCopy];
    [allLetters addObjectsFromArray:rethinking];
    [allLetters addObjectsFromArray:the];
    [allLetters addObjectsFromArray:baseline];
    
    for(int i = 0; i < allLetters.count; i++) {
        C4Shape *s = allLetters[i];
        [self runMethod:@"revealShape:" withObject:s afterDelay:i * .025];
    }
}

-(void)revealShape:(C4Shape *)shape {
    shape.animationDuration = 1.0f;
    shape.alpha = 1.0f;
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
    straightBaseline.strokeEnd = 0.0f;
    [self.canvas addShape:straightBaseline];
    
    straightBaselinePoint = [C4Shape ellipse:CGRectMake(0, 0, 8, 8)];
    straightBaselinePoint.center = pts[0];
    straightBaselinePoint.alpha = 0.0f;
    [self.canvas addShape:straightBaselinePoint];
    
    [self runMethod:@"revealShape:" withObject:straightBaselinePoint afterDelay:0.25f];
    [self runMethod:@"showBaseline:" withObject:straightBaseline afterDelay:1.0f];
}

-(void)showBaseline:(C4Shape *)baselineShape {
    baselineShape.animationDuration = 1.0f;
    baselineShape.strokeEnd = 1.0f;
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
    s.strokeEnd = 0.0f;
    [self.canvas addShape:s];
    [self runMethod:@"showBaseline:" withObject:s afterDelay:1.0f];
    
    for (int i = 0; i < 28; i++) {
        C4Shape *s = [C4Shape ellipse:CGRectMake(0, 0, 8, 8)];
        s.center = pts[i];
        s.alpha = 0.0f;
        [self.canvas addShape:s];
        if(i == 0) {
            [self revealShape:s];
        } else {
            [self runMethod:@"revealShape:" withObject:s afterDelay:2.0f+ (i * .05)];
        }
    }
}

-(void)createDrawnLetters {
    [C4Shape defaultStyle].lineWidth = 0.0f;
    [C4Shape defaultStyle].fillColor = C4GREY;

    rethinkingDrawn = [rethinking mutableCopy];
    
    C4Shape *letter;
    
    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    CGAffineTransform t;
    t = CGAffineTransformMakeScale(2.2, 2.2);
    CGPathRef scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)rethinkingDrawn[0]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(186.00,360.00);
    letter.rotation = -.64;
    letter.alpha = 0.0f;
    [rethinkingDrawn addObject:letter];
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);
    
    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(2.0, 2.0);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)rethinkingDrawn[1]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(242.00,320.00);
    letter.rotation = -.56;
    letter.alpha = 0.0f;
    [rethinkingDrawn addObject:letter];
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(1.8, 1.8);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)rethinkingDrawn[2]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(280.00,296.00);
    letter.rotation = -.45;
    letter.alpha = 0.0f;
    [rethinkingDrawn addObject:letter];
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(1.6, 1.6);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)rethinkingDrawn[3]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(324.00,274.00);
    letter.rotation = -.32;
    letter.alpha = 0.0f;
    [rethinkingDrawn addObject:letter];
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(1.4, 1.4);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)rethinkingDrawn[4]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(364.00,262.00);
    letter.rotation = -.22;
    letter.alpha = 0.0f;
    [rethinkingDrawn addObject:letter];
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(1.2,1.2);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)rethinkingDrawn[5]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(396.00,256.00);
    letter.rotation = -.12;
    letter.alpha = 0.0f;
    [rethinkingDrawn addObject:letter];
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);
    
    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(1.0,1.0);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)rethinkingDrawn[6]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(430.00,252.00);
    letter.rotation = -.0;
    letter.alpha = 0.0f;
    [rethinkingDrawn addObject:letter];
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);
    
    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.8,0.8);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)rethinkingDrawn[7]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(458.00,252.00);
    letter.rotation = .12;
    letter.alpha = 0.0f;
    [rethinkingDrawn addObject:letter];
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.6,0.6);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)rethinkingDrawn[8]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(478.00,255.00);
    letter.rotation = .18;
    letter.alpha = 0.0f;
    [rethinkingDrawn addObject:letter];
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.4,0.4);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)rethinkingDrawn[9]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(495.00,259.00);
    letter.rotation = .26;
    letter.alpha = 0.0f;
    [rethinkingDrawn addObject:letter];
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
    letter.alpha = 0.0f;
    [rethinkingDrawn addObject:letter];
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.36,0.36);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)the[1]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(519,265.00);
    letter.rotation = .29;
    letter.alpha = 0.0f;
    [rethinkingDrawn addObject:letter];
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.42,0.42);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)the[2]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(528,268.00);
    letter.rotation = .30;
    letter.alpha = 0.0f;
    [rethinkingDrawn addObject:letter];
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
    letter.alpha = 0.0f;
    [rethinkingDrawn addObject:letter];
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.54,0.54);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)baseline[1]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(560,280.00);
    letter.rotation = .36;
    letter.alpha = 0.0f;
    [rethinkingDrawn addObject:letter];
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.6,0.6);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)baseline[2]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(575,286.00);
    letter.rotation = .36;
    letter.alpha = 0.0f;
    [rethinkingDrawn addObject:letter];
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.66,0.66);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)baseline[3]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(589,292.00);
    letter.rotation = .4;
    letter.alpha = 0.0f;
    [rethinkingDrawn addObject:letter];
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.72,0.72);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)baseline[4]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(605,299.00);
    letter.rotation = .42;
    letter.alpha = 0.0f;
    [rethinkingDrawn addObject:letter];
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);
    
    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.78,0.78);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)baseline[5]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(622,306.00);
    letter.rotation = .42;
    letter.alpha = 0.0f;
    [rethinkingDrawn addObject:letter];
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);
    
    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.84,0.84);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)baseline[6]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(640,314.00);
    letter.rotation = .32;
    letter.alpha = 0.0f;
    [rethinkingDrawn addObject:letter];
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);

    letter = [C4Shape rect:CGRectMake(0, 0, 1, 1)];
    t = CGAffineTransformMakeScale(0.9,0.9);
    scaledPath = CGPathCreateCopyByTransformingPath(((C4Shape *)baseline[7]).path, &t);
    letter.path = scaledPath;
    
    letter.anchorPoint = CGPointMake(0,1);
    letter.center = CGPointMake(664,322.00);
    letter.rotation = .26;
    letter.alpha = 0.0f;
    [rethinkingDrawn addObject:letter];
    [self.canvas addShape:letter];
    CGPathRelease(scaledPath);
    
    [self revealRethinkingDrawnLetters];
}

-(void)revealRethinkingDrawnLetters {
    for (int i = 0; i < rethinkingDrawn.count; i++) {
        C4Shape *s = rethinkingDrawn[i];
        [self runMethod:@"revealShape:" withObject:s afterDelay:i * .05];
    }
}

-(void)revealDrawnBaselineLetters {
    [self.canvas addObjects:rethinking];
    [self.canvas addObjects:the];
    [self.canvas addObjects:baseline];
    
    NSMutableArray *allLetters = [@[] mutableCopy];
    [allLetters addObjectsFromArray:rethinking];
    [allLetters addObjectsFromArray:the];
    [allLetters addObjectsFromArray:baseline];
    
    for(int i = 0; i < allLetters.count; i++) {
        C4Shape *s = allLetters[i];
        [self runMethod:@"revealShape:" withObject:s afterDelay:i * .025];
    }
}


//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [points removeAllObjects];
//    points = [@[] mutableCopy];
//
//    CGPoint p = [[touches anyObject] locationInView:self.canvas];
//    NSValue *v = [NSValue valueWithCGPoint:p];
//    [points addObject:v];
//}
//
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    CGPoint p = [[touches anyObject] locationInView:self.canvas];
//    NSValue *v = [NSValue valueWithCGPoint:p];
//    [points addObject:v];
//}
//
//-(void)touchesEnded {
//    CGPoint pts[points.count];
//
//    for(int i = 0; i < points.count; i++) {
//        NSValue *v = points[i];
//        CGPoint p = [v CGPointValue];
//        pts[i] = p;
//    }
//    
//    for(int i = 0; i < points.count; i++) {
//        C4Log(@"CGPointMake(%4.2f,%4.2f),",pts[i]);
//    }
//    
//    C4Shape *s = [C4Shape polygon:pts pointCount:points.count];
//    [self.canvas addShape:s];
//
//    for(int i = 0; i < points.count; i++) {
//        C4Shape *s = [C4Shape ellipse:CGRectMake(0, 0, 8, 8)];
//        s.center = pts[i];
//        [self.canvas addShape:s];
//    }
//}

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
