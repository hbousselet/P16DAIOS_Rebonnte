import SwiftUI

struct AllMedicinesView: View {
    @State var viewModel: MedicineStockViewModel
    @State private var filterText: String = ""
    @State private var sortOption: SortOption = .none
    @State private var showNewStockPage: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.showLoading {
                    LoadingView()
                        .zIndex(1)
                }
                VStack {
                    HStack {
                        TextField("Filter by name", text: $filterText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading, 10)
                        
                        Spacer()
                        
                        Picker("Sort by", selection: $sortOption) {
                            Text("None").tag(SortOption.none)
                            Text("Name").tag(SortOption.name)
                            Text("Stock").tag(SortOption.stock)
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.trailing, 10)
                    }
                    .padding(.top, 10)
                    
                    List {
                        ForEach(filteredAndSortedMedicines, id: \.id) { medicine in
                            NavigationLink(destination: MedicineDetailView(index: viewModel.medicines.firstIndex(where: { $0.id == medicine.id }),
                                                                           viewModel: viewModel)) {
                                VStack(alignment: .leading) {
                                    Text(medicine.name)
                                        .font(.headline)
                                    Text("Stock: \(medicine.stock)")
                                        .font(.subheadline)
                                }
                            }
                        }
                        .onDelete(perform: removeMedicine)
                    }
                    .navigationBarTitle("All Medicines")
                    .navigationBarItems(trailing: Button(action: {
                        showNewStockPage.toggle()
                    }) {
                        Image(systemName: "plus")
                    })
                    .navigationDestination(isPresented: $showNewStockPage) {
                        MedicineDetailView(viewModel: viewModel,
                                           isCreatingNewStock: true)
                    }
                    .alert("Alert !", isPresented: $viewModel.presentAlertTabViews, actions: {
                        Button("OK") { }
                        Button("Retry fetch") {
                            Task(priority: .userInitiated) {
                                await viewModel.fetchMedicines()
                            }
                        }
                    }, message: {
                        if let error = viewModel.alertTabViews {
                            Text(error)
                        } else {
                            Text("Unknown Error")
                        }
                    })
                }
            }
        }
    }

    private func removeMedicine(offsets: IndexSet) {
        offsets.forEach { index in
            let id = viewModel.medicines[index].id
            Task(priority: .userInitiated) {
                await viewModel.deleteMedicines(id: id)
            }
        }
    }

    var filteredAndSortedMedicines: [Medicine] {
        var medicines = viewModel.medicines

        if !filterText.isEmpty {
            medicines = medicines.filter { $0.name.lowercased().contains(filterText.lowercased()) }
        }

        switch sortOption {
        case .name:
            medicines.sort { $0.name.lowercased() < $1.name.lowercased() }
        case .stock:
            medicines.sort { $0.stock < $1.stock }
        case .none:
            break
        }

        return medicines
    }
}

enum SortOption: String, CaseIterable, Identifiable {
    case none
    case name
    case stock

    var id: String { self.rawValue }
}
