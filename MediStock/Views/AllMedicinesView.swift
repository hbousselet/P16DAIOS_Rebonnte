import SwiftUI

struct AllMedicinesView: View {
    @Environment(MedicineStockViewModel.self) private var viewModel
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
                            NavigationLink(destination: MedicineDetailView(medicine: medicine)) {
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
                        MedicineDetailView(medicine: Medicine.createNewStock(for: viewModel.session?.session), isCreatingNewStock: true)
                    }
                }
            }
        }
    }

    private func removeMedicine(offsets: IndexSet) {
        offsets.forEach { index in
            let id = viewModel.medicines[index].id
            Task(priority: .background) {
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

struct AllMedicinesView_Previews: PreviewProvider {
    static var previews: some View {
        AllMedicinesView()
    }
}
