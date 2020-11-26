//
//  GEAMAssetPackBuilder.h
//  
//
//  Created by Pavel Kasila on 11/25/20.
//

#import <Foundation/Foundation.h>
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <assert.h>
#import "asset_pack_reader.h"

@interface GEAMAssetPackBuilder : NSObject
{
    FILE *packFile;
}
- initWithOutputPath: (NSString*) outputPath;
- (void) addAsset: (id) asset NS_SWIFT_NAME(add(asset:));
- (void) endAssetPack;
@end
