//
//  YMRRunner.m
//  You Must Run
//
//  Created by Igor on 08/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import "YMRRunner.h"

CGVector const LEFT = {-1.0f,0.0f};
CGVector const RIGHT = {1.0f, 0.0f};
CGVector const UP = {0.0f,1.0f};
CGVector const DOWN = {0.0f,-1.0f};


@implementation YMRRunner
{
    NSInteger climbStopFrame;
    NSInteger climbStopLoop;
    BOOL locked;
    SKTextureAtlas* atlas;
    
    CGSize runSpriteSize;
    
    CGVector prevDirection;
    YMRAction* currentTask; //current task which executed right now; used to get access to aditional function params in helper functions;
}

//@synthesize nextAction;
@synthesize currentAction;

@synthesize currentDirection;

@synthesize moveSpeed;

@synthesize taskQueue;
//@synthesize buttonPressed;





-(id) initWithName: (NSString*) name AndPosition: (CGPoint) position {
    self = [super initWithColor: [UIColor colorWithRed:1 green:1 blue:1 alpha:1] size:CGSizeMake(32, 32)];
    if(!self) return nil;
    
    
    atlas = [YMRSharedTextureAtlas getAtlasByName:@"Runners"];
    [self setName:name];
    [self setPosition:position];
    
    [self load];
    currentDirection = CGVectorMake(1,0); //RIGHT
    currentAction = NONE;
    
    moveSpeed = 80; //pixels per second
    
    self.anchorPoint = CGPointMake(0.5,0.8);

    return self;
}

