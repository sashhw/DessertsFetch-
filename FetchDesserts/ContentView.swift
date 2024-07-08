import SwiftUI

struct ContentView: View {
    @State private var viewModel = ViewModel()

    var body: some View {
        VStack {
            HStack {
                Text("Desserts")
                    .font(.largeTitle)
                    .padding(.trailing, 8)
                Image(systemName: "birthday.cake")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
            }
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                List {
                    ForEach(viewModel.desserts, id: \.self) { dessert in
                        HStack(alignment: .center) {
                            AsyncImage(url: URL(string: dessert.imageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Rectangle())
                            } placeholder: {
                                Rectangle()
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 50, height: 50)
                            .cornerRadius(5)

                            Text(dessert.name)
                                .font(.body)

                            Spacer()

                            Image(systemName: "arrow.right")
                                .frame(width: 15)
                                .aspectRatio(contentMode: .fit)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectedDessert = dessert
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .sheet(isPresented: $viewModel.isDetailPresented) {
            if let dessertDetails = viewModel.dessertDetails {
                DetailSheetView(details: dessertDetails, isPresented: $viewModel.isDetailPresented)
            }
        }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel){}
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred.")
        }
        .onAppear {
            Task {
                await viewModel.fetchDesserts()
            }
        }
    }
}

#Preview {
    ContentView()
}
