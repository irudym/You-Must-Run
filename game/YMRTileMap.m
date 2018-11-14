//
//  YMRTileMap.m
//  You Must Run
//
//  Created by Igor on 07/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import "YMRTileMap.h"

#define MAP_OFFSET 0  // TODO: should be taken into consideration when return tile coords!

@implementation YMRTileMap
{
    SKNode *objectLayer;
}

-(id) initWithFile: (NSString*) filename {
    self = [super init];
    if(!self) return nil;
    
    self.levelMap = [JSTileMap mapNamed: filename];
    self.levelMap.position = CGPointMake(0, MAP_OFFSET); //fix map position on the screen
    
    //get background
    //[self.levelMap.properties enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
    //    NSLog(@"Key: %@ => %@",key, obj);
    //}];
    
    
    NSString* background = [self.levelMap.properties objectForKeyedSubscript:@"background"];
    if(background) {
        NSLog(@"Load background: %@", background);
        SKSpriteNode *bkSprite = [SKSpriteNode spriteNodeWithImageNamed:background];
        bkSprite.zPosition = -100.0f;
        NSLog(@"Set bk size: %f, %f", self.levelMap.mapSize.width * self.levelMap.tileSize.width, self.levelMap.mapSize.height * self.levelMap.tileSize.height);
        bkSprite.size = CGSizeMake(self.levelMap.mapSize.width * self.levelMap.tileSize.width, self.levelMap.mapSize.height * self.levelMap.tileSize.height);
        [bkSprite setScale:2.3];
        [self addChild:bkSprite];
    }
    
    [self addChild: self.levelMap];
    
    objectLayer = [[SKNode alloc] init];
    objectLayer.name = @"object_layer";
    [objectLayer setPosition:CGPointMake(0, 0)];
    objectLayer.zPosition = -20;
    
    [self addChild:objectLayer];
    
    //Add objects to the map
    NSMutableArray *teleports = [NSMutableArray array];
    
    NSArray* objects = [[self.levelMap objectGroups][0] objects];
    for (NSDictionary * object in objects) {
        //NSLog(@"Layer name: %@", object[@"type"]);
        if([object[@"type"] isEqualToString:@"torch"]) {
            //add torch to the map
            NSLog(@"Add torch: %@ with position [%@,%@]", object[@"name"], object[@"x"], object[@"y"]);
            YMRTorch* torch = [[YMRTorch alloc] initWithName: object[@"name"] andPosition: CGPointMake([object[@"x"] floatValue], [object[@"y"] floatValue] + MAP_OFFSET)];
            torch.zPosition = -20;
            [objectLayer addChild:torch];
            
        } else
        if([object[@"type"] isEqualToString: @"switch"]) {
            NSLog(@"Add switch %@", object[@"name"]);
            YMRSwitch* switchPanel = [[YMRSwitch alloc] initWithName: object[@"name"] andPosition: CGPointMake([object[@"x"] floatValue], [object[@"y"] floatValue] + MAP_OFFSET)];
            [objectLayer addChild:switchPanel];
        } else
        if([object[@"type"] isEqualToString:@"teleport"]) {
            NSLog(@"Add teleport %@ with connection to %@", object[@"name"], object[@"linkTo"]);
            
            CGPoint tposition = CGPointMake([object[@"x"] floatValue], [object[@"y"] floatValue]);
            
            //get tile position to align the teleport on the map
            CGPoint sposition = [self getTileScreenPositionAtPoint:tposition];
            //fix teleport position
            sposition.y += 1.5* [self getTileHeightAtPoint:tposition];
            
            YMRTeleport* teleport = [[YMRTeleport alloc] initWithName:object[@"name"] andPosition: sposition];
            
            [teleport setLinkedTeleportName:object[@"linkTo"]];
            [teleports addObject:teleport];
            [objectLayer addChild:teleport];
        }
    }
    
    //update teleport connections
    for(int i=0;i<[teleports count]; i++) {
        if([teleports[i] linkedTeleport] == nil) {
            YMRTeleport* tel = [YMRTileMap findTeleportByName:[teleports[i] linkedTeleportName] inArray:teleports];
            if(tel!=nil) {
                [teleports[i] setLinkedTeleport:tel];
            } else {
                NSLog(@"Error to find teleport with name: %@", [teleports[i] linkedTeleportName]);
                [teleports[i] setLinkedTeleport:teleports[i]];
            }
        }
    }
    
    return self;
}