-(void) load {
    SKTexture *frame;
    
    //load all right position, left position will be obtained by scale * -1 (mirroring)
    _standFrames = [NSMutableArray array];
    frame = [atlas textureNamed: [NSString stringWithFormat:@"%@-stand-right.png", self.name]];
    [_standFrames addObject:frame];
    frame = [atlas textureNamed: [NSString stringWithFormat:@"%@-stand-back.png", self.name]];
    [_standFrames addObject:frame];
    
    
    _runFrames = [NSMutableArray array];
    for(int i=1;i<13;i++) {
        frame = [atlas textureNamed: [NSString stringWithFormat:@"%@-run-right%d.png", self.name, i]];
        //frame.filteringMode = SKTextureFilteringNearest;
        [_runFrames addObject:frame];
    }
    
    _stopFrames = [NSMutableArray array];
    for(int i=1;i<4;i++) {
        frame = [atlas textureNamed:[NSString stringWithFormat:@"%@-stop-right%d.png", self.name, i]];
        [_stopFrames addObject:frame];
    }
    
    _rotateFrames = [NSMutableArray array];
    for(int i=5;i>0;i--) {
        frame = [atlas textureNamed:[NSString stringWithFormat:@"%@-rotate%d.png", self.name, i]];
        [_rotateFrames addObject:frame];
    }
    
    NSMutableArray* rotateUpFrames = [NSMutableArray array];
    for(int i=1;i<4;i++) [rotateUpFrames addObject:[atlas textureNamed:[NSString stringWithFormat:@"%@-rotate%d.png", self.name, i]]];
    
    _landingFrames = [NSMutableArray array];
    for(int i=1;i<7;i++) {
        frame = [atlas textureNamed:[NSString stringWithFormat:@"%@-landing%d.png",self.name, i]];
        [_landingFrames addObject:frame];
    }
    
    NSMutableArray *landingUpFrames = [NSMutableArray array];
    [landingUpFrames addObject: [atlas textureNamed:[NSString stringWithFormat:@"%@-stand-back.png",self.name]]];
    
    _jumpFrames = [NSMutableArray array];
    for(int i=1;i<8;i++) {
        frame = [atlas textureNamed:[NSString stringWithFormat:@"%@-jump%d.png", self.name, i]];
        [_jumpFrames addObject:frame];
    }
    
    _climbFrames = [NSMutableArray array];
    for(int i=1;i<9;i++) {
        frame = [atlas textureNamed:[NSString stringWithFormat:@"%@-climb%d.png", self.name, i]];
        [_climbFrames addObject:frame];
    }
    
    runSpriteSize = [_runFrames[0] size];
    
    
    _runAction = [YMRAction animateWithTextures: _runFrames
                                   timePerFrame: 0.1f
                                         resize: NO
                                        restore: YES withTag: RUN_ACTION];
    _stopAction = [YMRAction animateWithTextures:_stopFrames
                                   timePerFrame:0.1f
                                         resize: NO
                                         restore: YES withTag: STOP_ACTION];
    
    _rotateAction = [YMRAction animateWithTextures:_rotateFrames
                                   timePerFrame: 0.08f
                                         resize: NO
                                          restore: YES withTag: TURN_ACTION];
    _rotateUpAction = [YMRAction animateWithTextures:rotateUpFrames
                                        timePerFrame: 0.08f
                                              resize: NO
                                             restore:YES withTag: TURN_ACTION];
    
    _landAction = [YMRAction animateWithTextures:_landingFrames
                                   timePerFrame:0.1f
                                         resize: NO
                                        restore: YES withTag: LANDING_ACTION];
    
    _landActionUp = [YMRAction animateWithTextures:landingUpFrames
                                     timePerFrame:0.1f
                                           resize: NO
                                          restore: YES withTag: LANDING_ACTION];

    
    _jumpAction = [YMRAction animateWithTextures:_jumpFrames
                                   timePerFrame:0.1f
                                         resize: NO
                                         restore: YES withTag: JUMP_ACTION];
    
    _climbAction = [YMRAction animateWithTextures:_climbFrames
                                   timePerFrame:0.1f
                                         resize: NO
                                          restore: YES withTag: CLIMB_ACTION];
    
    
    
    
    [self setFrame:_standFrames[0]];
    
    //init taskQueue
    taskQueue = [NSMutableArray array];
    
    //create physics object
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:[_standFrames[0] size]];
    self.physicsBody.dynamic = NO;
    self.physicsBody.allowsRotation = NO;
    
    self.physicsBody.restitution = 1.0f;
    self.physicsBody.friction = 0.0f;
    self.physicsBody.angularDamping = 0.0f;
    self.physicsBody.linearDamping = 0.0f;
    
    //DEBUG: set visible anchor point
    SKShapeNode* point = [SKShapeNode shapeNodeWithCircleOfRadius:1];
    point.fillColor = [SKColor redColor];
    point.strokeColor = [SKColor redColor];
    point.position  = CGPointMake(0, 0);
    point.zPosition = 2000;
    [self addChild:point];
}


//DEPRICATED
-(void) animate {
    //[self runAction:[SKAction repeatActionForever: [_runAction action] withKey:@"runAnimation"];
}



-(void) setStand {
    NSLog(@"Set runned stand");
    
    if([YMRRunner isDirectionDown:currentDirection] || [YMRRunner isDirectionUp:currentDirection])
        [self setFrame: _standFrames[1]];
    else
        [self setFrame:_standFrames[0]];
}




+ (SKAction *)jumpWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint height:(CGFloat)height {
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    [bezierPath moveToPoint:startPoint];
    CGPoint peak = CGPointMake(startPoint.x + (endPoint.x - startPoint.x)/2, startPoint.y + height);
    [bezierPath addCurveToPoint:endPoint controlPoint1:peak controlPoint2:peak];
    
    SKAction *jumpAction = [SKAction followPath:bezierPath.CGPath asOffset:NO orientToPath:NO duration:.5f];
    jumpAction.timingMode = SKActionTimingEaseIn;
    return jumpAction;
}



