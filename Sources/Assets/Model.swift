//
//  Model.swift
//  
//
//  Created by Pavel Kasila on 11/24/20.
//

import Foundation

@objc public class Model: NSObject, Asset {
    @objc required public init(sourceData: Data) {
        let amountOfVertices: Int = sourceData.subdata(in: 0..<MemoryLayout<Int>.size).withUnsafeBytes {$0.pointee}
        var vertices = [Vertex]()
        for i in 0..<amountOfVertices {
            let pos = MemoryLayout<Int>.size + Vertex.dataSize() * i
            vertices.append(.init(data: sourceData.subdata(in: pos..<pos+Vertex.dataSize())))
        }
        self.vertices = vertices
    }
    
    @objc public init(vertices: [Vertex]) {
        self.vertices = vertices
    }
    
    @objc public func assetData() -> Data {
        var data = Data()
        
        data = data + withUnsafeBytes(of: self.vertices.count) { Data($0) }
        
        for vertex in self.vertices {
            data += vertex.toData()
        }
        
        return data
    }
    
    @objc public func assetType() -> AssetType {
        return .model
    }
    
    @objc public private(set) var vertices: [Vertex]
}

