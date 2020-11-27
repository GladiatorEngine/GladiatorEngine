//
//  asset_pack_reader.h
//  
//
//  Created by Pavel Kasila on 11/25/20.
//

#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <assert.h>

typedef struct {
    long size;
    FILE* file;
} AssetPackFile;

/// Initializes AssetPackFile and opens file
/// @param filename file to be opened as asset pack
AssetPackFile* asset_pack_init(const char * __restrict filename);

/// Returns length of the next block (on current position)
/// @param apf AssetPackFile to work with asset pack
long asset_pack_location(AssetPackFile* apf);

/// Get current location
/// @param apf AssetPackFile to work with asset pack
int64_t asset_pack_get_next_block_length(AssetPackFile* apf);

/// Get block starting current position
/// @param apf AssetPackFile to work with asset pack
/// @param assetBlockLength length of block (from asset_pack_get_next_block_length)
uint8_t* asset_pack_get_block(AssetPackFile* apf, int64_t assetBlockLength);

/// Deinitialize AssetPackFile and close file
/// @param apf AssetPackFile used to work with asset pack
void asset_pack_deinit(AssetPackFile* apf);
