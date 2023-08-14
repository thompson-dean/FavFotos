//
//  FavoritePhotosDataService.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/14.
//

import Foundation
import CoreData

protocol FavoritePhotosDataServiceProtocol {
    /// Retrieve a list of favorite photos.
    func getFavorites() -> [PhotoEntity]
    
    /// Retrieve a specific `PhotoEntity` by its identifier.
    func getPhotoEntity(for id: Int) -> PhotoEntity?
    
    /// Add a photo to the favorites list.
    func add(photo: Photo)
    
    /// Remove a specific photo entity from the favorites list.
    func delete(entity: PhotoEntity)
    
    /// Check if a photo, identified by its ID, is marked as favorite.
    func isPhotoLiked(id: Int) -> Bool
}

class FavoritePhotosDataService: FavoritePhotosDataServiceProtocol {
    
    /// Core Data container for storing favorite photos.
    private let container: NSPersistentContainer
    
    /// Initializes the `FavoritePhotosDataService`, loading the Core Data store.
    init() {
        container = NSPersistentContainer(name: Constants.containerName)
        container.loadPersistentStores { (_, error) in
            if let error = error {
                print("Error loading Core Data! \(error)")
            }
        }
    }
    
    /// Fetches all favorite photos.
    func getFavorites() -> [PhotoEntity] {
        let request = NSFetchRequest<PhotoEntity>(entityName: Constants.entityName)
        do {
            return try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching Portfolio Entities. \(error)")
            return []
        }
    }
    
    /// Fetches a specific `PhotoEntity` based on its identifier.
    func getPhotoEntity(for id: Int) -> PhotoEntity? {
        let request = NSFetchRequest<PhotoEntity>(entityName: Constants.entityName)
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            return try container.viewContext.fetch(request).first
        } catch {
            print("Error fetching photo entity by ID. \(error)")
            return nil
        }
    }
    
    /// Adds a new photo to the favorites list.
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
    
    /// Deletes a given photo entity from the favorites list.
    func delete(entity: PhotoEntity) {
        container.viewContext.delete(entity)
        applyChanges()
    }
    
    /// Saves the changes made to the Core Data context.
    private func save() {
        do {
            try container.viewContext.save()
        } catch let error {
            print("Error saving to Core Data. \(error)")
        }
    }
    
    /// Applies changes (typically an add or delete operation) by saving them.
    private func applyChanges() {
        save()
    }
    
    /// Checks if a specific photo, identified by its ID, is in the favorites list.
    func isPhotoLiked(id: Int) -> Bool {
        let request = NSFetchRequest<PhotoEntity>(entityName: Constants.entityName)
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

