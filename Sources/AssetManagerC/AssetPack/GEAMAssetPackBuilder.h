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

/// Class which is used to build asset packs and write assets to them
@interface GEAMAssetPackBuilder : NSObject
{
    FILE *packFile;
}
/// Initializes GEAMAssetPackBuilder with path to output file
/// @param outputPath path to output asset pack
- initWithOutputPath: (NSString*) outputPath;

/// Adds new asset to asset pack (can't be reverted)
/// @param asset asset to be added
- (void) addAsset: (id) asset NS_SWIFT_NAME(add(asset:));

/// Ends asset pack creation and closes file
- (void) endAssetPack;
@end
