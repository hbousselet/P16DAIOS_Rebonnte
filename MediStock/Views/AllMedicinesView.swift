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
                            NavigationLink(destination: MedicineDetailView(medicine: medicine,viewModel: viewModel)) {
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
                        MedicineDetailView(medicine: Medicine.createNewStock(for: viewModel.user as? User), viewModel: viewModel, isCreatingNewStock: true)
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
            Task(priority: .userInitiated) {
                await viewModel.deleteMedicines(for: index)
            }
        }
    }

    var filteredAndSortedMedicines: [Medicine] {
        viewModel.filterAndSortMedicines(filterText: filterText, sortOption: sortOption)
    }
}
