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

@synthesize nextAction;
@synthesize nextPosition;
//@synthesize nextDirection;
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
    
    moveSpeed = 1;
    
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


#pragma mark Helper Functions


//DEPRICATED
-(void) setCurrentActionRun {
    NSLog(@"Start run animation");
    
    currentAction = RUN_ACTION;
    //change frame size
    //[self setSize:[_runFrames[0] size]];
    //start animation
    //[self runAction:[SKAction repeatActionForever:_runAction]];
}


-(void) beforeActionRun {
    NSLog(@"BeforeActionRun");
    
    currentAction = RUN_ACTION;
    
    //change frame size
    [self setSize:[_runFrames[0] size]];
    [self runAction:[SKAction repeatActionForever:[_runAction action]]];
}


//turn Runner Right and Left
-(void) beforeTurnRight {
    if(currentDirection.dx == 1 && currentDirection.dy == 0) return;
    
    if(currentDirection.dy != 1 /*UP*/ && currentDirection.dy != -1 /*DOWN*/) [self setFrame:_rotateFrames[0]]; else [self setFrame:_rotateFrames[2]];
    
    if(currentDirection.dx == -1 /*LEFT*/) self.xScale *= -1;
    
    if(currentDirection.dy == 1 /*UP*/ || currentDirection.dy == -1 /*DOWN*/) {
        if(prevDirection.dx == -1 /*LEFT*/) self.xScale *= -1;
    }
    
    //TODO: it's strage, that I need to resize every time I switch a sprite.
    [self setSize: [_rotateFrames[0] size]];
    
    //Let's keep the anchor point (should be 0.5, 0.8)
    
    currentAction = TURN_ACTION;
    currentDirection = RIGHT; //RIGHT
}

-(void) afterTurnRight {
    [self setFrame:_rotateFrames[4]];
}

-(void) beforeTurnLeft {
    if(currentDirection.dx < 0) return; //LEFT
    
    if(currentDirection.dy > 0 /*UP*/ ||  currentDirection.dy < 0 /*DOWN*/) {
        if(prevDirection.dx!=-1 /*LEFT*/) self.xScale *=-1;
    } else self.xScale *= -1;
    
    //TODO: it's strage, that I need to resize every time I switch a sprite.
    //[self setSize: [_rotateFrames[0] size]];
    if(currentDirection.dy != 1 /*UP*/ && currentDirection.dy != -1 /*DOWN*/) [self setFrame:_rotateFrames[0]]; else [self setFrame:_rotateFrames[2]];
    
    //Let's keep the anchor point (should be 0.5, 0.8)
    
    currentAction = TURN_ACTION;
    currentDirection = LEFT;
}

-(void) afterTurnLeft {
    NSLog(@"After Turn Left");
    //TODO: Strange, why does animation in SKAction return to the 0th frame?
    [self setFrame:_rotateFrames[4]];
}

-(void) beforeTurnUpDown {
    NSLog(@"Turn Up from direction: (%f, %f), position: (%f,%f)", currentDirection.dx, currentDirection.dy, [self position].x, [self position].y);
    
    if(currentDirection.dx==0 && (currentDirection.dy<0 || currentDirection.dy>0)) return;

    [self setSize: [_rotateFrames[1] size]];
    prevDirection = currentDirection;
    
    currentAction = TURN_ACTION;
    [self runAction: [_rotateUpAction action]];
}

-(void) afterTurnUpDown {
    [self setFrame:_standFrames[1]];
    currentDirection = UP; //UP
    if(currentTask.param2 >0 )currentDirection = UP;
    else if(currentTask.param2 <0 ) currentDirection = DOWN;
    else {
        NSLog(@"afterTurnUpDown: ERROR: wrong direction: (%f,%f)", currentTask.param1, currentTask.param2);
    }
    NSLog(@"afterTurnUp => position: (%f,%f)", [self position].x, [self position].y);
}


-(void) setStand {
    NSLog(@"Set runned stand");
    
    //set stand frame
    if(currentDirection.dy > 0 /*UP*/ || currentDirection.dy <0) [self setFrame: _standFrames[1]]; else
        [self setFrame:_standFrames[0]];
    
    self.physicsBody.dynamic = NO;
    //currentAction = NONE;
}


-(void) beforeActionStop {
    NSLog(@"beforeActionStop => position: (%f,%f)", [self position].x, [self position].y);
    currentAction = STOP_ACTION;
    if(currentDirection.dy !=1 && currentDirection.dy != -1 /*DOwN*/) {
        [self setFrame:_stopFrames[0]];
        //some inertion
        [self runAction:[SKAction moveBy:CGVectorMake(5.0f*currentDirection.dx, 0) duration:0.1f]];
    }
}

