//
//  ImageCache.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/09.
//

import Foundation

class ImageCache {
    
    typealias CacheType = NSCache<NSString, NSData>
    
    static let shared = ImageCache()
    
    private init() { }
    
    private lazy var cache: CacheType = {
        let cache = CacheType()
        cache.countLimit = 120
        cache.totalCostLimit = 100 * 1024 * 1024
        return cache
    }()
    
    func image(for id: Int) -> Data? {
        return cache.object(forKey: "\(id)" as NSString) as Data?
    }
    
    func insertImage(_ data: Data, for id: Int) {
        return cache.setObject(data as NSData, forKey: "\(id)" as NSString)
    }
}
