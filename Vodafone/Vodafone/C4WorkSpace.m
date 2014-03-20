//
//  C4WorkSpace.m
//  Vodafone
//
//  Created by travis on 2014-03-20.
//

#import "C4Workspace.h"

@implementation C4WorkSpace {
    C4View *device, *menuView;
    NSMutableArray *menuItems;
    NSInteger menuLevel;
    NSInteger pDir;
    
    NSArray *views;
    NSInteger articleLevel, tapCount;
    CGFloat width;
    C4View *mainView;
    BOOL allowMainViewInteraction;
}

-(void)setup {
    device = [[C4View alloc] initWithFrame:CGRectMake(0, 0, 230, 320)];
    device.backgroundColor = [UIColor clearColor];
    device.borderColor = C4GREY;
    device.borderWidth = 10.0f;
    device.cornerRadius = 3.0f;
    device.perspectiveDistance = 500;
    pDir = 0;
    [self.canvas addSubview:device];
    device.center = self.canvas.center;
    [self createSubMenu];
    
    [self addGesture:SWIPEUP name:@"su" action:@"swipedUp"];
    [self addGesture:SWIPEDOWN name:@"sd" action:@"swipedDown"];
    [self addGesture:SWIPELEFT name:@"sl" action:@"swipedLeft"];
    [self addGesture:SWIPERIGHT name:@"sr" action:@"swipedRight"];
    [self addGesture:TAP name:@"tap" action:@"tapped"];
    [self numberOfTouchesRequired:2 forGesture:@"tap"];
    [self runMethod:@"addText" afterDelay:1.f];
    [self runMethod:@"addMenu" afterDelay:6.0f];
    tapCount = 0;
}

-(void)tapped {
    if(tapCount == 0) {
        mainView.animationDuration = 1.0f;
        mainView.alpha = 1.0f;
        allowMainViewInteraction = YES;
        tapCount++;
    } else if(tapCount == 1) {
        mainView.animationDuration = 1.0f;
        mainView.alpha = 0.0f;
        menuView.animationDuration = 1.0f;
        menuView.alpha = 0.0f;
        device.animationDuration = 1.0f;
        device.alpha = 0.33f;
        
        C4Shape *s = [C4Shape shapeFromString:@"FLIP GESTURE <> LAYERED DATA" withFont:[C4Font fontWithName:@"Menlo-Bold" size:48]];
        s.center = self.canvas.center;
        s.alpha = 0.0f;
        [self.canvas addShape:s];
        [self runMethod:@"revealTitle:" withObject:s afterDelay:1.25f];
        tapCount++;
    }
}

-(void)revealTitle:(C4Shape *)shape {
    shape.animationDuration = 1.0f;
    shape.alpha = 1.0f;
}

-(void)createSubMenu {
    NSArray *libContent = @[@"NEWSPAPERS",@"BOOKS",@"MAGAZINES",@"PDFS",@"IMAGES"];
    NSArray *paperContent = @[@"GUARDIAN",@"DIE ZEIT",@"NYTIMES",@"EL PAIS"];
    NSArray *sectionContent = @[@"INTERNATIONAL",@"NATIONAL",@"POLITICS",@"BUSINESS"];
    NSArray *articleContent = @[@"KOCH GROUP",@"SENATE v. CIA",@"CRIMEAN CRISIS",@"GEN. REPRIMANDED"];
    
    [C4Shape defaultStyle].lineWidth = 0.0f;
    C4Font *font = [C4Font fontWithName:@"Menlo-Bold" size:24];
    width = 480.0f;
    
    C4View *libView = [[C4View alloc] initWithFrame:CGRectMake(0, 0, width * libContent.count, 66)];
    for (int i = 0; i < libContent.count; i++) {
        C4Shape *s = [C4Shape shapeFromString:libContent[i] withFont:font];
        s.center = CGPointMake(width * i + width/2, 33);
        [libView addShape:s];
    }
    
    C4View *paperView = [[C4View alloc] initWithFrame:CGRectMake(0, 0, width * paperContent.count, 66)];
    for (int i = 0; i < paperContent.count; i++) {
        C4Shape *s = [C4Shape shapeFromString:paperContent[i] withFont:font];
        s.center = CGPointMake(width * i + width/2, 33);
        [paperView addShape:s];
    }
    
    C4View *sectionView = [[C4View alloc] initWithFrame:CGRectMake(0, 0, width * sectionContent.count, 66)];
    for (int i = 0; i < sectionContent.count; i++) {
        C4Shape *s = [C4Shape shapeFromString:sectionContent[i] withFont:font];
        s.center = CGPointMake(width * i + width/2, 33);
        [sectionView addShape:s];
    }
    
    C4View *articleView = [[C4View alloc] initWithFrame:CGRectMake(0, 0, width * articleContent.count, 66)];
    for (int i = 0; i < articleContent.count; i++) {
        C4Shape *s = [C4Shape shapeFromString:articleContent[i] withFont:font];
        s.center = CGPointMake(width * i + width/2, 33);
        [articleView addShape:s];
    }
    
    mainView = [[C4View alloc] initWithFrame:CGRectMake(0, 0, width, 66)];
    mainView.borderWidth = 1.0f;
    libView.origin = CGPointMake(0,0);
    paperView.origin = CGPointMake(0, 66);
    sectionView.origin = CGPointMake(0, 132);
    articleView.origin = CGPointMake(0, 198);
    
    views = @[libView,paperView,sectionView,articleView];
    [mainView addObjects:views];
    
    [self addGesture:SWIPEUP name:@"su" action:@"swipedUp"];
    [self addGesture:SWIPEDOWN name:@"sd" action:@"swipedDown"];
    [self addGesture:SWIPELEFT name:@"sl" action:@"swipedLeft"];
    [self addGesture:SWIPERIGHT name:@"sr" action:@"swipedRight"];
    
    mainView.userInteractionEnabled = NO;
    mainView.center = CGPointMake(self.canvas.center.x, self.canvas.height - 88);
    mainView.clipsToBounds = YES;
    mainView.alpha = 0.0f;
    [self.canvas addSubview:mainView];
}

