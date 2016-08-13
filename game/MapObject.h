//
//  MapObject.h
//  You Must Run
//
//  Created by Igor on 12/08/16.
//  Copyright © 2016 Igor Rudym. All rights reserved.
//

#ifndef MapObject_h
#define MapObject_h

@protocol  YMRMapObject <NSObject>

@required
-(void) activate;
-(void) deactivate;

@end


#endif /* MapObject_h */
