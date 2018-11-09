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

@end
