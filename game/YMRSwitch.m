//
//  YMRSwitch.m
//  You Must Run
//
//  Created by Igor on 08/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import "YMRSwitch.h"

@implementation YMRSwitch
{
    SKTextureAtlas* atlas;
    NSArray *switchFrames;
    NSArray *switchOnFrames;
}


-(id) initWithName: (NSString*)name andPosition: (CGPoint) position {
    atlas = [YMRSharedTextureAtlas getAtlasByName:@"Objects"];
    if(!atlas) {
        NSLog(@"Error getting atlas named: Objects");
        return nil;
    }
    self = [super initWithTexture:[atlas textureNamed:@"switch1.png"]];
    if(!self) return nil;
    
    [self setName:name];
    [self setPosition:position];
    
    [self load];
    [self animate];
    
    return self;
}


-(void) load {
    NSMutableArray* frames = [NSMutableArray array];
    
    for(int i=1;i<5;i++) {
        NSString *textureName = [NSString stringWithFormat:@"switch%d.png", i];
        SKTexture *temp = [atlas textureNamed:textureName];
        temp.filteringMode = SKTextureFilteringNearest;
        [frames addObject:temp];
    }
    
    switchFrames = frames;
}

-(void) animate {
    [self runAction:[SKAction repeatActionForever:
                     [SKAction animateWithTextures: switchFrames
                                      timePerFrame: 0.1f
                                            resize: NO
                                           restore: YES]] withKey:@"switchAnimation"];

}

-(SKNode*) getLightMap {
    return nil;
}


@end
