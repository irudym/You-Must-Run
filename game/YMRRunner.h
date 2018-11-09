//
//  YMRRunner.h
//  You Must Run
//
//  Created by Igor on 08/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "YMRSharedTextureAtlas.h"
#import "PhysicsObject.h"

#import "NSMutableArray (QueueAdditions).h"

#import "FSMStackMachine.h"
#import "YMRStopState.h"

typedef enum {
    NONE, IDLE,  RUN_ACTION = 100, TURN_ACTION, STEP_ACTION, STOP_ACTION, MOVE_ACTION, JUMP_ACTION, FALL_ACTION, CLIMB_ACTION, LANDING_ACTION, STEPTO_ACTION, DUCK_ACTION, LOCKED_ACTION
} ActionTags;

@interface YMRRunner : SKSpriteNode <YMRPhysicsObject, StateObject>


-(id) initWithName: (NSString*) name AndPosition: (CGPoint) position;
-(void) load;

//Implemet StateObject methods
-(void)stop;
-(void)fall;
-(void)land;
-(void)run;
-(void)stopping;
-(void)turn;
-(void)turnUp;
-(void)climb;

-(void)stepTo: (CGPoint)point;
-(void)turnTo:(CGVector)direction;

//process events
-(void) handleEvent: (YMREvent*) event;

//utility functions
-(void) logFunction:(NSString*) name;
+(BOOL) compareVector: (CGVector) v1 with:(CGVector) v2;
+(BOOL) isDirectionLeft: (CGVector) direction;
+(BOOL) isDirectionRight: (CGVector) direction;
+(BOOL) isDirectionUp: (CGVector) direction;
+(BOOL) isDirectionDown: (CGVector) direction;

-(void) setFrame: (SKTexture*) frame;



//frames
@property NSMutableArray* runFrames;
@property NSMutableArray* stopFrames;
@property NSMutableArray* stopLeftFrames;
@property NSMutableArray* standFrames;
@property NSMutableArray* rotateFrames;
@property NSMutableArray* shortJumpRightFrames;
@property NSMutableArray* shortJumpLeftFrames;
@property NSMutableArray* landingFrames;
@property NSMutableArray* landingLeftFrames;
@property NSMutableArray* climbFrames;
@property NSMutableArray* jumpFrames;

//direction
@property CGVector currentDirection;

//OVERRIDE
-(void) update: (CFTimeInterval)currentTime;

//animations
@property SKAction *runAction;
@property SKAction *stopAction;
@property SKAction *rotateAction;
@property SKAction *rotateUpAction;
@property SKAction *landAction;
@property SKAction *landActionUp; //for reaching end of a ladder
@property SKAction *jumpAction;
@property SKAction *climbAction;

//physics characteristic
@property float moveSpeed;


@property FSMStackMachine* stateMachine;

@end
