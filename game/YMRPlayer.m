//
//  YMRPlayer.m
//  You Must Run
//
//  Created by Igor on 08/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import "YMRPlayer.h"

@implementation YMRPlayer

-(id) init {
    self = [super initWithName:@"player" AndPosition:CGPointMake(0,0)];
    if(!self) return nil;
    
    [self setZPosition:1000];
    
    return self;
}



-(void) run:(CGVector)direct {
    [self logFunction:@"YMRPlayer::run"];
    
    if(![YMRRunner compareVector:direct with:[self currentDirection]]) {
        //need to turn the runner to look to the right side
        [self turn: direct];
    }
    
    if([YMRRunner isDirectionRight:direct])
        [self runByX:1000];
    else [self runByX:-1000];
}

@end
