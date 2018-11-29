//
//  YMRRunner.m
//  You Must Run
//
//  Created by Igor on 08/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import "YMRRunner.h"
#import "YMRStopState.h"

CGVector const LEFT = {-1.0f,0.0f};
CGVector const RIGHT = {1.0f, 0.0f};
CGVector const UP = {0.0f,1.0f};
CGVector const DOWN = {0.0f,-1.0f};


@implementation YMRRunner
{
    SKTextureAtlas* atlas;
}

@synthesize currentDirection;
@synthesize moveSpeed;

@synthesize stateMachine;




-(id) initWithName: (NSString*) name AndPosition: (CGPoint) position {
    self = [super initWithColor: [UIColor colorWithRed:1 green:1 blue:1 alpha:1] size:CGSizeMake(32, 32)];
    if(!self) return nil;
    
    
    atlas = [YMRSharedTextureAtlas getAtlasByName:@"Runners"];
    [self setName:name];
    [self setPosition:position];
    
    [self load];
    currentDirection = CGVectorMake(1,0); //RIGHT
    
    moveSpeed = 80; //pixels per second
    
    self.anchorPoint = CGPointMake(0.5,0);
    
    // init State Machine
    stateMachine = [FSMStackMachine createWithObject:self];
    [stateMachine pushState:[YMRStopState createState]];

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
    
    //runSpriteSize = [_runFrames[0] size];
    
    
    _runAction = [SKAction animateWithTextures: _runFrames
                                   timePerFrame: 0.1f
                                         resize: YES
                                        restore: YES ];
    _stopAction = [SKAction animateWithTextures:_stopFrames
                                   timePerFrame:0.1f
                                         resize: YES
                                         restore: NO ];
    
    _rotateAction = [SKAction animateWithTextures:_rotateFrames
                                   timePerFrame: 0.08f
                                         resize: YES
                                          restore: NO ];
    
    _rotateUpAction = [SKAction animateWithTextures:rotateUpFrames
                                        timePerFrame: 0.08f
                                              resize: YES
                                             restore:NO ];
    
    _landAction = [SKAction animateWithTextures:_landingFrames
                                   timePerFrame:0.1f
                                         resize: YES
                                        restore: NO ];
    
    _landActionUp = [SKAction animateWithTextures:landingUpFrames
                                     timePerFrame:0.1f
                                           resize: NO
                                          restore: YES ];

    
    _jumpAction = [SKAction animateWithTextures:_jumpFrames
                                   timePerFrame:0.1f
                                         resize: YES
                                         restore: YES ];
    
    _climbAction = [SKAction animateWithTextures:_climbFrames
                                   timePerFrame:0.1f
                                         resize: YES
                                          restore: YES ];
    
    
    
    
    [self setFrame:_standFrames[0]];
    
    //create physics object
    CGSize size =  [(SKTexture *)_standFrames[0] size];
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
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
    // [self addChild:point];
}

#pragma mark State Object methods

/*
 * @function stand - set stand frame of the runner
 */
-(void) stop {
    //cancel all actions
    [self removeAllActions];
    
    //switch off physics just in case
    self.physicsBody.dynamic = NO;
    
    if([YMRRunner isDirectionDown:currentDirection] || [YMRRunner isDirectionUp:currentDirection])
        [self setFrame:_standFrames[1]];
    else
        [self setFrame:_standFrames[0]];
}

-(void) fall {
    // stop all actions
    [self removeAllActions];
    
    [self logFunction:@"FALL"];
    
    if([YMRRunner isDirectionUp:currentDirection] || [YMRRunner isDirectionDown:currentDirection])
        [self setFrame:_standFrames[1]];
    else [self setFrame:_standFrames[0]];
    
    self.physicsBody.dynamic = YES;
}

-(void) land {
    self.physicsBody.dynamic = NO;
    
    //start animation
    if(!([YMRRunner isDirectionDown:currentDirection] || [YMRRunner isDirectionUp:currentDirection]))[self runAction: _landAction];
}

-(void) run {
    float x = currentDirection.dx * 2000;
    
    [self runAction: [SKAction moveBy:CGVectorMake(x, 0) duration: fabs(x)/moveSpeed]];
    
    //run animation
    //change frame size
    //[self setSize:[_runFrames[0] size]];
    [self runAction:[SKAction repeatActionForever:_runAction]];
}

