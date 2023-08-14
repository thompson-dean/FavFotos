//
//  ImageCache.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/09.
//

import Foundation

/// A utility class that manages an in-memory cache for image data.
class ImageCache {
    
    /// Defines the type of cache that will be used to store image data.
    typealias CacheType = NSCache<NSString, NSData>
    
    /// Singleton instance of `ImageCache`.
    static let shared = ImageCache()
    
    /// Private initializer to ensure only one instance is created.
    private init() { }
    
    /// In-memory cache for storing image data. Limited by count and total memory usage.
    private lazy var cache: CacheType = {
        let cache = CacheType()
        cache.countLimit = 120 // Limit to 120 images
        cache.totalCostLimit = 100 * 1024 * 1024 // Limit to 100MB
        return cache
    }()
    
    /// Clears all objects from the cache.
    func clear() {
        cache.removeAllObjects()
    }
    
    /// Fetches image data from the cache for a given ID.
    func image(for id: Int) -> Data? {
        return cache.object(forKey: "\(id)" as NSString) as Data?
    }
    
    /// Inserts or updates image data into the cache for a given ID.
    func insertImage(_ data: Data, for id: Int) {
        return cache.setObject(data as NSData, forKey: "\(id)" as NSString)
    }
}
