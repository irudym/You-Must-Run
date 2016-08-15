//
//  MapObject.h
//  You Must Run
//
//  Created by Igor on 12/08/16.
//  Copyright © 2016 Igor Rudym. All rights reserved.
//

#ifndef MapObject_h
#define MapObject_h

#import "YMRRunner.h"

@protocol  YMRMapObject <NSObject>


@required

// highlight the object, for example: switch light in a lift, switch on
// light at a screen when a runner is near, and so on...
-(void) setHighlight: (BOOL) status;

-(void) activateWithObject: (SKNode*) object;
-(void) deactivate;

@end


#endif /* MapObject_h */
