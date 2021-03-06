import Foundation
import Crypto
import AssetManagerC
import Logger
@_exported import Assets

/// Manages all assets in game
@objc public class AssetManager: NSObject {
    @objc public private(set) var textures: [Texture] = []
    @objc public private(set) var models: [Model] = []
    @objc private var logger: Logger
    
    /// Initilizes AssetManager with console Logger (by default) or any other custom Logger
    /// - Parameter logger: Logger to log all messages
    @objc public init(logger: Logger = Logger()) {
        self.logger = logger
    }
    
    /// Loads texture asset from file
    /// - Parameter path: path to texture asset
    /// - Throws: if it cannot load asset from file
    @objc public func loadTextureAsset(path: String) throws {
        let assetTuple = try self.loadAsset(path: path)
        if assetTuple.0 != .texture {
            fatalError("\(path) is not a texture")
        }
        
        self.logger.write(message: "AssetManager has verified that \(path) is a texture asset", type: .debug)
        
        loadTextureAsset(data: assetTuple.1)
    }
    
    /// Loads texture asset from raw data
    /// - Parameter data: raw texture asset data
    @objc public func loadTextureAsset(data: Data) {
        self.textures.append(Texture(sourceData: data))
        self.logger.write(message: "AssetManager has loaded a new texture with id \(self.textures.count - 1)", type: .info)
    }
    
    /// Loads model asset from file
    /// - Parameter path: path to model asset
    /// - Throws: if it cannot load asset from file
    @objc public func loadModelAsset(path: String) throws {
        let assetTuple = try self.loadAsset(path: path)
        if assetTuple.0 != .model {
            fatalError("\(path) is not a model")
        }
        
        self.logger.write(message: "AssetManager has verified that \(path) is a model asset", type: .debug)
        
        loadModelAsset(data: assetTuple.1)
    }
    
    /// Loads model from raw data
    /// - Parameter data: raw model asset data
    @objc public func loadModelAsset(data: Data) {
        self.models.append(Model(sourceData: data))
        self.logger.write(message: "AssetManager has loaded a new model with id \(self.textures.count - 1)", type: .info)
    }
    
