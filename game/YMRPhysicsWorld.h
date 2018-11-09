//
//  YMRPhysicsWorld.h
//  You Must Run
//
//  Created by Igor on 08/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

#import "YMRTileMap.h"
#import "PhysicsObject.h"
#import "MapObject.h"
#include "YMRAction.h"


@interface YMRPhysicsWorld : SKNode

-(id) initWithMap: (YMRTileMap*) map;

-(void) addObject: (id<YMRPhysicsObject>) object;
-(void) update: (CFTimeInterval)currentTime;

@property CGFloat adjustmentY;


@end
