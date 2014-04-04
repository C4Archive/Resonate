//
//  C4WorkSpace.m
//  Properties
//
//  Created by Slant on 2014-04-04.
//

#import "C4Workspace.h"
#import "C4Logo.h"

@implementation C4WorkSpace {
    C4Logo *logo;
    C4Label *mainLabel;
    C4Shape *s, *t, *u;
    NSInteger touchIndex;
    BOOL objectsAreListening;
    C4Image *image;
    C4Movie *movie;
    C4Sample *audio;
    C4GL *gl;
}

-(void)createLogo {
    logo = [[C4Logo alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    logo.origin = CGPointMake(10, self.canvas.height-logo.height-10);
    [logo setup];
    [self.canvas addSubview:logo];
}

-(void)setup {
    [self createLogo];
    
    C4Font *font = [C4Font fontWithName:@"Menlo-Regular" size:24];
    mainLabel = [C4Label labelWithText:@"PROPERTIES" font:font];
    mainLabel.numberOfLines = 20;
    mainLabel.frame = CGRectMake(20, 0, 640, self.canvas.height);
    [self.canvas addLabel:mainLabel];

}

-(void)touchesBegan {
    switch (touchIndex) {
        case 0:
            [self addMedia];
            mainLabel.text = @"[C4Shape ellipse:{0,0,100,100}];";
            s = [C4Shape ellipse:CGRectMake(0, 0, 100, 100)];
            break;
        case 1:
            mainLabel.text = @"[self.canvas addShape:s];";
            [self.canvas addShape:s];
            break;
        case 2:
            s.center = CGPointMake(768,384);
            mainLabel.text = @"s.center = CGPointMake(768,384);";
            break;
        case 3:
            s.origin = CGPointZero;
            mainLabel.text = @"s.origin = CGPointZero;";
            break;
        case 4:
            s.animationDuration = 1.0f;
            mainLabel.text = @"s.animationDuration = 1.0f;";
            break;
        case 5:
            s.center = CGPointMake(768,384);
            mainLabel.text = @"s.center = CGPointMake(768,384);";
            break;
        case 6:
            s.fillColor = C4RED;
            mainLabel.text = @"s.fillColor = C4RED;";
            break;
        case 7:
            s.rotation += TWO_PI;
            mainLabel.text = @"s.rotation = TWO_PI;";
            break;
        case 8:
            [s rect:s.frame];
            mainLabel.text = @"[s rect:s.frame];";
            break;
        case 9:
            s.animationOptions = AUTOREVERSE;
            mainLabel.text = @"s.animationOptions = AUTOREVERSE;";
            break;
        case 10:
            s.rotation += TWO_PI;
            mainLabel.text = @"s.rotation = TWO_PI;";
            break;
        case 11:
            s.perspectiveDistance = 100;
            mainLabel.text = @"s.perspectiveDistance = 500;";
            break;
        case 12:
            s.rotationX = PI;
            mainLabel.text = @"s.rotationX = PI;";
            break;
        case 13:
            s.animationOptions = 0;
            mainLabel.text = @"s.animationOptions = 0;";
            break;
        case 14:
            [s ellipse:s.frame];
            mainLabel.text = @"[s ellipse:s.frame];";
            break;
        case 15:
            [self addObjects];
            mainLabel.text = @"-(void)addObjects {\nCGRect frame = CGRectMake(0, 0, 100, 100);\nt = [C4Shape ellipse:frame];\nt.strokeColor = C4RED;\nt.center = CGPointMake(768, 192);\n\nu = [C4Shape ellipse:frame];\nu.fillColor = C4BLUE;\nu.strokeColor = C4GREY;\nu.center = CGPointMake(768, 576);\n\n[self.canvas addObjects:@[t,u]];\n}";
            break;
        case 16:
            [self listenFor:@"touchesBegan" fromObjects:@[s,t,u] andRunMethod:@"pulse:"];
            mainLabel.text = @"[self listenFor:@\"touchesBegan\"\n    fromObjects:@[s,t,u]\n   andRunMethod:@\"pulse:\"];";
            break;
        case 17:
            objectsAreListening = YES;
            mainLabel.text = @"objectsAreListening = YES;";
            break;
        case 18:
            [self showBorder:s];
            [self showBorder:t];
            [self showBorder:u];
            mainLabel.text = @"-(void)showBorder:(C4Shape *)shape {\nshape.animationDuration = 1.0f;\nshape.borderColor = s.strokeColor;\nshape.borderWidth = 2.0f;\n}";
            break;
        case 19:
            [self hideShape:s];
            [self hideShape:t];
            [self hideShape:u];
            mainLabel.text = @"[self hideShapes];";
            break;
        case 20:
            [self addMedia];
            mainLabel.text = @"[self revealMedia];";
            break;
        case 21:
            [self playMedia];
            mainLabel.text = @"[self playMedia];";
            break;
        default:
            break;
    }
    touchIndex++;
}

-(void)pulse:(NSNotification *)aNotification {
    C4Shape *obj = [aNotification object];

    if(objectsAreListening) {
        if([obj isEqual:s]) {
            [self shape:t changeColor:s.strokeColor afterDelay:0.75];
            [self shape:u changeColor:s.strokeColor afterDelay:0.75];
        } else if([obj isEqual:t]) {
            [self shape:s changeColor:t.strokeColor afterDelay:0.75];
            [self shape:u changeColor:t.strokeColor afterDelay:1.25];
        } else if([obj isEqual:u]) {
            [self shape:s changeColor:u.strokeColor afterDelay:0.75];
            [self shape:t changeColor:u.strokeColor afterDelay:1.25];
        }
    }
    
    C4Shape *pulse = [C4Shape ellipse:CGRectMake(0, 0, 10, 10)];
    pulse.center = obj.center;
    pulse.fillColor = [UIColor clearColor];
    pulse.strokeColor = obj.strokeColor;
    pulse.userInteractionEnabled = NO;
    [self.canvas addShape:pulse];
    [self runMethod:@"animatePulse:" withObject:pulse afterDelay:0.1f];
}

-(void)shape:(C4Shape *)shape changeColor:(UIColor *)c afterDelay:(CGFloat)delay {
    shape.animationDuration = 0.5f;
    [shape runMethod:@"setFillColor:" withObject:c afterDelay:delay];
}

-(void)animatePulse:(C4Shape *)pulse {
    CGPoint center = pulse.center;
    pulse.animationDuration = 2.0f;
    [pulse ellipse:CGRectMake(0, 0, 1024, 1024)];
    pulse.center = center;
    pulse.alpha = 0.0f;
    [pulse runMethod:@"removeFromSuperview" afterDelay:2.1f];
}
                              
-(void)addObjects {
    CGRect frame = CGRectMake(0, 0, 100, 100);
    t = [C4Shape ellipse:frame];
    t.strokeColor = C4RED;
    t.center = CGPointMake(768, 192);
    
    u = [C4Shape ellipse:frame];
    u.fillColor = C4BLUE;
    u.strokeColor = C4GREY;
    u.center = CGPointMake(768, 576);

    [self.canvas addObjects:@[t,u]];
}
                              
-(void)showBorder:(C4Shape *)shape {
    shape.animationDuration = 1.0f;
    shape.borderColor = shape.strokeColor;
    shape.borderWidth = 2.0f;
}

-(void)hideShape:(C4Shape *)shape {
    shape.animationOptions = 0;
    shape.animationDuration = 1.0f;
    shape.alpha = 0.0f;
    [shape runMethod:@"removeFromSuperview" afterDelay:1.05];
}

-(void)addMedia {
    image = [C4Image imageNamed:@"C4Sky"];
    image.width = 200;
    image.center = CGPointMake(768, self.canvas.height / 3.0f);
    image.alpha = 0.0f;
    
    movie = [C4Movie movieNamed:@"inception.mov"];
    movie.width = 320;
    movie.center = CGPointMake(768, self.canvas.height / 3.0f * 2);
    movie.alpha = 0.0f;
    
    audio = [C4Sample sampleNamed:@"C4Loop.aif"];
    
    [self.canvas addObjects:@[image, movie]];
    [self runMethod:@"revealMedia" afterDelay:0.25f];
}

-(void)revealMedia {
    image.animationDuration = 0.5f;
    image.alpha = 1.0f;
    
    movie.animationDuration = 1.0f;
    movie.alpha = 1.0f;
}

-(void)playMedia {
    image.animationDuration = 5.0f;
    [image colorInvert];
    [movie play];
    [audio play];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}
@end
