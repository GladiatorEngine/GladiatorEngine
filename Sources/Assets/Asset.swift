//
//  Asset.swift
//  
//
//  Created by Pavel Kasila on 11/24/20.
//

import Foundation

@objc public protocol Asset {
    init(sourceData: Data)
    func assetData() -> Data
    func assetType() -> AssetType
}
