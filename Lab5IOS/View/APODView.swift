// APODView.swift
import SwiftUI

struct APODView: View {
    
    // @StateObject створює та керує життєвим циклом нашої ViewModel.
    // ViewModel буде жити, доки живе цей View.
    @StateObject private var viewModel = APODViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // ZStack дозволяє нам показувати різні стани
                // (завантаження, помилка, контент) поверх один одного.
                
                if viewModel.isLoading {
                    ProgressView("Завантаження...") // Індикатор завантаження
                } else if let errorMessage = viewModel.errorMessage {
                    // Стан помилки
                    Text("Помилка: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else if let apod = viewModel.apodData {
                    // Стан успіху: показуємо контент
                    APODContentView(apod: apod)
                }
            }
            .navigationTitle("Фото дня NASA")
            .onAppear {
                // Коли View з'являється, даємо команду ViewModel
                // завантажити дані (але тільки якщо їх ще немає).
                if viewModel.apodData == nil {
                    viewModel.loadData()
                }
            }
            .toolbar {
                // Додамо кнопку для примусового оновлення
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.loadData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

// Я виніс основний контент в окрему структуру для чистоти коду.
// Це відповідає рекомендаціям Apple щодо декомпозиції UI.
struct APODContentView: View {
    let apod: APODModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(apod.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                // Перевіряємо тип медіа. APOD може повернути відео (напр. YouTube)
                if apod.mediaType == "image" {
                    
                    // AsyncImage - вбудований у SwiftUI спосіб
                    // асинхронно завантажити та показати зображення.
                    AsyncImage(url: URL(string: apod.url)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView() // Показуємо, поки вантажиться
                                .frame(height: 300)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(10)
                        case .failure:
                            // Заглушка, якщо картинка не завантажилась
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 300)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else if apod.mediaType == "video" {
                    // Якщо це відео, ми не можемо його програти прямо тут
                    // (це складніше), але можемо дати посилання.
                    Link("Це відео. Натисніть, щоб подивитися у браузері.",
                         destination: URL(string: apod.url)!)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Text(apod.explanation)
                    .font(.body)
                
                Text("Дата: \(apod.date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

// Це для попереднього перегляду в Xcode
#Preview {
    APODView()
}
