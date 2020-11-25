//
//  Texture.swift
//  
//
//  Created by Pavel Kasila on 11/24/20.
//

import Foundation

public class Texture: Asset {
    let data: Data
    
    required public init(sourceData: Data) {
        self.data = sourceData
    }
    
    public func assetData() -> Data {
        return self.data
    }
    
    public func assetType() -> AssetType {
        return .texture
    }
}
