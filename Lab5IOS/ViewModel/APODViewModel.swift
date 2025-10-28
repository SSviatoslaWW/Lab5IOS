// APODViewModel.swift
import Foundation
import Combine

// @MainActor гарантує, що всі оновлення @Published
// властивостей відбуваються в головному потоці, що безпечно для UI.
@MainActor
class APODViewModel: ObservableObject {
    
    // Дані, які View буде відображати
    @Published var apodData: APODModel?
    
    // Стани для UI
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Наш сервіс даних
    private let dataService = NasaDataService()
    
    func loadData() {
        // 1. Встановлюємо стан завантаження
        isLoading = true
        errorMessage = nil
        
        // Використовуємо Task для виклику асинхронної функції
        Task {
            do {
                // 2. Викликаємо наш Data Layer
                let data = try await dataService.fetchAPOD()
                
                // 3. Оновлюємо дані (це автоматично оновить View)
                self.apodData = data
                
            } catch let error as NetworkError {
                // 4. Обробляємо наші кастомні помилки
                switch error {
                case .invalidURL:
                    self.errorMessage = "Неправильна URL адреса."
                case .networkError(let err):
                    self.errorMessage = "Помилка мережі: \(err.localizedDescription)"
                case .decodingError:
                    self.errorMessage = "Помилка формату даних."
                case .invalidData:
                    self.errorMessage = "Отримано невірні дані від сервера."
                }
            } catch {
                // Загальна помилка
                self.errorMessage = "Невідома помилка: \(error.localizedDescription)"
            }
            
            // 5. Завершуємо завантаження
            self.isLoading = false
        }
    }
}
