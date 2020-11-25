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

AssetPackFile* asset_pack_init(const char * __restrict filename);
long asset_pack_location(AssetPackFile* apf);
int64_t asset_pack_get_next_block_length(AssetPackFile* apf);
uint8_t* asset_pack_get_block(AssetPackFile* apf, int64_t assetBlockLength);
void asset_pack_deinit(AssetPackFile* apf);
