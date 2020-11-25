//
//  GEAMAssetPackBuilder.m
//  
//
//  Created by Pavel Kasila on 11/25/20.
//

#import "GEAMAssetPackBuilder.h"

@implementation GEAMAssetPackBuilder

- (id)initWithOutputPath:(NSString *)outputPath {
    self = [self init];
    packFile = fopen([outputPath cStringUsingEncoding:NSUTF8StringEncoding], "wb");
    return self;
}

- (void)addAsset:(id<Asset>)asset {
    NSData *data = [asset assetData];
    unsigned char *bytePtr = (unsigned char *)[data bytes];
    
    fwrite(bytePtr, data.length, 1, packFile);
}

- (void)endAssetPack {
    fclose(packFile);
}

@end
