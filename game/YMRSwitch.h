//
//  YMRSwitch.h
//  You Must Run
//
//  Created by Igor on 08/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "LightSource.h"
#import "YMRSharedTextureAtlas.h"

@interface YMRSwitch : SKSpriteNode <YMRLightSource>

-(id) initWithName: (NSString*)name andPosition: (CGPoint) position;
-(void) load;
-(void) animate;

-(SKNode*) getLightMap;

@end
