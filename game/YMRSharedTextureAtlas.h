//
//  YMRSharedTextureAtlas.h
//  You Must Run
//
//  Created by Igor on 08/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface YMRSharedTextureAtlas : NSObject

+(void) initSharedAtlas;
+(void) addAtlas: (SKTextureAtlas*) atlas WithName: (NSString*)atlasName;
+(SKTextureAtlas*) getAtlasByName: (NSString*)name;

+(SKTextureAtlas*) loadAtlas: (NSString*)atlasName;

@end
