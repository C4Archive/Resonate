//
//  C4WorkSpace.m
//  Conclusion
//
//  Created by Slant on 2014-04-04.
//

#import "C4Workspace.h"
#import "C4Logo.h"

@implementation C4WorkSpace {
    C4Label *label;
    C4Font *font;
    NSInteger index;
    NSArray *pages;
    
    C4Image *image;
    C4Control *currentObject;
    
    NSArray *colors;
    NSArray *shapes;
    C4Logo *logo;
}

-(void)setup {
    [self setupLines];
    [self createLogo];
    
    index = -1;
    font = [C4Font fontWithName:@"Menlo-Regular" size:48];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"pages" ofType:@"plist"];
    pages = [NSArray arrayWithContentsOfFile:path];
    
    label = [C4Label labelWithText:@" " font:font];
    label.center = self.canvas.center;
    label.numberOfLines = 25;
    label.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    image = [C4Image imageNamed:@"iPhone"];
    
    [C4Image defaultStyle].borderColor = [C4GREY colorWithAlphaComponent:.5];
    
    currentObject = label;
    [self.canvas addLabel:label];
    [self addGesture:SWIPERIGHT name:@"swipeRight" action:@"swipedRight"];
    [self addGesture:SWIPELEFT name:@"swipeLeft" action:@"swipedLeft"];
    
    [self addGesture:PAN name:@"pan" action:@"pan:"];
    [self minimumNumberOfTouches:2 forGesture:@"pan"];
}

-(void)pan:(id)sender {
    UIPanGestureRecognizer *p = (UIPanGestureRecognizer *)sender;
    CGFloat x = [p locationInView:self.canvas].x;
    if(x > 20 && x < self.canvas.width - 20) {
        x -= 20;
        x /= (self.canvas.width - 40);
        x *= pages.count;
        index = (NSInteger)x;
        [self loadPage];
        image.animationDuration = 0;
        image.alpha = 0;
        label.animationDuration = 0;
        label.alpha = 0;
        currentObject.animationDuration = 0;
        currentObject.alpha = 1;
    }
}

-(void)nextPage {
    NSInteger pagesCount = pages.count;
    
    if(index < pagesCount - 1) {
        index++;
        [self fadeCurrentPage];
    }
}

-(void)fadeCurrentPage {
    currentObject.animationDuration = 0.1f;
    currentObject.alpha = 0.0f;
    [self runMethod:@"loadPageReveal" afterDelay:currentObject.animationDuration];
}

-(void)revealCurrentPage {
    currentObject.animationDuration = 0.25f;
    currentObject.alpha = 1.0f;
}

-(void)prevPage {
    if(index > 0) {
        index--;
        [self fadeCurrentPage];
    }
}

-(void)loadPageReveal {
    [self loadPage];
    [self runMethod:@"revealCurrentPage" afterDelay:0.1f];
}

-(void)loadPage {
    NSDictionary *currentPageData = pages[index];
    if([currentPageData[@"type"] isEqualToString:@"text"]) {
        label.animationDuration = 0.0f;
        label.text = currentPageData[@"string"];
        label.frame = self.canvas.bounds;
        [label sizeToFit];
        label.center = self.canvas.center;
        label.alpha = 0.0f;
        currentObject = label;
    } else {
        if([currentPageData[@"type"] isEqualToString:@"image"]) {
            [C4Image defaultStyle].borderWidth = 0.5;
        } else {
            [C4Image defaultStyle].borderWidth = 0.0;
        }
        image.animationDuration = 0.0f;
        [image removeFromSuperview];
        image = nil;
        image = [C4Image imageNamed:currentPageData[@"string"]];
        [self.canvas addImage:image];
        image.alpha = 0.0f;
        image.center = self.canvas.center;
        currentObject = image;
    }
}

-(void)swipedRight {
    [self prevPage];
}

-(void)swipedLeft {
    [self nextPage];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)createLogo {
    logo = [[C4Logo alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    logo.origin = CGPointMake(10, self.canvas.height-logo.height-10);
    [logo setup];
    [self.canvas addSubview:logo];
}

-(void)setupLines {
    for(int x = -self.canvas.height, i = 0; x < self.canvas.width; x += 20, i++) {
        CGPoint pts[2] = {CGPointMake(x, 0),CGPointMake(x + self.canvas.height, self.canvas.height)};
        C4Shape *line = [C4Shape line:pts];
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
        line.lineWidth = 0.25f;
        [self.canvas addShape:line];
        [self runMethod:@"animate:" withObject:line afterDelay:i * 0.25f];
    }
}

-(void)animate:(C4Shape *)line {
    line.animationDuration = 20.0f;
    line.animationOptions = REPEAT;
    line.rotation = PI;
}

@end
