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

-(void) runToX: (float)x;
-(void) turn: (CGVector)direction;
-(void) fallY: (float)y;
-(void) fall;
-(void) land;
-(void) climbY: (float)y;
-(void) jumpToX: (float)x;
-(void) stepToX: (float)x; //small steps to get to exact point in the map
-(void) runByX: (float)x;


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


//@property ActionTags nextAction;
//@property CGPoint nextPosition;
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
@property CGVector currentDirection;


/**
 * Helper functions
 *
 * beforeAction - the first method in queue, performs some initial actions
 * action - usually amination action (the second element in the taskQueue
 * afterAction - the last method which finalize all actions
 *
 * example: actionTurnLeft
            afterTurnLeft
 
 * all these function can be overrided by child classes
 **/

-(void) actionTurnRight;
-(void) afterTurnRight;

-(void) actionTurnLeft;
-(void) afterTurnLeft;

-(void) actionTurnUpDown;
-(void) afterTurnUpDown;

-(void) actionFall;

-(void) actionLanding;
-(void) afterLanding;

-(void) actionStop;
-(void) afterStop;

-(void) actionRun;

-(void) actionStep;
-(void) afterStep;

-(void) actionClimb;

//Physic object functions
//lock and unlock - used to lock the runner in case of some animations, in example: teleportation

-(void) lock;
-(void) unlock;

//OVERRIDE
-(void) update: (CFTimeInterval)currentTime;

//Utiliy functions
-(void) runAction: (SKAction*) action andAfter: (SEL) func;
-(void) logFunction:(NSString*) name;
+(BOOL) compareVector: (CGVector) v1 with:(CGVector) v2;
+(BOOL) isDirectionLeft: (CGVector) direction;
+(BOOL) isDirectionRight: (CGVector) direction;



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