-(void) afterActionStop {
    [self setStand];
    currentAction = NONE;
}


-(void) setCurrentActionFall {
    currentAction = FALL_ACTION;
    
    if(currentDirection.dy!=1 /*UP*/) [self setFrame:_standFrames[0]]; else [self setFrame:_standFrames[1]];
    
    NSLog(@"Start falling");
    self.physicsBody.dynamic = YES;
}


//DEPRICATED
-(void) setCurrentActionStep {
    //fix the frame size
    [self setFrame: _stopFrames[0]];
}

-(void) beforeActionStep {
    //fix the frame size
    [self setFrame: _stopFrames[0]];
    [self runAction: [_stopAction action]];
}

-(void) afterActionStep {
    //need to fix runner position x as after moveBy action X position could be just about the required position (due to float coordinates)
    NSLog(@"Call afterActionStep with params: %f and %f", currentTask.param1, currentTask.param2);
    //[self setPosition:CGPointMake(currentTask.param1, [self position].y)];
    NSLog(@"\tRunner positionX :%f", [self position].x);
}



//DEPRICATED
-(void) setCurrentActionLand {
    currentAction = LANDING_ACTION;
    
    //set frame size
    if(currentDirection.dy!=1) [self setFrame:_landingFrames[0]]; else [self setSize:[_standFrames[1] size]];
    
    self.physicsBody.dynamic = NO;
}

-(void) beforeActionLanding {
    //currentAction = LANDING_ACTION; //it's already set in function landRunner
    
    //set frame size
    if(currentDirection.dy!=1) [self setFrame:_landingFrames[0]]; else [self setSize:[_standFrames[1] size]];
    
    self.physicsBody.dynamic = NO;
}

-(void) afterActionLanding {
    currentAction = NONE;
}



-(void) setCurrentActionJump {
    currentAction = JUMP_ACTION;
    [self setFrame:_jumpFrames[0]];
    [self runAction: [_jumpAction action]];
    self.physicsBody.dynamic = YES;
}


-(void) beforeActionClimb {
    NSLog(@"beforeActionClimb => position: (%f,%f)", [self position].x, [self position].y);

    currentAction = CLIMB_ACTION;
    NSLog(@"Run animation climb");
    [self setFrame:_climbFrames[3]]; //this fame will be shown, when animation stops
    
    [self runAction:[SKAction repeatActionForever:[_climbAction action]]];
    NSLog(@"beforeActionClimb => position: (%f,%f)", [self position].x, [self position].y);
}

-(void) actionClimb {
    //[taskQueue push: [YMRAction moveToY:y duration: moveSpeed * fabs(y)/100 withTag: CLIMB_ACTION]];
    
    float y = 1000;
    if(currentTask.param2 <0) y = -y;
    //[self runAction: [SKAction moveBy:CGVectorMake(roundf([self position].x), y) duration:self.moveSpeed * 1000/80]];
    [self runAction: [SKAction moveToY:[self position].y + y duration:self.moveSpeed * 1000/80]];
}