/*
-(void) jumpX: (float)x {
    NSLog(@"Jump to: %f", x);
    
    //float jump_position_x = [self position].x + x;
    //float jump_speed = fabs(x)/90;
    
    [taskQueue push: [YMRAction performSelector:@selector(setStand) onTarget:self withTag: JUMP_ACTION]];
    [taskQueue push: _landAction];
    
    //TODO: Switch to physics!
    [taskQueue push: [SKAction applyImpulse:CGVectorMake(x, 2.4) duration: .15]];
    //[taskQueue push: [YMRRunner jumpWithStartPoint: [self position] endPoint: CGPointMake(jump_position_x, [self position].y-1) height: 10]];
    [taskQueue push: [YMRAction performSelector:@selector(setCurrentActionJump) onTarget:self withTag: JUMP_ACTION]];
}
*/



#pragma mark Task queue management

-(void) runNextTask {
    //[self logFunction:@"runNextTask"];
    //NSLog(@"---> currentAction: %d || taskQueue count: %lu", currentAction, (unsigned long)[taskQueue count]);
    
    if(currentAction != NONE || [taskQueue count] == 0) return;
    //check if [self has some Action in run?
    //..
    
    currentTask = (YMRAction*)taskQueue[0];
    SKAction *action = [currentTask action];
    
    [taskQueue removeObjectAtIndex:0];
    
    [self runAction: action];
}



#pragma mark Physics Object protocol implementation


-(BOOL) isFalling {
    //NSLog(@"calling isFalling, current action: %d", currentAction);
    
    return currentAction == FALL_ACTION;
}


-(void) setFrame: (SKTexture*) frame {
    NSLog(@"Call setFrame...");
    [self setTexture:frame];
    [self setSize: [frame size]];
}

-(void) lock {
    currentAction = LOCKED_ACTION;
}

-(void) unlock {
    currentAction = NONE;
}


//----------------- CODE REWORK -------------------


#pragma mark Utility functions

+(BOOL)compareVector: (CGVector) v1 with:(CGVector) v2 {
    if(v1.dx == v2.dx && v1.dy == v2.dy) return true;
    return false;
}

+(BOOL) isDirectionUp: (CGVector) direction {
    return [YMRRunner compareVector:direction with: UP];
}

+(BOOL) isDirectionRight: (CGVector) direction {
    return [YMRRunner compareVector:direction with: RIGHT];
}

+(BOOL) isDirectionLeft: (CGVector) direction {
    return [YMRRunner compareVector:direction with: LEFT];
}

+(BOOL) isDirectionDown: (CGVector) direction {
    return [YMRRunner compareVector:direction with: DOWN];
}

-(void) logFunction:(NSString*) name {
    //if(DEBUG)
    NSLog(@"%@=> with direction: (%f,%f) || position: (%f,%f)", name, currentDirection.dx, currentDirection.dy, [self position].x, [self position].y);
}

-(void) runAction: (SKAction*) action andAfter: (SEL) func {
    SKAction *sequence = [SKAction sequence:@[action, [SKAction performSelector:func onTarget:self]]];
    [self runAction: sequence];
}


#pragma Overided functions

-(void) update: (CFTimeInterval)currentTime {
    //[self logFunction:@"Update"];
    [self runNextTask];
}

#pragma mark Action helper functions

-(void) actionTurnRight {
    [self logFunction:@"actionTurnRight"];
    
    //check if Runner is already looking to the right direction
    if([YMRRunner isDirectionRight:currentDirection]) return;
    
    currentAction = TURN_ACTION;
    
    if([YMRRunner isDirectionLeft: currentDirection] || (([YMRRunner isDirectionUp:currentDirection] || [YMRRunner isDirectionDown:currentDirection]) && [YMRRunner isDirectionLeft:prevDirection])) self.xScale *= -1;
    
    //set start frame before animation
    if([YMRRunner isDirectionUp:currentDirection] || [YMRRunner isDirectionDown:currentDirection]) {
        [self setFrame:_rotateFrames[2]];
        //start animation
        [self runAction: [[_rotateUpAction action] reversedAction] andAfter:@selector(afterTurnRight)];
    }
    else {
        [self setFrame:_rotateFrames[0]];
        //start animation
        [self runAction: [_rotateAction action] andAfter:@selector(afterTurnRight)];
    }
}

