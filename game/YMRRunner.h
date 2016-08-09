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

#import "YMRAction.h"


//typedef enum {
//    RIGHT = 1, LEFT = -1, UP = 2, DOWN = -2
//} Direction;





@interface YMRRunner : SKSpriteNode <YMRPhysicsObject>


-(id) initWithName: (NSString*) name AndPosition: (CGPoint) position;
-(void) load;

-(void) runX: (float)x;
-(void) turn: (CGVector)direction;
//-(void) turn;
-(void) fallY: (float)y;
-(void) fall;
-(void) land;
-(void) climbY: (float)y;
-(void) jumpX: (float)x;
-(void) stepToX: (float)x; //small steps to get to exact point in the map


//key press events

-(void) stop;
-(void) jump;
-(void) run: (CGVector) direction;


/**
 @funtion climb - go up or down on the letter, use runX to adjust the player at the ledder
**/
-(void) climb: (CGVector) direction withX: (float)x;


-(BOOL) isFalling;

-(void) animate;

-(void) setFrame: (SKTexture*) frame;

-(void) runNextTask;

-(void) setStand;

+ (SKAction *)jumpWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint height:(CGFloat)height;


@property ActionTags nextAction;
@property CGPoint nextPosition;
//@property Direction nextDirection;
@property ActionTags currentAction;

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
//@property Direction currentDirection;
@property CGVector currentDirection;

//translate direction from legacy enum to vector
//TODO: Have to get rid of the legacy enum at all!
//+(CGVector) getDirection: (Direction) direct;

/**
 * Helper functions
 *
 * beforeAction - the first method in queue, performs some initial actions
 * action - usually amination action (the second element in the taskQueue
 * afterAction - the last method which finalize all actions
 *
 * example: beforeTurnLeft
            turnLeft
            afterTurnLeft
 
 * all these function can be overrided by child classes
 **/

-(void) beforeTurnLeft;
-(void) beforeTurnRight;
-(void) beforeTurnUpDown;
-(void) afterTurnLeft;
-(void) afterTurnRight;
-(void) afterTurnUpDown;

-(void) beforeActionRun;

//STOP actions
-(void) beforeActionStop;
-(void) afterActionStop;

//LANDIN actions functions
-(void) beforeActionLanding;
-(void) afterActionLanding;

-(void) beforeActionClimb;
-(void) actionClimb;
-(void) afterActionClimb;

-(void) beforeActionStep;
-(void) afterActionStep;


//animations
@property YMRAction *runAction;
@property YMRAction *stopAction;
@property YMRAction *rotateAction;
@property YMRAction *rotateUpAction;
@property YMRAction *landAction;
@property YMRAction *landActionUp; //for reaching end of a ladder
@property YMRAction *jumpAction;
@property YMRAction *climbAction;

//physics characteristic
@property float moveSpeed;

//task queue
@property NSMutableArray* taskQueue;

//@property CGPoint direction;
//@property Direction buttonPressed;

@end
