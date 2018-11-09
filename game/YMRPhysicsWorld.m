//
//  YMRPhysicsWorld.m
//  You Must Run
//
//  Created by Igor on 08/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import "YMRPhysicsWorld.h"

@implementation YMRPhysicsWorld
{
    NSMutableArray* objects;
    YMRTileMap* levelMap;
    SKShapeNode* point;
    SKShapeNode* rect;
}

@synthesize adjustmentY;

-(id) initWithMap: (YMRTileMap*) map {
    self = [super init];
    if(!self) return nil;
    
    
    objects = [NSMutableArray array];
    levelMap = map;
    
    [self setAdjustmentY:0];
    
    //DEBUG: set visible anchor point
    point = [SKShapeNode shapeNodeWithCircleOfRadius:1];
    point.fillColor = [SKColor redColor];
    point.strokeColor = [SKColor redColor];
    point.position  = CGPointMake(0, 0);
    point.zPosition = 2000;
    [levelMap addChild:point];
    
    rect = [SKShapeNode shapeNodeWithRect:CGRectMake(0, 0, 32, 32)];
    rect.strokeColor = [SKColor blueColor];
    rect.position = CGPointMake(0, 0);
    rect.zPosition = 2000;
    [levelMap addChild:rect];
    
    return self;
}

-(void) addObject: (id<YMRPhysicsObject>) object {
    [objects addObject:object];
    [self addChild: object];
}


-(void) update: (CFTimeInterval)currentTime {
    CGPoint coord;
    CGPoint tile_coord;
    int tile_gid;
    id<YMRMapObject> mapObject;
    for(int i=0;i<[objects count];i++) {
        coord = [objects[i] position];
        
        //deactivate objects
        NSArray* obj = [levelMap getObjects];
        for(int i=0; i< [obj count]; i++) {
            [obj[i] setHighlight:NO];
        }
        
        //check if the object at some map objects and activate it
        mapObject = [levelMap getObjectAtPosition:coord];
        if(mapObject!=nil) {
            //NSLog(@"Physical object should activate: %@", [(SKNode*)mapObject name]);
            [mapObject setHighlight:YES];
        }
        
        //NSLog(@"Update object[%@]: %f,%f with height: %f", [objects[i] name], coord.x, coord.y, [objects[i] frame].size.height);
        
        //check if the object should fall
        //check at feet level
        //adjust position
        coord.y -= adjustmentY;
        [point setPosition:coord];
        tile_gid = [[[levelMap levelMap] layerNamed: @"map"] tileGidAt: coord];
        
        NSLog(@"Tile at coord: %d", tile_gid);
        
        tile_coord = [levelMap getTileScreenPositionAtPoint:[objects[i] position]];
        [rect setPosition:tile_coord];
        
        //Falling
        
        if([levelMap isEmptyTileAtPosition: coord]) {
            //if(tile_gid == 0) {
            [objects[i] handleEvent:[YMREvent createEventByType:EVENT_FALL]];
        } else {
            //fix the falling object position
            adjustmentY = 26; // TODO: set a table of adjustments which depends on tile type, could take the data from YMRMap class
            coord.y = [levelMap getTileScreenPositionAtPoint:coord].y + [levelMap getTileHeightAtPoint:coord] + adjustmentY;
            [objects[i] handleEvent:[YMREvent createEventWithType:EVENT_LAND andPoint:coord]];
        }
        
        //check that object reached end of ladder during climbing=> need to stop it
        //TODO: need to stop when approached from above!
        //
        //NSLog(@"tile gid: %d | currentAction: %d | curentDirection: (%f,%f)", tile_gid, [objects[i] currentAction], [objects[i] currentDirection].dx, [objects[i] currentDirection].dy);
        /*
        if([objects[i] currentAction] == CLIMB_ACTION && [levelMap isLadderBase: tile_gid] && [objects[i] currentDirection].dy == DOWN.dy) {
            [objects[i] stop];
            
            //fix object position
            coord.y = [levelMap getTileScreenPositionAtPoint:coord].y + [levelMap getTileHeightAtPoint:coord] + adjustmentY;
            [objects[i] setPosition:coord];
        }
        [objects[i] update:0];
         */
        [objects[i] update: currentTime];
    }
}

-(BOOL) isOutOfLadder: (CGPoint)position {
    int tile_gid = [levelMap isLadderAt:position];
    if(![levelMap isLadderBase:tile_gid]) {
        
    }
    return YES;
}

@end
