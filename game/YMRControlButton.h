//
//  YMRControlButton.h
//  You Must Run
//
//  Created by Igor on 14/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface YMRControlButton : SKSpriteNode

-(id)init;
+(id)controlButtonWithImage: (NSString*) filename;

-(void) setButtonDownTarget: (SEL)func fromObject: (id)object;
-(void) setButtonUpTarget: (SEL)func fromObject: (id)object;

@property SEL func_down;
@property SEL func_up;
@property id obj_down;
@property id obj_up;

@end
