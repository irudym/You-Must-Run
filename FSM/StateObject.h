//
//  StateObject.h
//  You Must Run
//
//  Created by Igor Rudym (Intel) on 04/11/2018.
//  Copyright © 2018 Igor Rudym. All rights reserved.
//

#ifndef StateObject_h
#define StateObject_h

// to include CGPoint definition
#import <SpriteKit/SpriteKit.h>

@protocol StateObject <NSObject>

-(void) stop;
-(void) run;
-(void) fall;
-(void) land;
//-(void) turn;
//-(void) turnUp;
-(void) climb;

-(void) turnTo: (CGVector)direction;
-(void) stepTo: (CGPoint)point;

//inertia
-(void) stopping;

//Some useful SKNode methods
- (BOOL)hasActions;
-(void) setPosition: (CGPoint)position;

@end


#endif /* StateObject_h */