-(void)addText {
    device.animationDuration = 1.5f;
    device.alpha = 0.33f;
    
    C4Font *f = [C4Font fontWithName:@"Menlo-Bold" size:32];
    
    NSArray *titles = @[@"BOOKS", @"MAGS", @"NEWSPAPERS", @"PDFs",@"IMAGES"];
    CGFloat dx = self.canvas.width / (titles.count + 1);
    for (int i = 0; i < titles.count; i++) {
        C4Shape *s = [C4Shape shapeFromString:titles[i] withFont:f];
        s.lineWidth = 0.;
        s.alpha = 0.;
        s.center = CGPointMake(i * dx + dx, self.canvas.center.y);
        [self.canvas addShape:s];
        [self runMethod:@"revealShape:" withObject:s afterDelay:i * .25f];
        [self runMethod:@"hideShape:" withObject:s afterDelay:4 + i * .25f];
    }
    
    [self runMethod:@"revealView:" withObject:device afterDelay:4.0f];
}

-(void)addMenu {
    menuView = [[C4View alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    menuLevel = 0;
    C4Font *f = [C4Font fontWithName:@"Menlo-Bold" size:36];
    NSArray *titles = @[@"LIBRARY", @"ITEM", @"SECTION", @"SUBSECTION"];
    CGFloat dy = 0;
    menuItems = [@[] mutableCopy];
    for (int i = 0; i < titles.count; i++) {
        C4Shape *s = [C4Shape shapeFromString:titles[i] withFont:f];
        if(i == 0) dy = s.height * 1.25;
        s.lineWidth = 0.;
        
        if(i == 0) s.alpha = 1.0;
        else s.alpha = .33f;
        
        s.origin = CGPointMake(80, i * dy - 2 * dy + self.canvas.center.y);
        [menuView addShape:s];
        [menuItems addObject:s];
    }
    menuView.alpha = 0.0f;
    [self.canvas addSubview:menuView];
    [self runMethod:@"revealView:" withObject:menuView afterDelay:1.0f];
}

-(void)revealView:(C4View *)view {
    view.animationDuration = 1.5f;
    view.alpha = 1.0f;
}

-(void)revealShape:(C4Shape *)shape {
    shape.animationDuration = 1.f;
    shape.alpha = 1.0f;
}

-(void)hideShape:(C4Shape *)shape {
    shape.animationDuration = 1.f;
    shape.alpha = 0.0f;
}

-(void)swipedDown {
    if(menuLevel < 3) {
        device.animationDuration = 1.0f;
        device.rotationX += PI;
        C4Shape *menuItem = menuItems[menuLevel];
        menuItem.animationDuration = 1.0f;
        menuItem.alpha = 0.33f;
        
        if(allowMainViewInteraction) {
            for (int i = 0; i < views.count; i++) {
                C4View *v = views[i];
                v.animationDuration = 1.0f;
                v.origin = CGPointMake(v.origin.x, v.origin.y - 66);
            }
        }

        menuLevel++;
        menuItem = menuItems[menuLevel];
        menuItem.animationDuration = 1.0f;
        menuItem.alpha = 1.0f;
    }
}

-(void)swipedUp {
    if(menuLevel > 0) {
        device.animationDuration = 1.0f;
        device.rotationX -= PI;
        C4Shape *menuItem = menuItems[menuLevel];
        menuItem.animationDuration = 1.0f;
        menuItem.alpha = 0.33f;

        if(allowMainViewInteraction) {
            for (int i = 0; i < views.count; i++) {
                C4View *v = views[i];
                v.animationDuration = 1.0f;
                v.origin = CGPointMake(v.origin.x, v.origin.y + 66);
            }
        }

        menuLevel--;
        menuItem = menuItems[menuLevel];
        menuItem.animationDuration = 1.0f;
        menuItem.alpha = 1.0f;
    }
}

-(void)swipedLeft {
    if(articleLevel < 3) {
        device.animationDuration = 1.0f;
        if(pDir == 1){
            device.rotationY -= PI;
            pDir = -1;
        }
        else {
            device.rotationY += PI;
            pDir = 1;
        }
        
        if(allowMainViewInteraction) {
            for (int i = 0; i < views.count; i++) {
                C4View *v = views[i];
                v.animationDuration = 1.0f;
                v.origin = CGPointMake(v.origin.x - width, v.origin.y);
            }
            articleLevel++;
        }
        
    }
}

-(void)swipedRight {
    if(articleLevel > 0) {
        device.animationDuration = 1.0f;
        if(pDir == 1){
            device.rotationY += PI;
            pDir = -1;
        }
        else {
            device.rotationY -= PI;
            pDir = 1;
        }
        
        if(allowMainViewInteraction) {
            for (int i = 0; i < views.count; i++) {
                C4View *v = views[i];
                v.animationDuration = 1.0f;
                v.origin = CGPointMake(v.origin.x + width, v.origin.y);
            }
            articleLevel--;
        }
    }
}

@end
