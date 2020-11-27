//
//  Vertex.swift
//  
//
//  Created by Pavel Kasila on 11/27/20.
//

import Foundation

public struct Vertex: VertexStorable {
    
    public private(set) var coordinate: Coordinate
    public private(set) var id: UUID
    
    public init(id: UUID = UUID(), coordinate: Coordinate) {
        self.id = id
        self.coordinate = coordinate
    }
    
    public func toData() -> Data {
        var data = Data()
        
        // Add id
        data += withUnsafeBytes(of: self.id) { Data($0) }
        
        // Add coordinate data
        data += self.coordinate.toData()
        
        return data
    }
    
    public static func dataSize() -> Int {
        MemoryLayout<UUID>.size + Coordinate.dataSize()
    }
    
    public init(data: Data) {
        self.id = data.subdata(in: 0..<MemoryLayout<UUID>.size).withUnsafeBytes {$0.pointee}
        self.coordinate = Coordinate(data: data.subdata(in: MemoryLayout<UUID>.size..<data.endIndex))
    }
}

extension Vertex {
    public struct Coordinate: VertexStorable {
        public typealias PrecisionType = Float
        
        public var x: PrecisionType
        public var y: PrecisionType
        public var z: PrecisionType
        
        public init(x: PrecisionType, y: PrecisionType, z: PrecisionType) {
            self.x = x
            self.y = y
            self.z = z
        }
        
        public func toData() -> Data {
            [x, y, z].map { v -> Data in withUnsafeBytes(of: v) { Data($0) } }.reduce(Data()) { $0 + $1 }
        }
        
        public static func dataSize() -> Int {
            MemoryLayout<PrecisionType>.size * 3
        }
        
        public init(data: Data) {
            var coords = Array<PrecisionType>()
            for i in 0..<3 {
                coords.append(data.subdata(in: MemoryLayout<PrecisionType>.size*i..<MemoryLayout<PrecisionType>.size*(i+1)).withUnsafeBytes {$0.pointee})
            }
            self.x = coords[0]
            self.y = coords[1]
            self.z = coords[2]
        }
    }
}

public protocol VertexStorable {
    func toData() -> Data
    static func dataSize() -> Int
    init(data: Data)
}
