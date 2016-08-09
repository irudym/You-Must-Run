//
//  YMRControlButton.m
//  You Must Run
//
//  Created by Igor on 14/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import "YMRControlButton.h"

@implementation YMRControlButton



-(id) init
{
    self = [super init];
    _obj_down = nil;
    _obj_up = nil;
    return self;
}

-(id) initWithImage: (NSString*)filename {
    self = [self initWithImageNamed:filename];
    _obj_down = nil;
    _obj_up = nil;
    self.userInteractionEnabled = TRUE;
    return self;
}

+(id) controlButtonWithImage:(NSString *)filename {
    return [[YMRControlButton alloc] initWithImage:filename];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event
{
    if(!_obj_down) return;
    [_obj_down performSelector: _func_down];
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event
{
    if(!_obj_up) return;
    [_obj_up performSelector:_func_up];
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    // we want to know the location of our touch in this scene
    //CGPoint touchLocation = [touch locationInView: self.parent];
    //self.position = touchLocation;
}

-(void) setButtonDownTarget:(SEL)func fromObject:(id)object {
    _obj_down = object;
    _func_down = func;
}

-(void) setButtonUpTarget:(SEL)func fromObject:(id)object {
    _obj_up = object;
    _func_up = func;
}


@end