-(void) afterTurnRight {
    currentAction = NONE;
    currentDirection  = RIGHT;
    
    //set right frame as after animation it returns to original
    [self setFrame:_rotateFrames[4]];
}

-(void) actionTurnLeft {
    [self logFunction:@"actionTurnLeft"];
    
    //check if Runner is already looking to the right direction
    if([YMRRunner isDirectionLeft:currentDirection]) return;
    
    currentAction = TURN_ACTION;
    
    //if we turn from UP or DOWN directions, need to make the right xScale transformation
    if([YMRRunner isDirectionUp:currentDirection] || [YMRRunner isDirectionDown:currentDirection]) {
        //if previous direction was RIGHT, need to mirror the sprite
        if([YMRRunner isDirectionRight:prevDirection]) self.xScale *= -1;
    } else self.xScale *= -1;
    
    if([YMRRunner isDirectionUp:currentDirection] || [YMRRunner isDirectionDown:currentDirection]) {
        [self setFrame:_rotateFrames[2]];
        
        //start animation
        [self runAction: [[_rotateUpAction action] reversedAction] andAfter:@selector(afterTurnLeft)];
    }
    else {
        [self setFrame:_rotateFrames[0]];
        
        //start animation
        [self runAction: [_rotateAction action] andAfter:@selector(afterTurnLeft)];
    }
    
    //Let's keep the anchor point (should be 0.5, 0.8)
}

-(void) afterTurnLeft {
    [self logFunction:@"afterTurnLeft"];
    currentAction = NONE;
    
    currentDirection = LEFT;
    //set right frame as after animation it returns to original
    [self setFrame:_rotateFrames[4]];
}

-(void) actionTurnUpDown {
    [self logFunction:@"actionTurnUpDown"];
    
    if([YMRRunner isDirectionUp:currentDirection] || [YMRRunner isDirectionDown:currentDirection]) {
        //change direction from Up to Down (or reverse) if necessary
        CGVector direction = CGVectorMake(currentTask.param1, currentTask.param2);
        if(![YMRRunner compareVector:currentDirection with:direction]) {
            currentDirection = direction;
        }
        return;
    }
    
    currentAction = TURN_ACTION;
    
    //set start frame
    [self setFrame:_rotateFrames[1]];
    
    //remember previous direction (will be used after Runner get out from a ladder
    prevDirection = currentDirection;
    
    [self runAction:[_rotateUpAction action] andAfter:@selector(afterTurnUpDown)];
}

-(void) afterTurnUpDown {
    [self logFunction:@"afterTurnUpDown"];
    
    //set frame where runner looks up
    [self setFrame:_standFrames[1]];
    
    //set currentDirection
    currentDirection = CGVectorMake(currentTask.param1, currentTask.param2);

    currentAction = NONE;
    
    //check that the direction is UP or DOWN
    if(![YMRRunner isDirectionUp:currentDirection] && ![YMRRunner isDirectionDown:currentDirection]) {
        NSLog(@"afterTurnUpDown: ERROR: wrong direction: (%f,%f)", currentTask.param1, currentTask.param2);
    }
}

-(void) actionFall {
    [self logFunction:@"actionFall"];
    currentAction = FALL_ACTION;
    
    if([YMRRunner isDirectionUp:currentDirection] || [YMRRunner isDirectionDown:currentDirection])
        [self setFrame:_standFrames[1]];
    else [self setFrame:_standFrames[0]];
    
    self.physicsBody.dynamic = YES;
}

