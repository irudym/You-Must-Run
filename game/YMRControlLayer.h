//
//  YMRControlLayer.h
//  You Must Run
//
//  Created by Igor on 14/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "YMRRunner.h"
#import "YMRTileMap.h"
#import "YMRControlButton.h"
#import "YMRAction.h"

@interface YMRControlLayer : SKNode

-(id) initWithRunner: (YMRRunner*) runner andMap: (YMRTileMap*) map;

-(void) rightButtonDown;
-(void) buttonUp;
-(void) leftButtonDown;
-(void) upButtonDown;
-(void) downButtonDown;
-(void) actionButtonDown;
-(void) actionButtonUp;

@property YMRRunner* mainRunner;
@property YMRTileMap* mainMap;

@end
