//
//  YMRTeleport.m
//  You Must Run
//
//  Created by Igor on 12/08/16.
//  Copyright © 2016 Igor Rudym. All rights reserved.
//

#import "YMRTeleport.h"

@implementation YMRTeleport
{
    NSArray* teleportLightFrames;
    SKTextureAtlas* atlas;
    SKTexture *activeFrame;
    SKAction* teleportationAction;
    BOOL activated;
    SKSpriteNode* textureLayer;
}

@synthesize linkedTeleport;

-(id) initWithName:(NSString *)name andPosition:(CGPoint)position {
    atlas = [YMRSharedTextureAtlas getAtlasByName:@"Objects"];
    self = [super init];
    if(!self) return nil;
    
    [self setSize:CGSizeMake(32, 64)];
    
    
    self.linkedTeleport = nil;
    
    [self setName:name];
    [self setPosition:position];
    
    [self load];
    
    activated = NO;
    
    return self;
}

-(void) load {
    activeFrame = [atlas textureNamed:@"teleport0.png"];
    SKTexture* frame;
    
    
    //create texture layer to show images of the object
    textureLayer = [SKSpriteNode spriteNodeWithTexture:activeFrame];
    textureLayer.zPosition = self.zPosition - 1;
    [self addChild: textureLayer];
    [textureLayer setHidden:YES];
    
    [textureLayer setPosition:CGPointMake(17, 34)];
    
    teleportLightFrames = [NSMutableArray array];
    for(int i=0; i<6; i++) {
        frame = [atlas textureNamed: [NSString stringWithFormat:@"teleport_light%d.png", i]];
    }
    
    teleportationAction = [SKAction animateWithTextures: teleportLightFrames
                                           timePerFrame:0.1f
                                                 resize: NO
                                                restore: YES];
    
    
    //DEBUG: set visible object area
    SKShapeNode* point = [SKShapeNode shapeNodeWithRect:CGRectMake(0, 0, [self size].width, [self size].height)];
    point.fillColor = [SKColor colorWithRed:0.2 green:0.3 blue:1 alpha:0.5];
    point.strokeColor = [SKColor colorWithRed:0.2 green:0.3 blue:1 alpha:0.5];
    point.position  = CGPointMake(0, 0);
    point.zPosition = self.zPosition - 2;  //debug level
    //[self addChild:point];

}

-(void) animate {
    
}

-(void) connectTeleport:(YMRTeleport *)teleport {
    self.linkedTeleport = teleport;
}

-(void) activate {
    if(activated) return;
    activated = YES;
    [textureLayer setHidden: NO];
}

-(void) deactivate {
    if(!activated) return;
    activated = NO;
    [textureLayer setHidden: YES];
    
}

-(void) teleportRunner: (YMRRunner*) runner {
    //lock runner
    
}

-(void) afterTeleporation {
    //unlock the runner
}

#pragma mark LightSource delegate functions

-(SKNode*) getLightMap {
    return nil;
}


@end
