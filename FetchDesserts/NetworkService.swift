import Foundation

class NetworkService {
    func fetchDessertsData() async throws -> [Dessert] {
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert") else {
            throw NetworkError.invalidURL
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(DessertResponse.self, from: data)
            return decoded.desserts
        } catch {
            throw error
        }
    }

    func fetchDessertDetails(id: String) async throws -> DessertDetails? {
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=\(id)") else {
            throw NetworkError.invalidURL
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(DetailResponse.self, from: data)
            return decoded.details.first
        } catch {
            throw error
        }
    }
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
}
