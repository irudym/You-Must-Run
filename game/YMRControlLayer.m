//
//  YMRControlLayer.m
//  You Must Run
//
//  Created by Igor on 14/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import "YMRControlLayer.h"

#include <math.h>


@implementation YMRControlLayer

@synthesize mainRunner;

-(id) initWithRunner: (YMRRunner*) runner andMap: (YMRTileMap*) map {
    self = [super init];
    if(!self) return nil;
    
    mainRunner = runner;
    _mainMap = map;
    
    //enable touch handling
    self.userInteractionEnabled = TRUE;
    
    YMRControlButton *rightButton = [YMRControlButton controlButtonWithImage:@"arrow-retina@2x.png"];
    [rightButton setPosition:CGPointMake(520,90)];
    [rightButton setButtonDownTarget:@selector(rightButtonDown) fromObject:self];
    [rightButton setButtonUpTarget:@selector(buttonUp) fromObject:self];
    [self addChild: rightButton];
    
    YMRControlButton *leftButton = [YMRControlButton controlButtonWithImage:@"arrow-retina@2x.png"];
    leftButton.xScale = -1;
    [leftButton setPosition:CGPointMake(430,90)];
    [leftButton setButtonDownTarget:@selector(leftButtonDown) fromObject:self];
    [leftButton setButtonUpTarget:@selector(buttonUp) fromObject:self];
    [self addChild:leftButton];
    
    YMRControlButton* upButton = [YMRControlButton controlButtonWithImage:@"arrow-retina@2x.png"];
    [upButton setPosition:CGPointMake(475,120)];
    upButton.zRotation = M_PI/2;
    [upButton setButtonDownTarget: @selector(upButtonDown) fromObject: self];
    [upButton setButtonUpTarget:@selector(buttonUp) fromObject:self];
    [self addChild:upButton];
    
    YMRControlButton *downButton = [YMRControlButton controlButtonWithImage:@"arrow-retina@2x.png"];
    [downButton setPosition:CGPointMake(475, 75)];
    downButton.zRotation = -M_PI/2;
    [downButton setButtonDownTarget:@selector(downButtonDown) fromObject:self];
    [downButton setButtonUpTarget:@selector(buttonUp) fromObject:self];
    [self addChild:downButton];
    
    YMRControlButton *actionButton = [YMRControlButton controlButtonWithImage:@"action-retina@2x.png"];
    [actionButton setPosition:CGPointMake(25,75)];
    [actionButton setButtonDownTarget:@selector(actionButtonDown) fromObject:self];
    [actionButton setButtonUpTarget:@selector(actionButtonUp) fromObject:self];
    [self addChild:actionButton];
    
    [self setZPosition:2000];
    
    return self;
}

-(void) rightButtonDown {
    //[mainRunner setDirection:CGPointMake(1, 0)];
    //[mainRunner setButtonPressed:RIGHT];
    [mainRunner run: RIGHT];
}

-(void) buttonUp {
    //[mainRunner setButtonPressed:NONE];
    //[mainRunner setButtonPressed:UP];
    [mainRunner stop];
}

-(void) leftButtonDown {
    //[mainRunner setButtonPressed:LEFT];
    //[mainRunner setDirection:CGPointMake(-1,0)];
    [mainRunner run: LEFT];
}

-(void) upButtonDown {
    //check if ladder is near and climb up
    //TODO: Need to get rid of that adjustment!
    CGPoint check_pos = CGPointMake([mainRunner position].x, [mainRunner position].y - 50);
    int ladder_gid = [_mainMap isLadderAt:check_pos];
    NSLog(@"Check the tile_gid: %d", ladder_gid);
    //if(ladder_gid >= 0 && ladder_gid != 12)
    if(ladder_gid!=-1)
    {
        NSLog(@"Check the ladder\n\tPlayerX: %f\n\tLadderX: %f", mainRunner.position.x, [_mainMap getTileScreenPositionAtPoint:check_pos].x + [_mainMap getTileWidthAtPoint: check_pos]/2);
        [mainRunner climb:UP withX: [_mainMap getTileScreenPositionAtPoint:check_pos].x + [_mainMap getTileWidthAtPoint: check_pos]/2];
    } else
        //otherwise just jump!
        [mainRunner jump];
}

-(void) downButtonDown {
    //check if ladder is near and climb up
    //TODO: Need to get rid of that adjustment!
    CGPoint check_pos = CGPointMake([mainRunner position].x, [mainRunner position].y - 50);
    int ladder_gid = [_mainMap isLadderAt:check_pos];
    NSLog(@"Check the tile_gid: %d", ladder_gid);
    if(ladder_gid >= 0 && ladder_gid != 10) {
        [mainRunner climb:DOWN withX: [_mainMap getTileScreenPositionAtPoint:check_pos].x + [_mainMap getTileWidthAtPoint: check_pos]/2];
    } //else
        //otherwise duck!
    
}

-(void) actionButtonDown {
//    [mainRunner turn:LEFT];
    [mainRunner nextAction];
}

-(void) actionButtonUp {
    
}

@end
