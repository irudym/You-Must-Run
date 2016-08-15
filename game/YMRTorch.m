//
//  YMRTorch.m
//  You Must Run
//
//  Created by Igor on 07/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import "YMRTorch.h"

@implementation YMRTorch
{
    NSArray *torchFrames;
    SKTextureAtlas* atlas;
}


-(id)initWithName:(NSString *)name andPosition:(CGPoint)position {
    atlas = [YMRSharedTextureAtlas getAtlasByName:@"Objects"];
    if(!atlas) {
        NSLog(@"Error getting atlas named: Objects");
        return nil;
    }
    
    self = [super initWithTexture:[atlas textureNamed:@"torch1.png"]];
    if(!self) return nil;
    
    
    [self setName:name];
    [self setPosition:position];
    
    [self load];
    [self animate];
    
    return self;
}


-(void) load {
    NSMutableArray* frames = [NSMutableArray array];
    if(!atlas) {
        NSLog(@"Error getting atlas named: Objects");
    }
    
    int frameCount = rand() % 9 + 1;
    for(int i=1;i<11;i++) {
        NSString *textureName = [NSString stringWithFormat:@"torch%d.png", frameCount++];
        if(frameCount>10) frameCount = 1;
        SKTexture *temp = [atlas textureNamed:textureName];
        temp.filteringMode = SKTextureFilteringNearest;
        [frames addObject:temp];
    }
    
    torchFrames = frames;
}


-(void) animate {
    [self runAction:[SKAction repeatActionForever:
                      [SKAction animateWithTextures: torchFrames
                                       timePerFrame: 0.05f
                                             resize: NO
                                            restore: YES]] withKey:@"torchAnimation"];
}

#pragma mark LightSource delegate functions

-(SKNode*) getLightMap {
    return nil;
}

-(void) activateWithObject:(SKNode *)object {}
-(void) deactivate {}
-(void) setHighlight:(BOOL)status {}

@end
