//
//  GameScene.m
//  You Must Run
//
//  Created by Igor on 06/11/15.
//  Copyright (c) 2015 Igor Rudym. All rights reserved.
//

#import "GameScene.h"

#define SCROLL_BORDER_X 100
#define SCROLL_BORDER_Y 100

@implementation GameScene
{
    SKTextureAtlas *objectsAtlas;
    YMRPhysicsWorld *physics;
    
    YMRPlayer* mainPlayer;
    YMRTileMap* levelMap;
    CGRect scrollingBorders;
    YMRControlLayer *controlLayer;
}

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    //SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    //myLabel.text = @"Hello, World!";
    //myLabel.fontSize = 45;
    //myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
    //                               CGRectGetMidY(self.frame));
    //[self addChild:myLabel];
    
    //Load images
    [YMRSharedTextureAtlas loadAtlas:@"Objects"];
    [YMRSharedTextureAtlas loadAtlas:@"Runners"];
    
    
    levelMap = [YMRTileMap mapWithFile: @"level1.tmx"];

    if(!levelMap) {
        //[self addChild:map];
    }
    
    physics = [[YMRPhysicsWorld alloc] initWithMap:levelMap];
    //TODO: have to discover why there is a shift on 50 pixel on Y?
    [physics setAdjustmentY:50];
    
    mainPlayer = [[YMRPlayer alloc] init];
    [mainPlayer setPosition:CGPointMake(80,280)];
    
    [physics addChild: levelMap];
    [physics addObject:mainPlayer];
    
    [self addChild:physics];
    
    controlLayer = [[YMRControlLayer alloc] initWithRunner:mainPlayer andMap:levelMap];
    [self addChild:controlLayer];
    
    // Add some gravity
    self.physicsWorld.gravity = CGVectorMake(0.0f, -2.0f);
    
    //set scrolling region
    scrollingBorders = CGRectMake(SCROLL_BORDER_X, SCROLL_BORDER_Y, [self size].width - SCROLL_BORDER_Y, [self size].height - SCROLL_BORDER_Y);
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
    }
}

//get scene coordinates of objects which belong to Physics layer
-(CGPoint) getScenePositionOfObject: (SKNode*) object {
    return CGPointMake([object position].x + [physics position].x, [object position].x + [physics position].x);
}

-(void)update:(CFTimeInterval)currentTime {
    // Update control layer
    [controlLayer update: currentTime];
    
    /* Called before each frame is rendered */
    [physics update: currentTime];
    
    //get player's coordinates related to the screen (Scene)
    CGPoint player_pos = [self getScenePositionOfObject:mainPlayer];
    
    //NSLog(@"Player position: [%f,%f]", player_pos.x, player_pos.y);
    
    //scroll the map from  right to left
    if(player_pos.x > scrollingBorders.size.width && ![physics hasActions] && [physics position].x > -([levelMap size].width - [self size].width/*not end of the map*/)) {
        NSLog(@"Scroll the map");
        NSLog(@"Map width: %f",[levelMap size].width);
        [physics runAction:[SKAction moveBy:CGVectorMake(-500, 0) duration: 3.0f]];
    }
    
    //scroll the map from left to right
    if(player_pos.x < scrollingBorders.origin.x && [physics position].x < 0) {
        [physics runAction:[SKAction moveBy:CGVectorMake(500, 0) duration: 3.0f]];
    }
    
    //check scrolling limits
    if([physics hasActions]) {
        if([physics position].x < -([levelMap size].width - [self size].width)) {
            [physics removeAllActions];
            [physics setPosition:CGPointMake(-([levelMap size].width - [self size].width), [physics position].y)];
        } else
            if([physics position].x > 0) {
                [physics removeAllActions];
                [physics setPosition:CGPointMake(0,[physics position].y)];
            }
    }
}

@end