-(void) actionLanding {
    [self logFunction:@"actionLanding"];
    
    currentAction = LANDING_ACTION;
    self.physicsBody.dynamic = NO;
    
    if([YMRRunner isDirectionUp:currentDirection] || [YMRRunner isDirectionDown:currentDirection]) {
        [self afterLanding];
    }
    else {
        [self setSize:[_landingFrames[0] size]];
        
        //start animation
        [self runAction: [_landAction action] andAfter:@selector(afterLanding)];
    }
}

-(void) afterLanding {
    [self logFunction:@"afterLanding"];
    
    //set sprite frame
    currentAction = NONE;
    
    //set stand
    [self setStand];

}

-(void) actionStop {
    [self logFunction:@"actionStop"];
    if(currentAction == STOP_ACTION) return;
    
    currentAction = STOP_ACTION;
    if([YMRRunner isDirectionLeft:currentDirection] || [YMRRunner isDirectionRight:currentDirection]) {
        [self setFrame:_stopFrames[0]];
        
        //some inertia
        [self runAction:[SKAction moveBy:CGVectorMake(5.0f*currentDirection.dx, 0) duration:0.1f]];
        
        //start animation
        [self runAction: [_stopAction action] andAfter:@selector(afterStop)];
    } else [self afterStop];
}

-(void) afterStop {
    currentAction = NONE;
    [self setStand];
}

-(void) actionRun {
    [self logFunction:@"actionRun"];
    currentAction = RUN_ACTION;
    float x = [currentTask param1];
    
    [self runAction: [SKAction moveBy:CGVectorMake(x, 0) duration: fabs(x)/moveSpeed]];
    
    //run animation
    //change frame size
    [self setSize:[_runFrames[0] size]];
    [self runAction:[SKAction repeatActionForever:[_runAction action]]];
    
}

-(void) actionStep {
    [self logFunction:@"actionStep"];
    NSLog(@"---> x: %f", currentTask.param1);
    
    currentAction = STEP_ACTION;
    
    float shift = [currentTask param1] - [self position].x;
    
    [self runAction: [SKAction moveToX:[currentTask param1] duration:fabs(shift)/moveSpeed]];
    
    [self setFrame: _stopFrames[0]];
    [self runAction:[_stopAction action] andAfter:@selector(afterStep)];
}

-(void) afterStep {
    [self logFunction:@"afterStep"];
    currentAction = NONE;
    
    //fix player position
    //[self setPosition:]
}

-(void) actionClimb {
    [self logFunction:@"actionClimb"];
    
    currentAction = CLIMB_ACTION;
    
    float shift = currentTask.param2 - [self position].y;
    
    [self runAction: [SKAction moveToY:currentTask.param2 duration:fabs(shift)/moveSpeed]];
    
    [self setFrame:_climbFrames[0]];
    
    [self runAction:[SKAction repeatActionForever:[_climbAction action]]];
}



#pragma mark Action functions

-(void)run: (CGVector) direction {
}

-(void)turn: (CGVector) direction {
    [self logFunction:@"TURN"];
    if([YMRRunner isDirectionUp:direction] || [YMRRunner isDirectionDown:direction]) {
        //need to make half of turn animation
        [taskQueue push: [YMRAction performSelector:@selector(actionTurnUpDown) onTarget:self withTag:TURN_ACTION andParam1:direction.dx andParam2:direction.dy]];
    } else {
        //need to make full turn or half turn again in case current direction is UP or DOWN
        if([YMRRunner isDirectionRight:direction]) {
            [taskQueue push:[YMRAction performSelector:@selector(actionTurnRight) onTarget:self withTag:TURN_ACTION andParam1: direction.dx andParam2:direction.dy]];
        }
        else {
            [taskQueue push:[YMRAction performSelector:@selector(actionTurnLeft) onTarget:self withTag:TURN_ACTION andParam1: direction.dx andParam2:direction.dy]];
        }
    }
}

