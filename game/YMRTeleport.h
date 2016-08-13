//
//  YMRTeleport.h
//  You Must Run
//
//  Created by Igor on 12/08/16.
//  Copyright © 2016 Igor Rudym. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LightSource.h"
#import "MapObject.h"
#import "YMRSharedTextureAtlas.h"
#import "YMRRunner.h"

@interface YMRTeleport : SKSpriteNode <YMRLightSource, YMRMapObject>

-(id) initWithName: (NSString*)name andPosition: (CGPoint) position;
-(void) load;
-(void) animate;

-(void) connectTeleport: (YMRTeleport*) teleport;

-(void) activate;
-(void) deactivate;

-(void) teleportRunner: (YMRRunner*) runner;

-(SKNode*) getLightMap;

@property YMRTeleport* linkedTeleport;
@property NSString* linkedTeleportName;

@end
