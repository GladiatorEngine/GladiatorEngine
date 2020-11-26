import Foundation
import Crypto
import AssetManagerC
@_exported import Assets

public class AssetManager {
    public private(set) var textures: [Texture] = []
    public private(set) var models: [Model] = []
    
    public init() {
        
    }
    
    public func loadTextureAsset(path: String) throws {
        let assetTuple = try self.loadAsset(path: path)
        if assetTuple.0 != .texture {
            fatalError("\(path) is not a texture")
        }
        
        try loadTextureAsset(data: assetTuple.1)
    }
    
    public func loadTextureAsset(data: Data) throws {
        self.textures.append(Texture(sourceData: data))
    }
    
    public func loadModelAsset(path: String) throws {
        let assetTuple = try self.loadAsset(path: path)
        if assetTuple.0 != .model {
            fatalError("\(path) is not a model")
        }
        
        try loadModelAsset(data: assetTuple.1)
    }
    
    public func loadModelAsset(data: Data) throws {
        self.models.append(Model(sourceData: data))
    }
    
    public func loadAssetPack(path: String) throws {
        let apf = asset_pack_init(path.cString(using: .utf8))!
        while asset_pack_location(apf) < apf.pointee.size {
            let blockLength = asset_pack_get_next_block_length(apf)
            let block = asset_pack_get_block(apf, blockLength)!
            let data = Data(Array(UnsafeBufferPointer(start: block, count: Int(blockLength+1))))
            
            let asset = try loadAssetFromData(data: data, hashed: false)
            
            switch asset.0 {
            case .texture:
                try self.loadTextureAsset(data: asset.1)
                break
            case .model:
                try self.loadModelAsset(data: asset.1)
                break
            case .pack:
                fatalError("Asset pack can't contain another asset pack in it")
                break
            default:
                fatalError("Asset type \(asset.0.rawValue) is not implemented now!")
                break
            }
        }
        asset_pack_deinit(apf)
    }
    
    public func loadAssetPack(data packData: Data) throws {
        var position = 0
        while position < packData.endIndex {
            let length: Int = packData.subdata(in: position..<position+MemoryLayout<Int>.size).withUnsafeBytes {$0.pointee} + 1
            let asset = try loadAssetFromData(data: packData.subdata(in: position+MemoryLayout<Int>.size..<position+MemoryLayout<Int>.size+length), hashed: false)
            position = position+MemoryLayout<Int>.size+length
            
            switch asset.0 {
            case .texture:
                try self.loadTextureAsset(data: asset.1)
                break
            case .model:
                try self.loadModelAsset(data: asset.1)
                break
            case .pack:
                fatalError("Asset pack can't contain another asset pack in it")
                break
            default:
                fatalError("Asset type \(asset.0.rawValue) is not implemented now!")
                break
            }
        }
    }
    
    private func loadAsset(path: String) throws -> (AssetType, Data) {
        return try loadAssetFromData(data: try Data(contentsOf: URL(fileURLWithPath: path)))
    }
    
    private func loadAssetFromData(data fullAsset: Data, hashed: Bool = true) throws -> (AssetType, Data) {
        let assetTypeByte: UInt8 = fullAsset.subdata(in: 0..<1).withUnsafeBytes {$0.pointee}
        
        guard let assetType = AssetType(rawValue: assetTypeByte) else {throw AssetLoadErrors.failedToParseType(byte: assetTypeByte)}
        let data = fullAsset.subdata(in: 1..<(hashed ? fullAsset.endIndex-64 : fullAsset.endIndex))
        
        if hashed {
            // Verify data with hash
            let hash = fullAsset.subdata(in: fullAsset.endIndex-64..<fullAsset.endIndex)
            if Data() + SHA512.hash(data: data) != hash {
                fatalError("Asset hash is not valid!")
            }
        }
        
        return (assetType, data)
    }
    
    public static func buildAssetPackData(assets: [Asset]) -> Data {
        var data = Data()
        
        for asset in assets {
            let aData = asset.assetData()
            var length: Int = aData.endIndex
            data = data + Data(bytes: &length, count: MemoryLayout<Int>.size) + Data([asset.assetType().rawValue]) + aData
        }
        
        return data
    }
    
    public static func saveAssetPack(assets: [Asset], path: String) {
        let builder = GEAMAssetPackBuilder(outputPath: path)!
        for asset in assets {
            builder.add(asset: asset)
        }
        builder.endAssetPack()
    }
    
    public static func saveAsset(path: String, asset: Asset) {
        return saveAsset(path: path, type: asset.assetType(), data: asset.assetData())
    }
    
    public static func saveAsset(path: String, type: AssetType, data: Data) {
        do {
            let typeByteData = Data([type.rawValue])
            let hash = SHA512.hash(data: data)
            let fullData = typeByteData + data + hash
            try fullData.write(to: URL(fileURLWithPath: path))
        } catch let e {
            fatalError("Failed to save asset: \(e)")
        }
    }
}