-(void) afterActionClimb {
    //as climbins is enternal action, so only action "stop" can stop the runner
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

#pragma mark Action Functions
-(void) runX:(float)x {
    NSLog(@"Run to: %f", x);
    
    //TODO: need to set right calculation!
    // fabs(currentX - x)/100
    [taskQueue push: [YMRAction performSelector:@selector(beforeActionRun) onTarget:self withTag: RUN_ACTION]];
    //NEED TO CHANGE TO MOVEBY!!!!!!!
    [taskQueue push: [YMRAction moveToX:x duration: moveSpeed * fabs([self position].x - x)/100 withTag: RUN_ACTION]];
}

-(void) stepToX:(float)x {
    if(currentDirection.dy >0 || currentDirection.dy < 0) return;
    NSLog(@"StepTo: %f from positionX: %f", x, self.position.x);
    float shift = x - self.position.x;
    
    NSLog(@"Shift FABS: %f", fabs(shift));
    if(fabs(shift) < 1) return;
    NSLog(@"Should move by %f and current direction: (%f,%f)", shift, currentDirection.dx, currentDirection.dy);
    if(shift/fabs(shift) != currentDirection.dx) {
        NSLog(@"\thave to turn to the right direction from %f to %f", currentDirection.dx, -currentDirection.dx);
        [self turn:CGVectorMake(-currentDirection.dx, currentDirection.dy)];
    }
    
    [taskQueue push: [YMRAction performSelector:@selector(beforeActionStep) onTarget: self withTag:STEP_ACTION]];
    [taskQueue push: [YMRAction moveBy:CGVectorMake(shift,0) duration: moveSpeed * fabs(shift)/80 withTag: STEP_ACTION]];
    [taskQueue push: [YMRAction performSelector:@selector(afterActionStep) onTarget:self withTag:STEP_ACTION andParam1:x andParam2:[self position].y]];
}


-(void) turn: (CGVector) direct {
    if(direct.dy > 0 /*UP*/ || direct.dy <0 /*DOWN*/) {
        //Rotate UP || Down
        //           
        [taskQueue push:[YMRAction performSelector:@selector(beforeTurnUpDown) onTarget:self withTag: TURN_ACTION]];
        [taskQueue push: [YMRAction performSelector:@selector(afterTurnUpDown) onTarget:self withTag: TURN_ACTION andParam1:direct.dx andParam2:direct.dy]];
        
    } else {
        if(direct.dx > 0 /*RIGHT*/) [taskQueue push:[YMRAction performSelector:@selector(beforeTurnRight) onTarget:self withTag:TURN_ACTION]];
            else [taskQueue push:[YMRAction performSelector:@selector(beforeTurnLeft) onTarget:self withTag: TURN_ACTION]];
        
        if(currentDirection.dy > 0 /*UP*/ || currentDirection.dy < 0)
            [taskQueue push: [_rotateUpAction reversedAction]];
        else [taskQueue push:_rotateAction];
        
        if(direct.dx > 0 /*RIGHT*/) [taskQueue push:[YMRAction performSelector:@selector(afterTurnRight) onTarget:self withTag: TURN_ACTION]];
            else [taskQueue push:[YMRAction performSelector:@selector(afterTurnLeft) onTarget:self withTag: TURN_ACTION]];
    }
}

-(void) stopRunner {
    NSLog(@"Stop the runner, direction: %f, %f", currentDirection.dx, currentDirection.dy);
    
    [taskQueue push: [YMRAction performSelector:@selector(beforeActionStop) onTarget:self withTag: STOP_ACTION]];
    
    //This could be moved to beforeActionStop and afterActionStop <- setStand for example
    if(currentDirection.dy != 1 /*UP*/ && currentDirection.dy != -1 /*DOwN*/) {
        [taskQueue push: _stopAction];
        //[taskQueue push: [YMRAction performSelector:@selector(setStand) onTarget:self withTag: STOP_ACTION]];
    }
    [taskQueue push: [YMRAction performSelector:@selector(afterActionStop) onTarget:self withTag: STOP_ACTION]];
    
}

-(void) fallY: (float) y {
    NSLog(@"Fall to: %f", y);
    
    //TODO: need to set right calculation!
    //let say that speed is 10 pixels per second
    //float fall_speed = 30;
    //float fall_time = ([self position].y - y)/fall_speed;
    //NSLog(@"Falling with speed: %f", fall_time);
    //[taskQueue push: [SKAction moveToY:y duration: fall_time]];
    
    [taskQueue push: [YMRAction performSelector:@selector(setCurrentActionFall) onTarget:self withTag: FALL_ACTION]];
}

-(void) landRunner {
    NSLog(@"Landing the runner");
    
    //due to before all task were cleared, set currentAction to LANDING_ACTION to be able runNextTask (in case a runner is falling it doens't execute)
    currentAction = LANDING_ACTION;
    
    [taskQueue insertObject:[YMRAction performSelector:@selector(afterActionLanding) onTarget:self withTag: LANDING_ACTION] atIndex:0];
    if(fabs(currentDirection.dy) != 1 ) [taskQueue insertObject: [YMRAction performSelector:@selector(setStand) onTarget:self withTag:LANDING_ACTION] atIndex: 0];
    if(currentDirection.dy >0 /*UP*/ || currentDirection.dy <0 /*DOWN*/) [taskQueue insertObject: _landActionUp atIndex: 0];
        else [taskQueue insertObject: _landAction atIndex: 0];
    [taskQueue insertObject: [YMRAction performSelector:@selector(beforeActionLanding) onTarget:self withTag: LANDING_ACTION] atIndex: 0];
}

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

-(void) climbY:(float)y {
    //TODO: need to set right calculation!
    NSLog(@"Climb to %f", y);
    
    [taskQueue push: [YMRAction performSelector:@selector(beforeActionClimb) onTarget:self withTag: CLIMB_ACTION]];
    //[taskQueue push: [YMRAction moveToY:y duration: moveSpeed * fabs(y)/100 withTag: CLIMB_ACTION]];
    [taskQueue push: [YMRAction performSelector:@selector(actionClimb) onTarget:self withTag:CLIMB_ACTION andParam1:0 andParam2:y]];
    [taskQueue push: [YMRAction performSelector:@selector(afterActionClimb) onTarget:self withTag: CLIMB_ACTION]];
}


#pragma mark Control Functions

-(void) stop {
    if(currentAction == JUMP_ACTION || currentAction == STOP_ACTION) return;
    
    //clear the queue
    [taskQueue removeAllObjects];
    
    //we cannot stop while falling
    if(currentAction  == FALL_ACTION || currentAction == NONE) {
        return;
    }
    
    [self removeAllActions];
    
    [self stopRunner];
    
    [self runNextTask];
}

-(void) fall {
    if(currentAction == JUMP_ACTION) return;
    if(currentAction == FALL_ACTION) return;
    
    //stop all tasks and clear task queue
    [self removeAllActions];
    [taskQueue removeAllObjects];
    
    
    [self fallY:-32];
    
    //if before falling we were running, let's keep runninig
    if(currentAction == RUN_ACTION) {
        [self run: currentDirection];
    }
    
    [self runNextTask];
}

-(void) land {
    [self removeAllActions];
    [self landRunner];
    [self runNextTask];
}

-(void) climb:(CGVector)direct  withX: (float) x {
    NSLog(@"Climb the ladder to: %f\n\tPositions => currentX: %f | Ladder: %f | currentDirection: (%f,%f)", direct.dy, [self position].x, x, currentDirection.dx, currentDirection.dy);
    
    // need to make following steps before climbing the ladder
    //1. check the runner looks to the ladder
    //2. make a little step to the ladder
    if(fabs([self position].x - x) >=1) {
        //NSLog(@"Climb check the direction: %d <=> %d", (int)((x - [self position].x)/fabs(x - [self position].x)), self.currentDirection);
        //if((int)((x - [self position].x)/fabs(x - [self position].x)) != self.currentDirection) return; //looking to the wrong direction
        [self stepToX: x];
    }
    
    //check if our direction is up or down
    if(direct.dy>0 && currentDirection.dy != 1 /*UP*/) {
        [self turn: UP];
    } else if(direct.dy<0 && currentDirection.dy != -1 /*DOWN*/ ){
        [self turn: DOWN];
    }
    
    [self climbY:500*direct.dy];
    
    if(currentAction == NONE) {
        [self runNextTask];
    }
}


//let think about what is the best way to climb on ladders. Just climb up and let YMRPhysicsWorld checks the end of the ladder or just provide the limit point for climbing
-(void) climbTo: (float)y {
    
}

-(void) jump {
    //TODO: debug ladder climbing
    return;
    
    if(currentAction == JUMP_ACTION) return;
    [self jumpX:currentDirection.dx];
    
    if(currentAction == NONE) {
        [self runNextTask];
    }
}



#pragma mark Task queue management
-(void) runNextTask {
    
    if(currentAction == FALL_ACTION) return;
    
    //NSLog(@"Next task... queue size: %lu", [taskQueue count]);
    if([taskQueue count] == 0) return;
    
    
    //need tp get the action from the start of Queue!
    currentTask = (YMRAction*)taskQueue[0];
    SKAction *action = [currentTask action];
    
    [taskQueue removeObjectAtIndex:0];
    
    
    SKAction *next = [SKAction performSelector: @selector(runNextTask) onTarget:self];
    SKAction *sequence = [SKAction sequence:@[action, next]];
    
    [self runAction: sequence];
}


#pragma mark New key pressed events

//move the sprite right
-(void) right {
    [self runX:1000];
}


#pragma mark Physics Object protocol implementation

//-(void) stop {
//    [self removeAllActions];
//    [self setFrame:_standFrames[0]];
//}

-(BOOL) isFalling {
    //NSLog(@"calling isFalling, current action: %d", currentAction);
    
    return currentAction == FALL_ACTION;
}


-(void) setFrame: (SKTexture*) frame {
    NSLog(@"Call setFrame...");
    [self setTexture:frame];
    [self setSize: [frame size]];
}

//Candidate for deprication
/*
-(CGVector) getDirection: (Direction) direct {
    if(direct == RIGHT) return CGVectorMake(1, 0);
    if(direct == LEFT) return CGVectorMake(-1, 0);
    if(direct == UP) return CGVectorMake(0, 1);
    return CGVectorMake(0, -1); //DOWN
}
*/



@end
