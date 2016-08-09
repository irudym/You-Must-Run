//
//  LightSource.h
//  You Must Run
//
//  Created by Igor on 07/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#ifndef LightSource_h
#define LightSource_h

#import <SpriteKit/SpriteKit.h>


@protocol YMRLightSource <NSObject>

@required
-(SKNode*) getLightMap;

@end


#endif /* LightSource_h */
