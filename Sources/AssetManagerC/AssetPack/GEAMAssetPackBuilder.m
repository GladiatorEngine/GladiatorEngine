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
    
    // Write AssetPack byte
    uint8_t assetTypeByte = AssetTypePack;
    fwrite(&assetTypeByte, sizeof(uint8_t), 1, packFile);
    
    return self;
}

- (void)addAsset:(id<Asset>)asset {
    NSData *data = [asset assetData];
    unsigned char *bytePtr = (unsigned char *)[data bytes];
    
    // Write length
    int64_t length = data.length;
    fwrite(&length, sizeof(int64_t), 1, packFile);
    
    // Write AssetType
    uint8_t assetTypeByte = [asset assetType];
    fwrite(&assetTypeByte, sizeof(uint8_t), 1, packFile);
    
    // Write data itself
    fwrite(bytePtr, data.length, 1, packFile);
}

- (void)endAssetPack {
    fclose(packFile);
}

@end
