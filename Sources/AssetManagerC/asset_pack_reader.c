//
//  asset_pack_reader.c
//  
//
//  Created by Pavel Kasila on 11/25/20.
//

#include "asset_pack_reader.h"

AssetPackFile* asset_pack_init(const char * __restrict filename) {
    FILE* f = fopen(filename, "rb");
    AssetPackFile* p = malloc(sizeof(AssetPackFile));
    
    p->file = f;
    
    fseek(f, 0L, SEEK_END); // Go to EOF
    p->size = ftell(f) - 64; // AssetPack length without hash
    fseek(f, 0L, SEEK_SET); // Return to start
    
    // Verify that asset file is exactly AssetPack
    uint8_t assetTypeByte;
    fread(&assetTypeByte, sizeof(uint8_t), 1, f);
    assert(assetTypeByte == 0xEE); // Assert that first byte is 0xEE (AssetPack)
    
    return p;
}

int32_t asset_pack_get_next_block_length(AssetPackFile* apf) {
    // Get block length
    int32_t assetBlockLength;
    fread(&assetBlockLength, sizeof(int32_t), 1, apf->file);
    return assetBlockLength;
}

long asset_pack_location(AssetPackFile* apf) {
    return ftell(apf->file);
}

uint8_t* asset_pack_get_block(AssetPackFile* apf, int32_t assetBlockLength) {
    FILE* f = apf->file;
    
    // Read bytes for this length
    uint8_t* p = malloc( sizeof(uint8_t) * ( assetBlockLength + 1 ) );
    fread(p, sizeof(char), assetBlockLength, f);
    
    return p;
}

void asset_pack_deinit(AssetPackFile* apf) {
    fclose(apf->file);
    free(apf);
}