-(void) stopping {
    // stop all actions
    [self removeAllActions];
    
    [self setFrame:_stopFrames[0]];
    
    //some inertia
    [self runAction:[SKAction moveBy:CGVectorMake(5.0f*currentDirection.dx, 0) duration:0.1f]];
    
    //start animation
    [self runAction: _stopAction];
}

-(void) jump {
    self.physicsBody.dynamic = YES;
    [self runAction: _jumpAction];
    
    //kick the runner to skies!
    [self.physicsBody applyImpulse:CGVectorMake(currentDirection.dx, 2)];
}


//DEPRECATED
-(void) turn {
    if([YMRRunner isDirectionUp:currentDirection] || [YMRRunner isDirectionDown:currentDirection]) {
        // [self setFrame:_rotateFrames[2]];
        
        //start animation
        [self runAction: [_rotateUpAction reversedAction]];
    }
    else {
        // [self setFrame:_rotateFrames[0]];
        
        //start animation
        [self runAction: _rotateAction];
    }
    
    //change direction
    currentDirection.dx = -currentDirection.dx;
    
    //in case prev direction was UP or DOWN
    currentDirection.dy = 0;
    
    //change sprite direction using mirorring
    self.xScale *= -1;
}

//DEPRECATED
// use turnTo: UP instead
-(void) turnUp {
    if(!([YMRRunner isDirectionUp:currentDirection] || [YMRRunner isDirectionDown:currentDirection])) {
        [self runAction: _rotateUpAction];
    }
    [self setCurrentDirection:UP];
}

//DEPRECATED
// use turnTo: DOWN instead
-(void) turnDown {
    if(!([YMRRunner isDirectionUp:currentDirection] || [YMRRunner isDirectionDown:currentDirection])) {
        [self runAction: _rotateUpAction];
    }
    [self setCurrentDirection:DOWN];
}

-(void) climb {
    [self runAction: [SKAction repeatActionForever:_climbAction]];
    
    CGFloat dy = currentDirection.dy * 2000;
    NSLog(@"Climb by %f", dy);
    [self runAction: [SKAction moveBy:CGVectorMake(0, dy) duration:fabs(dy)/[self moveSpeed]]]; //???? too fast
}

- (void)stepTo:(CGPoint)point {
    //supposing that the runners 'steps to' only in X
    //TODO: need to handle Y movement
    
    [self runAction: _stopAction];
    
    CGPoint moveToPoint;
    moveToPoint.x = point.x;
    moveToPoint.y = [self position].y;
    NSLog(@"StepTo: %f from %f", moveToPoint.x, [self position].x);
    [self runAction: [SKAction moveTo:moveToPoint duration:fabs((moveToPoint.x - [self position].x)/[self moveSpeed])]];
}

-(void)turnTo:(CGVector)direction {
    if([YMRRunner isDirectionUp:currentDirection] || [YMRRunner isDirectionDown:currentDirection]) {
        if([YMRRunner isDirectionUp:direction] || [YMRRunner isDirectionDown:direction]) {
            [self setCurrentDirection:direction];
            return;
        }
        //start animation
        [self runAction: [_rotateUpAction reversedAction]];
    } else {
        if([YMRRunner isDirectionUp:direction] || [YMRRunner isDirectionDown:direction]) {
            [self setCurrentDirection:direction];
            [self runAction: _rotateUpAction];
            return;
        }
        //start animation
        [self runAction: _rotateAction];
    }
    [self setCurrentDirection:direction];
    if([YMRRunner isDirectionLeft:direction]) self.xScale = -1;
    if([YMRRunner isDirectionRight:direction]) self.xScale = 1;
}

#pragma mark State Machine operation

-(void) handleEvent:(YMREvent*)event {
    [stateMachine handleEvent:event];
}

#pragma Overided functions

-(void) update: (CFTimeInterval)currentTime {
    [stateMachine update];
}

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


-(void) setFrame: (SKTexture*) frame {
    // NSLog(@"Call setFrame...");
    [self setSize: [frame size]];
    [self setTexture:frame];
}

-(int) getHeight {
    return self.size.height;
}



@end
