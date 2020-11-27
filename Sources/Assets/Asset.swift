//
//  Asset.swift
//  
//
//  Created by Pavel Kasila on 11/24/20.
//

import Foundation

@objc public protocol Asset {
    @objc init(sourceData: Data)
    @objc func assetData() -> Data
    @objc func assetType() -> AssetType
}
