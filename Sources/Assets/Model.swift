//
//  Model.swift
//  
//
//  Created by Pavel Kasila on 11/24/20.
//

import Foundation

public class Model: Asset {
    required public init(sourceData: Data) {
        let amountOfVertices: Int = sourceData.subdata(in: 0..<MemoryLayout<Int>.size).withUnsafeBytes {$0.pointee}
        var vertices = [[Float]]()
        for i in 0..<amountOfVertices {
            var f = [Float]()
            for j in 0..<4 {
                let pos = MemoryLayout<Int>.size + MemoryLayout<Float>.size * ((i+1)*(j+1)-1)
                f.append(sourceData.subdata(in: pos..<pos+MemoryLayout<Float>.size).withUnsafeBytes {$0.pointee})
            }
            vertices.append(f)
        }
        self.vertices = vertices
    }
    
    public init(vertices: [[Float]]) {
        self.vertices = vertices
    }
    
    public func assetData() -> Data {
        var data = Data()
        
        data = data + withUnsafeBytes(of: self.vertices.count) { Data($0) }
        
        for vertex in self.vertices {
            for f in vertex {
                data = data + withUnsafeBytes(of: f) { Data($0) }
            }
        }
        
        return data
    }
    
    public func assetType() -> AssetType {
        return .model
    }
    
    public private(set) var vertices: [[Float]]
}