+(YMRTeleport*) findTeleportByName: (NSString*)name inArray: (NSMutableArray*)teleports {
    for(int i = 0;i<[teleports count];i++) {
        if([[teleports[i] name] isEqualToString:name]) return teleports[i];
    }
    return nil;
}

+(id) mapWithFile: (NSString*) filename {
    return [[YMRTileMap alloc] initWithFile:filename];
}

-(CGPoint) getTileScreenPositionAtPoint: (CGPoint) point {
    CGPoint coord = [[[self.levelMap layerNamed:@"map"] tileAt:point] position];
    //use tile map coords and multiplay them to tile size
    
    CGPoint p = [[self.levelMap layerNamed:@"map"] coordForPoint: point];
    p.y = [self.levelMap mapSize].height - p.y - 1; // to start from 0
    
    //adjust the position as the sprite has the anchor point in the middle
    coord.y = p.y * [[[self.levelMap layerNamed:@"map"] tileAt:point] frame].size.height; //-= [[[self.levelMap layerNamed:@"map"] tileAt:point] frame].size.height/2; //size of the tile
    coord.x = p.x * [[[self.levelMap layerNamed:@"map"] tileAt:point] frame].size.width;// [[[self.levelMap layerNamed:@"map"] tileAt:point] frame].size.width/2;
    return coord;
}

-(float) getTileHeightAtPoint:(CGPoint)point {
    return [[[self.levelMap layerNamed:@"map"] tileAt:point] frame].size.height;
}

-(float) getTileWidthAtPoint:(CGPoint)point {
    return [[[self.levelMap layerNamed:@"map"] tileAt:point] frame].size.width;
}

-(CGSize) size {
    return CGSizeMake([_levelMap mapSize].width * [_levelMap tileSize].width, [_levelMap mapSize].height * [_levelMap tileSize].height);
}

#pragma mark Check functions

/**
 *@function isLadderAt - check if there is a ladder tile at provided position
 *@params position - position to check
 *@return - ladder tile gid or -1 in case there is no ladder tile
 **/
-(int) isLadderAt:(CGPoint)position {
    //TODO: load that data from map file [ladder]
    int tile_gid = [[_levelMap layerNamed:@"map"] tileGidAt:position];
    // NSLog(@"==>isLadderAt: %d", tile_gid);
    if(tile_gid >= 10 && tile_gid < 14) return tile_gid;
    return -1;
}

-(BOOL) isLadderBase: (int)gid {
    // TODO: load the data from map file [ladder_bottom]
    if(gid == 10 || gid == 13) return YES;
    return NO;
}

-(BOOL) isLadderTop: (int) gid {
    // TODO: load that data from map file [ladder_top]
    if(gid == 12) return YES;
    return NO;
}

-(int) isLadderBaseAt:(CGPoint)position {
    int tile_gid = [[_levelMap layerNamed:@"map"] tileGidAt:position];
    if([self isLadderBase: tile_gid]) return tile_gid;
    return -1;
}


-(SKNode<YMRMapObject>*) getObjectAtPosition: (CGPoint)position {
    
    SKNode<YMRMapObject>* obj = nil;
    
    NSArray <SKSpriteNode*> *objects = [self getObjects];
    for(int i=0;i<[objects count]; i++) {
        if(position.x >= [objects[i] position].x && position.y >= [objects[i] position].y && position.x <= ([objects[i] position].x + [objects[i] size].width) && position.y <= ([objects[i] position].y + [objects[i] size].height)) {
            return objects[i];
        }
    }
    return obj;
}

-(NSArray <SKNode *>*) getObjects {
    return [objectLayer children];
}

-(BOOL) isEmptyTileAtPosition: (CGPoint) position {
    int tile_gid = [[_levelMap layerNamed:@"map"] tileGidAt:position];
    if(tile_gid == 0) return YES;
    
    if([self isLadderAt:position]!=-1 && (![self isLadderBase:tile_gid] && ![self isLadderTop:tile_gid])) {
        CGPoint tile_position = [self getTileScreenPositionAtPoint:position];
        if(position.x < tile_position.x+8 || position.x > tile_position.x + 16) return YES;
    }

    return NO;
}

-(CGFloat) getTileLandHeight: (int)gid withPosition: (CGPoint)position {
    //TODO: need to get data from map file
    if(gid == 11 ) return 32;
    if(gid >= 10 && gid <= 13) return 7;
    
    //it also helps to implement diagonal floors
    return 7;
}

-(CGFloat) getTileLandHeightAtPosition: (CGPoint)position {
    return [self getTileLandHeight:[[_levelMap layerNamed:@"map"] tileGidAt:position] withPosition:position];
}


@end
