//
//  YMRTileMap.h
//  You Must Run
//
//  Created by Igor on 07/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "JSTileMap.h"

#import "YMRTorch.h"
#import "YMRSwitch.h"
#import "YMRTeleport.h"

@interface YMRTileMap : SKNode

-(id) initWithFile: (NSString*) filename;
+(id) mapWithFile: (NSString*) filename;

-(CGPoint) getTileScreenPositionAtPoint: (CGPoint) point;
-(float) getTileHeightAtPoint: (CGPoint) point;
-(float) getTileWidthAtPoint: (CGPoint) point;

-(CGSize) size;

-(SKNode<YMRMapObject>*) getObjectAtPosition: (CGPoint)position;
-(NSArray <SKNode *>*) getObjects;


//Return YES if tile is ladder base
-(BOOL) isLadderBase: (int) gid;


/**
 * check if there is a ladder at the position
 * @return: 
 *  if tile a ladder: tile id
 *  otherwise: -1
 **/
-(int) isLadderAt: (CGPoint) position;


/**
 * check if there is a ladder base at provided position
 * @return:
 *  if tile a ladder base: tile id
 *  otherwise: -1
 **/
-(int) isLadderBaseAt: (CGPoint) position;

-(BOOL) isEmptyTileAtPosition: (CGPoint) position;


@property JSTileMap* levelMap;

@end
