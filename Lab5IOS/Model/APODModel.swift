// APODModel.swift
import Foundation

// Модель описує дані, які ми очікуємо отримати з APOD API
// Codable дозволяє легко декодувати JSON у цю структуру
struct APODModel: Codable, Identifiable {
    
    // Ми можемо використати 'url' як унікальний ID для SwiftUI
    var id: String { url }
    
    let date: String
    let explanation: String
    let mediaType: String
    let title: String
    let url: String // URL до зображення
    
    // Оскільки JSON використовує 'snake_case' (media_type),
    // а Swift 'camelCase' (mediaType), ми кажемо декодеру,
    // як їх співвідносити.
    enum CodingKeys: String, CodingKey {
        case date, explanation, title, url
        case mediaType = "media_type"
    }
}