-(void) stopRunner {
    [self logFunction:@"stopRunner"];
    
    if(currentAction == RUN_ACTION || currentAction == CLIMB_ACTION)
        [self removeAllActions];
    
    [taskQueue push:[YMRAction performSelector:@selector(actionStop) onTarget:self withTag:STOP_ACTION]];
    
}

-(void) runToX: (float) x {
    
}

/**
 * move the character by X points d
 **/
-(void) runByX: (float)x {
    [self logFunction:@"runByX"];

    [self.taskQueue push: [YMRAction performSelector:@selector(actionRun) onTarget:self withTag: RUN_ACTION andParam1:x andParam2:0]];
}


-(void) stepToX: (float) x {
    [self logFunction:@"stepToX"];
    NSLog(@"---> x: %f",x);
    if([YMRRunner isDirectionUp:currentDirection] || [YMRRunner isDirectionDown:currentDirection]) return;
    
    float shift = x - self.position.x;
    if(fabs(shift) < 1) return;
    
    if(shift/fabs(shift) != currentDirection.dx) {
        [self turn:CGVectorMake(-currentDirection.dx, currentDirection.dy)];
    }
    
    [taskQueue push: [YMRAction performSelector:@selector(actionStep) onTarget:self withTag:STEP_ACTION andParam1:x andParam2:0]];
}

-(void) climbY:(float)y {
    [self logFunction:@"climbY"];
    [taskQueue push: [YMRAction performSelector:@selector(actionClimb) onTarget:self withTag:CLIMB_ACTION andParam1:0 andParam2:y]];
}

-(void) jumpToX:(float)x {
    
}


#pragma mark Control functions

-(void) fall {
    [self logFunction:@"Fall"];
    if(currentAction == FALL_ACTION || currentAction == JUMP_ACTION) return;
    
    //stop all tasks and clear task queue
    [self removeAllActions];
    [taskQueue removeAllObjects];
    
    //start falling
    [taskQueue push:[YMRAction performSelector:@selector(actionFall) onTarget:self withTag:FALL_ACTION]];
    
    //if before falling we were running, let's keep runinig
    if(currentAction == RUN_ACTION) {
        [self run: currentDirection];
    }
    
    currentAction = NONE;
}

-(void) land {
    [self logFunction:@"Land"];
    [self removeAllActions];
    
    currentAction = NONE;
    
    [taskQueue insertObject:[YMRAction performSelector:@selector(actionLanding) onTarget:self withTag:LANDING_ACTION] atIndex:0];
}

-(void) stop {
    [self logFunction:@"Stop"];
    
    if(currentAction == JUMP_ACTION || currentAction == STOP_ACTION) return;
    
    //clear the task queue except turn action
    if(currentAction != TURN_ACTION && currentAction != LANDING_ACTION) {
        [taskQueue removeAllObjects];
    } else {
        //need to remove task from the queue except the turn action and landing actions
        //find all TURN_ACTIONs
        int i=0;
        while([(YMRAction*)taskQueue[i] tag] == TURN_ACTION || [(YMRAction*)taskQueue[i] tag] == LANDING_ACTION) i++;
        [taskQueue removeObjectsInRange:NSMakeRange(i, [taskQueue count] - i)];
        return;
    }
    
    //we cannot stop while falling or already stopped
    if(currentAction  == FALL_ACTION || currentAction == NONE) {
        return;
    }
    
    [self stopRunner];
    
    //to run next task
    currentAction = NONE;
}


-(void) climb: (CGVector) direction withX: (float)x {
    [self logFunction:@"Climb"];
    NSLog(@"---> Direction: (%f,%f) || X: %f", direction.dx, direction.dy, x);
    
    if(fabs([self position].x - x) >= 1) {
        [self stepToX:x];
    }
    
    if(![YMRRunner compareVector:direction with:currentDirection]) {
        [self turn:direction];
    }
    
    [self climbY:1000*direction.dy];
}


-(void) jump {
    
}





@end
