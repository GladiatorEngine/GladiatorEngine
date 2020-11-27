//
//  Texture.swift
//  
//
//  Created by Pavel Kasila on 11/24/20.
//

import Foundation

@objc public class Texture: NSObject, Asset {
    let data: Data
    
    @objc required public init(sourceData: Data) {
        self.data = sourceData
    }
    
    @objc public func assetData() -> Data {
        return self.data
    }
    
    @objc public func assetType() -> AssetType {
        return .texture
    }
}
