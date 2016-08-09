//
//  YMRSharedTextureAtlas.m
//  You Must Run
//
//  Created by Igor on 08/11/15.
//  Copyright © 2015 Igor Rudym. All rights reserved.
//

#import "YMRSharedTextureAtlas.h"

extern NSMutableDictionary* gSharedTextures = nil;

@implementation YMRSharedTextureAtlas

+(void) initSharedAtlas {
    gSharedTextures = [[NSMutableDictionary alloc] init];
}

+(void) addAtlas: (SKTextureAtlas*) atlas WithName: (NSString*)atlasName {
    if(!gSharedTextures) [YMRSharedTextureAtlas initSharedAtlas];
    [gSharedTextures setObject: atlas forKey: atlasName];
}

+(SKTextureAtlas*) getAtlasByName: (NSString*) name {
    return gSharedTextures[name];
}

+(SKTextureAtlas*) loadAtlas:(NSString *)atlasName {
    SKTextureAtlas* atlas = [SKTextureAtlas atlasNamed:atlasName];
    if(atlas) [YMRSharedTextureAtlas addAtlas:atlas WithName:atlasName];
    return atlas;
}

@end
