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
    NSMutableArray* teleportLightFrames;
    SKTextureAtlas* atlas;
    SKTexture *activeFrame;
    SKAction* teleportationAction;
    BOOL activated;
    BOOL highlighted;
    SKSpriteNode* textureLayer;
}

@synthesize linkedTeleport;
@synthesize currentRunner;

-(id) initWithName:(NSString *)name andPosition:(CGPoint)position {
    atlas = [YMRSharedTextureAtlas getAtlasByName:@"Objects"];
    //self = [super initWithTexture:[atlas textureNamed:@"teleport_light2.png"]];
    self = [super init];
    if(!self) return nil;
    
    [self setAnchorPoint:CGPointMake(0, 0)];
    
    [self setSize:CGSizeMake(32, 64)];
    
    self.linkedTeleport = nil;
    
    [self setName:name];
    [self setPosition:position];
    
    [self load];
    
    activated = NO;
    highlighted = NO;
    
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
    for(int i=0; i<7; i++) {
        frame = [atlas textureNamed: [NSString stringWithFormat:@"teleport_light%d.png", i]];
        [teleportLightFrames addObject: frame];
    }
    
    teleportationAction = [SKAction animateWithTextures: teleportLightFrames
                                           timePerFrame:0.05f
                                                 resize: NO
                                                restore: YES];
    
    
    //DEBUG: set visible object area
    SKShapeNode* point = [SKShapeNode shapeNodeWithRect:CGRectMake(0, 0, [self size].width, [self size].height)];
    point.fillColor = [SKColor colorWithRed:0.2 green:0.3 blue:1 alpha:0.5];
    point.strokeColor = [SKColor colorWithRed:0.2 green:0.3 blue:1 alpha:0.5];
    point.position  = CGPointMake(0, 0);
    point.zPosition = self.zPosition - 2;  //debug level
    //[self addChild:point];
    
    self.zPosition = 3000;
}

-(void) animate {
    
}

-(void) connectTeleport:(YMRTeleport *)teleport {
    self.linkedTeleport = teleport;
}

-(void) activate {
    [currentRunner setPosition: CGPointMake([self position].x + 16, [self position].y + 32)];
     SKAction* sequence = [SKAction sequence:@[teleportationAction, [SKAction performSelector:@selector(afterTeleporation) onTarget:self]]];
    [self runAction:sequence];
}

-(void) deactivate {
}

-(void) setHighlight:(BOOL)status {
    if(![textureLayer isHidden] == status) return;
    [textureLayer setHidden:!status];
    
}

-(void) activateWithObject:(SKNode *)object {
    //lock runner
    YMRRunner* runner = (YMRRunner*)object;
    
    [runner lock];
    [runner setHidden:YES];
    currentRunner = runner;
    [linkedTeleport setCurrentRunner:runner];

    
    SKAction* sequence = [SKAction sequence:@[teleportationAction, [SKAction performSelector:@selector(activate) onTarget:linkedTeleport]]];
    
    [self runAction:sequence];
    
}

-(void) afterTeleporation {
    //unlock the runner
    [currentRunner unlock];
    [currentRunner setHidden:NO];
    
}

#pragma mark LightSource delegate functions

-(SKNode*) getLightMap {
    return nil;
}


@end
