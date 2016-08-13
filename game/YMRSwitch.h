//
//  YMRSwitch.h
//  You Must Run
//
//  Created by Igor on 08/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LightSource.h"
#import "MapObject.h"
#import "YMRSharedTextureAtlas.h"

@interface YMRSwitch : SKSpriteNode <YMRLightSource, YMRMapObject>

-(id) initWithName: (NSString*)name andPosition: (CGPoint) position;
-(void) load;
-(void) animate;

-(SKNode*) getLightMap;

-(void) activate;
-(void) deactivate;

@end
