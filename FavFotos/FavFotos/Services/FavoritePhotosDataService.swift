//
//  FavoritePhotosDataService.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/14.
//

import Foundation
import CoreData

class FavoritePhotosDataService {
    
    private let container: NSPersistentContainer
    private let containerName: String = "FavoritesContainer"
    private let entityName: String = "PhotoEntity"
    
    init() {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { (_, error) in
            if let error = error {
                print("Error loading Core Data! \(error)")
            }
        }
    }
    
    func getFavorites() -> [PhotoEntity] {
        let request = NSFetchRequest<PhotoEntity>(entityName: entityName)
        do {
            return try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching Portfolio Entities. \(error)")
            return []
        }
    }
    
    func getPhotoEntity(for id: Int) -> PhotoEntity? {
        let request = NSFetchRequest<PhotoEntity>(entityName: entityName)
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            return try container.viewContext.fetch(request).first
        } catch {
            print("Error fetching photo entity by ID. \(error)")
            return nil
        }
    }
    
    func add(photo: Photo) {
        let photoEntity = PhotoEntity(context: container.viewContext)
        
        photoEntity.id = Int32(photo.id)
        if let imageData = ImageCache.shared.image(for: photo.id) {
            photoEntity.image = imageData
        }
        photoEntity.width = Int32(photo.width)
        photoEntity.height = Int32(photo.height)
        photoEntity.photographer = photo.photographer
        photoEntity.photographerURL = photo.photographerURL
        
        applyChanges()
    }
    
    func delete(entity: PhotoEntity) {
        container.viewContext.delete(entity)
        applyChanges()
    }
    
    
    private func save() {
        do {
            try container.viewContext.save()
        } catch let error {
            print("Error saving to Core Data. \(error)")
        }
    }
    
    private func applyChanges() {
        save()
    }
    
    func isPhotoLiked(id: Int) -> Bool {
        let request = NSFetchRequest<PhotoEntity>(entityName: entityName)
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let count = try container.viewContext.count(for: request)
            return count > 0
        } catch {
            print("Error checking if photo is liked. \(error)")
            return false
        }
    }
}


