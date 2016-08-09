//
//  YMRTileMap.m
//  You Must Run
//
//  Created by Igor on 07/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import "YMRTileMap.h"

#define MAP_OFFSET 50

@implementation YMRTileMap

-(id) initWithFile: (NSString*) filename {
    self = [super init];
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
    
    //Add objects to the map
    
    NSArray* objects = [[self.levelMap objectGroups][0] objects];
    for (NSDictionary * object in objects) {
        //NSLog(@"Layer name: %@", object[@"type"]);
        if([object[@"type"] isEqualToString:@"torch"]) {
            //add torch to the map
            NSLog(@"Add torch: %@ with position [%@,%@]", object[@"name"], object[@"x"], object[@"y"]);
            YMRTorch* torch = [[YMRTorch alloc] initWithName: object[@"name"] andPosition: CGPointMake([object[@"x"] floatValue], [object[@"y"] floatValue] + MAP_OFFSET)];
            [self addChild:torch];
        } else
        if([object[@"type"] isEqualToString: @"switch"]) {
            NSLog(@"Add switch %@", object[@"name"]);
            YMRSwitch* switchPanel = [[YMRSwitch alloc] initWithName: object[@"name"] andPosition: CGPointMake([object[@"x"] floatValue], [object[@"y"] floatValue] + MAP_OFFSET)];
            [self addChild:switchPanel];
        }
    }
    
    
    return self;
}

+(id) mapWithFile: (NSString*) filename {
    return [[YMRTileMap alloc] initWithFile:filename];
}

-(CGPoint) getTileScreenPositionAtPoint: (CGPoint) point {
    CGPoint coord = [[[self.levelMap layerNamed:@"map"] tileAt:point] position];
    //adjust the position as the sprite has the anchor point in the middle
    coord.y -= [[[self.levelMap layerNamed:@"map"] tileAt:point] frame].size.height/2; //size of the tile
    coord.x -= [[[self.levelMap layerNamed:@"map"] tileAt:point] frame].size.width/2;
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
    int tile_gid = [[_levelMap layerNamed:@"map"] tileGidAt:position];
    NSLog(@"==>isLadderAt: %d", tile_gid);
    if(tile_gid >= 10 && tile_gid < 14) return tile_gid;
    return -1;
}

-(BOOL) isLadderBase: (int)gid {
    if(gid == 10 || gid == 13) return TRUE;
    return FALSE;
}

-(int) isLadderBaseAt:(CGPoint)position {
    int tile_gid = [[_levelMap layerNamed:@"map"] tileGidAt:position];
    if([self isLadderBase: tile_gid]) return tile_gid;
    return -1;
}


@end
