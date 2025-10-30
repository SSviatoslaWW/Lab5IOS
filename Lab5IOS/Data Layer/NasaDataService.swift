// NasaDataService.swift
import Foundation

// Спеціальні помилки для кращої обробки в UI
enum NetworkError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case invalidData
}

// Клас, що реалізує "прошарок даних"
class NasaDataService {
    
    private let apiKey = "0z9FfDd3cy59MCuYd9iZr52KVYnMTg3vr0Gr8YCh"
    private let apodURL = "https://api.nasa.gov/planetary/apod"
    
    // Асинхронна функція, яка повертає нашу Модель або кидає Помилку
    func fetchAPOD() async throws -> APODModel {
        
        // 1. Створення URL з параметрами (наш API ключ)
        guard var urlComponents = URLComponents(string: apodURL) else {
            throw NetworkError.invalidURL
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        // 2. Виконання запиту
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Перевірка, чи відповідь успішна (код 200)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NetworkError.invalidData
            }
            
            // 3. Декодування JSON
            let decoder = JSONDecoder()
            let apodData = try decoder.decode(APODModel.self, from: data)
            return apodData
            
        } catch let error as URLError {
            throw NetworkError.networkError(error) // Помилка мережі
        } catch let error as DecodingError {
            throw NetworkError.decodingError(error) // Помилка розбору JSON
        } catch {
            throw NetworkError.networkError(error) // Інші помилки
        }
    }
}
