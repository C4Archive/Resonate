//
//  C4WorkSpace.m
//  ArtMovieView
//
//  Created by Slant on 2014-03-10.
//

#import "C4Workspace.h"

@implementation C4WorkSpace {
    NSArray *movies;
    NSInteger movieIndex;
    C4Movie *m;
    C4Shape *mask;
    NSMutableArray *lines;
    C4Timer *t;
    C4Shape *r;
    CGFloat height;
}

//FIXME: Lines can't act as masks (wtf?)
-(void)setup {
    movieIndex = 0;
    movies = @[[C4Movie movieNamed:@"RedC4Short.mov"],
              [C4Movie movieNamed:@"WeSitRoomShort.mp4"],
              [C4Movie movieNamed:@"BlackSheepShort.mp4"]];
    self.canvas.backgroundColor = [UIColor blackColor];
    
    [self replaceMovie];
    [self runMethod:@"startAnimateIn" afterDelay:0.25f];
    [self listenFor:@"reachedEnd" andRunMethod:@"nextMovie"];
    
    [self addGesture:LONGPRESS name:@"long" action:@"restart"];
}

-(void)restart {
    movieIndex = 0;
    for(int i = 0; i < movies.count; i++) {
        C4Movie *movie = movies[i];
        [movie seekToTime:0];
    }
    [self replaceMovie];
    [self runMethod:@"startAnimateIn" afterDelay:0.25f];
}

-(void)nextMovie {
    movieIndex++;
    [self startAnimateOut];
    if(movieIndex < 3) {
        [self runMethod:@"replaceMovie" afterDelay:2.5f];
        [self runMethod:@"startAnimateIn" afterDelay:2.75f];
    }
}

-(void)replaceMovie {
    [m pause];
    
    //remove all the objects
    for(int i = 0; i < lines.count; i++) {
        C4Shape *s = lines[i];
        [s removeFromSuperview];
        s = nil;
    }
    
    [mask removeFromSuperview];
    mask = nil;
    
    [m removeFromSuperview];
    
    //create the new movie
    m = movies[movieIndex];
    m.width = self.canvas.width;
    
    //create the new mask
    mask = [C4Shape rect:m.bounds];
    //FIXME: height doesn't get set when width gets set for movies
    height = m.bounds.size.height / 20.0f;
    mask.lineWidth = 0;
    mask.fillColor = [UIColor clearColor];
    lines = [@[] mutableCopy];
    for(int i = 0; i < 20; i++) {
        C4Shape *shape = [C4Shape rect:CGRectMake(-m.width, i * height, m.width, height+1)];
        shape.alpha = 0.0f;
        [mask addSubview:shape];
        [lines addObject:shape];
    }
    m.center = self.canvas.center;
    
    m.mask = mask;
    [self.canvas addSubview:m];
    m.shouldAutoplay = YES;
    [m play];
}

//FIXME: there's a bug in setting the line animation duration for stroke end / start
//the following shouldn't require setting any value other than 0 for the duration
//
-(void)resetStrokePoints {
    int x = x;
    for(int i = 0; i < lines.count; i++) {
        C4Shape *line = lines[i];
        line.animationDuration = 0.0f;
        line.alpha = 0;
    }
    
    for(int i = 0; i < lines.count; i++) {
        C4Shape *line = lines[i];
        line.animationDuration = 0.01;
        line.strokeStart = 0.;
        line.strokeEnd = 0.;
    }
    
    for(int i = 0; i < lines.count; i++) {
        C4Shape *line = lines[i];
        line.animationDuration = 0.0;
        line.alpha = 1;
    }
}

-(void)startAnimateIn {
    for (int i = 0; i < lines.count; i++) {
        [self runMethod:@"maskLineIn:" withObject:lines[i] afterDelay:i * .05];
    }
}

-(void)startAnimateOut {
    for (int i = 0; i < lines.count; i++) {
        [self runMethod:@"maskLineOut:" withObject:lines[i] afterDelay:i * .05];
    }
}

-(void)resetPositions {
    for(int i = 0; i < lines.count; i++) {
        C4Shape *s = lines[i];
        s.animationDuration = 0.0f;
        s.origin = CGPointMake(-m.width, s.origin.y);
    }
}

-(void)maskLineIn:(C4Shape *)shape {
    shape.animationDuration = 1.0f;
    shape.origin = CGPointMake(0,shape.origin.y);
    shape.alpha = 1.0f;
}

-(void)maskLineOut:(C4Shape *)shape {
    shape.animationDuration = 1.0f;
    shape.origin = CGPointMake(m.width,shape.origin.y);
    shape.alpha = 0.0f;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

@end
