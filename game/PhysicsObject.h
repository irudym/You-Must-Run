//
//  PhysicsObject.h
//  You Must Run
//
//  Created by Igor on 08/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#ifndef PhysicsObject_h
#define PhysicsObject_h

FOUNDATION_EXPORT CGVector const LEFT;
FOUNDATION_EXPORT CGVector const RIGHT;
FOUNDATION_EXPORT CGVector const UP;
FOUNDATION_EXPORT CGVector const DOWN;


@protocol YMRPhysicsObject <NSObject>

-(void) stop;
-(void) fall;
-(void) land;

-(bool) isFalling;

-(int) currentAction;
-(CGVector) currentDirection;


@end


#endif /* PhysicsObject_h */
