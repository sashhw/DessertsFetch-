import Foundation

@Observable
class ViewModel {
    private let networkService = NetworkService()
    
    private(set) var desserts: [Dessert] = []
    var selectedDessert: Dessert? {
        didSet {
            fetchDetailsIfNeeded()
        }
    }
    var dessertDetails: DessertDetails?
    var isDetailPresented: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?
    var showErrorAlert: Bool = false

    func fetchDesserts() async {
        isLoading = true
        errorMessage = nil
        do {
            var fetchedDesserts = try await networkService.fetchDessertsData()
            fetchedDesserts.sort(by: { $0.name < $1.name })
            self.desserts = fetchedDesserts
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
        isLoading = false
    }

    private func fetchDetailsIfNeeded() {
        guard let id = selectedDessert?.id else { return }
        Task {
            await fetchDetails(id: id)
        }
    }

    func fetchDetails(id: String) async {
        do {
            let details = try await networkService.fetchDessertDetails(id: id)
            self.dessertDetails = details
            self.isDetailPresented = true
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}
