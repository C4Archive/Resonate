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
}

-(void)setup {
    C4Font *f = [C4Font fontWithName:@"Menlo-Regular" size:48];
    rethinkingLetters = @[@"r",@"e",@"t",@"h",@"i",@"n",@"k",@"i",@"n",@"g"];
    theLetters = @[@"t",@"h",@"e"];
    baselineLetters = @[@"b",@"a",@"s",@"e",@"l",@"i",@"n",@"e"];
    
    for(int i = 0; i < rethinkingLetters.count; i++) {
        
    }
}

@end