    /// Loads asset pack from path
    /// - Parameter path: path to asset pack
    /// - Throws: if something goes wrong with loading asset from raw data from pack
    @objc public func loadAssetPack(path: String) throws {
        let apf = asset_pack_init(path.cString(using: .utf8))!
        self.logger.write(message: "AssetManager has initialized AssetPack loading session from \(path)", type: .debug)
        while asset_pack_location(apf) < apf.pointee.size {
            self.logger.write(message: "Loading a new asset block from AssetPack \(path)", type: .debug)
            let blockLength = asset_pack_get_next_block_length(apf)
            let block = asset_pack_get_block(apf, blockLength)!
            let data = Data(Array(UnsafeBufferPointer(start: block, count: Int(blockLength+1))))
            
            let asset = try loadAssetFromData(data: data, hashed: false)
            
            self.logger.write(message: "Loaded a new asset block from AssetPack \(path) with type byte \(asset.0.rawValue)", type: .debug)
            
            switch asset.0 {
            case .texture:
                self.loadTextureAsset(data: asset.1)
                break
            case .model:
                self.loadModelAsset(data: asset.1)
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
        self.logger.write(message: "AssetManager has deinitialized AssetPack loading session from \(path)", type: .debug)
        self.logger.write(message: "AssetManager has loaded blocks from AssetPack \(path)", type: .info)
    }
    
    /// Loads asset pack from raw data
    /// - Parameter packData: raw data
    /// - Throws: if something goes wrong with loading asset from raw data from pack
    @objc public func loadAssetPack(data packData: Data) throws {
        self.logger.write(message: "AssetManager is loading AssetPack from raw data", type: .debug)
        var position = 0
        while position < packData.endIndex {
            let length: Int = packData.subdata(in: position..<position+MemoryLayout<Int>.size).withUnsafeBytes {$0.pointee} + 1
            let asset = try loadAssetFromData(data: packData.subdata(in: position+MemoryLayout<Int>.size..<position+MemoryLayout<Int>.size+length), hashed: false)
            position = position+MemoryLayout<Int>.size+length
            
            switch asset.0 {
            case .texture:
                self.loadTextureAsset(data: asset.1)
                break
            case .model:
                self.loadModelAsset(data: asset.1)
                break
            case .pack:
                fatalError("Asset pack can't contain another asset pack in it")
                break
            default:
                fatalError("Asset type \(asset.0.rawValue) is not implemented now!")
                break
            }
        }
        self.logger.write(message: "AssetManager has loaded AssetPack from raw data", type: .debug)
    }
    
    private func loadAsset(path: String) throws -> (AssetType, Data) {
        self.logger.write(message: "AssetManager is loading asset from \(path)", type: .debug)
        defer {
            self.logger.write(message: "AssetManager had loaded asset from \(path)", type: .debug)
        }
        return try loadAssetFromData(data: try Data(contentsOf: URL(fileURLWithPath: path)))
    }
    
    private func loadAssetFromData(data fullAsset: Data, hashed: Bool = true) throws -> (AssetType, Data) {
        self.logger.write(message: "AssetManager is loading asset from data \(hashed ? "with" : "without") hash", type: .debug)
        let assetTypeByte: UInt8 = fullAsset.subdata(in: 0..<1).withUnsafeBytes {$0.pointee}
        
        guard let assetType = AssetType(rawValue: assetTypeByte) else {throw AssetLoadErrors.failedToParseType(byte: assetTypeByte)}
        let data = fullAsset.subdata(in: 1..<(hashed ? fullAsset.endIndex-64 : fullAsset.endIndex))
        
        if hashed {
            self.logger.write(message: "AssetManager is verifying asset's data", type: .debug)
            // Verify data with hash
            let hash = fullAsset.subdata(in: fullAsset.endIndex-64..<fullAsset.endIndex)
            if Data() + SHA512.hash(data: data) != hash {
                fatalError("Asset hash is not valid!")
            }
            self.logger.write(message: "AssetManager has verified asset's data", type: .debug)
        }
        
        self.logger.write(message: "AssetManager is loaded asset from data \(hashed ? "with" : "without") hash", type: .debug)
        
        return (assetType, data)
    }
    
    /// Builds asset pack out of array of assets
    /// - Parameter assets: assets to be stored in asset pack
    /// - Returns: raw asset pack data
    @objc public static func buildAssetPackData(assets: [Asset]) -> Data {
        var data = Data()
        
        for asset in assets {
            let aData = asset.assetData()
            var length: Int = aData.endIndex
            data = data + Data(bytes: &length, count: MemoryLayout<Int>.size) + Data([asset.assetType().rawValue]) + aData
        }
        
        return data
    }
    
    /// Builds and immediately save asset pack out of assets
    /// - Parameters:
    ///   - assets: assets to be stored in pack
    ///   - path: path to save asset pack
    @objc public static func saveAssetPack(assets: [Asset], path: String) {
        let builder = GEAMAssetPackBuilder(outputPath: path)!
        for asset in assets {
            builder.add(asset: asset)
        }
        builder.endAssetPack()
    }
    
    /// Save asset to path
    /// - Parameters:
    ///   - path: path to save asset
    ///   - asset: asset itself
    @objc public static func saveAsset(path: String, asset: Asset) {
        return saveAsset(path: path, type: asset.assetType(), data: asset.assetData())
    }
    
    /// Save raw data with asset type to path
    /// - Parameters:
    ///   - path: path to save
    ///   - type: asset type in header
    ///   - data: raw data
    @available(*, deprecated, message: "This function will be replaced by saveAsset(path:asset:), please migrate")
    @objc public static func saveAsset(path: String, type: AssetType, data: Data) {
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
