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
    CGPoint topCoord; // point of top sprite point
    CGPoint midCoord; // point in the middle of an object's sprite
    CGPoint tile_coord;
    int tile_gid;
    id<YMRMapObject> mapObject;
    for(int i=0;i<[objects count];i++) {
        //fix object position according to tile height, exept ladders
        //object_postion_y += tile_land_heigh
        
        
        coord = CGPointMake([objects[i] position].x, (int)[objects[i] position].y);
        //coord = [objects[i] position];
        topCoord = CGPointMake(coord.x, coord.y + [objects[i] getHeight]);
        midCoord = CGPointMake(coord.x, coord.y + [objects[i] getHeight]/2);
        
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
        
        //check if the object should fall
        //check at feet level
        //adjust position
        // coord.y -= adjustmentY;
        [point setPosition:coord];
        
        tile_gid = [[[levelMap levelMap] layerNamed: @"map"] tileGidAt: coord];
        tile_coord = [levelMap getTileScreenPositionAtPoint:[objects[i] position]];
        
        if(![levelMap isEmptyTileAtPosition:coord]) {
            //NSLog(@"Tile at position (%f, %f): %d", [objects[i] position].x, [objects[i] position].y, tile_gid);
            //[rect setPosition:tile_coord];
            //NSLog(@"====> Tile position: %f, %f", tile_coord.x, tile_coord.y);
        }
        [rect setPosition:tile_coord];
        
        
        // check if object reached upper end of ladders during climbin => need to stop it to avoid falling
        if([levelMap isLadderTop: tile_gid] && [YMRRunner isDirectionUp:[objects[i] currentDirection]]) {
            CGFloat coord_y = [levelMap getTileScreenPositionAtPoint:coord].y + [levelMap getTileHeightAtPoint:coord] - 1;// - adjustmentY;
            if([objects[i] position].y > coord_y) {
                NSLog(@"STOOOOP the runner at %f,%f | coord", [objects[i] position].x, [objects[i] position].y);
                [objects[i] handleEvent:[YMREvent createEventByType:EVENT_STOP]];
                [objects[i] setPosition:CGPointMake([objects[i] position].x, coord_y + 1)];
                [objects[i] update: currentTime];
                return;
            }
        }
        
        //Falling
        if([levelMap isEmptyTileAtPosition:coord] || ((![levelMap isEmptyTileAtPosition:coord] && [levelMap isLadderBaseAt:coord] == -1) && coord.y > [levelMap getTileLandHeightAtPosition: coord] + [levelMap getTileScreenPositionAtPoint:coord].y)) {
            //if(tile_gid == 0) {
            NSLog(@"Start falling at position: %f, %f", coord.x, coord.y);
            [objects[i] handleEvent:[YMREvent createEventByType:EVENT_FALL]];
        }
        
        //Check landing
        if (![levelMap isEmptyTileAtPosition:midCoord]) {
            //NSLog(@"Middle of the object is at no empty tile! POS: %f,%f", coord.x, coord.y);
            if(coord.y <= [levelMap getTileScreenPositionAtPoint:midCoord].y + [levelMap getTileLandHeightAtPosition: midCoord])
            {
                //fix the falling object position
                coord.y = [levelMap getTileScreenPositionAtPoint:midCoord].y + [levelMap getTileLandHeightAtPosition: midCoord];
                [objects[i] handleEvent:[YMREvent createEventWithType:EVENT_LAND andPoint:coord]];
            }
        }
        
        //check if object reached end of ladder during climbing=> need to stop it
        
        if([levelMap isLadderBaseAt: coord] > -1 && [YMRRunner isDirectionDown:[objects[i] currentDirection]]) {
            CGFloat coord_y = [levelMap getTileScreenPositionAtPoint:coord].y + [levelMap getTileLandHeightAtPosition: coord];
            if(coord.y <= coord_y) {
                [objects[i] handleEvent:[YMREvent createEventByType:EVENT_STOP]];
                
                //fix object position
                coord.y = coord_y;
                [objects[i] setPosition: coord];
            }
        }
        
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
