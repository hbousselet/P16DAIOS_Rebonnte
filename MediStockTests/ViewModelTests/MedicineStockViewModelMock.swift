//
//  MedicineStockViewModelMock.swift
//  MediStockTests
//
//  Created by Hugues BOUSSELET on 15/02/2026.
//

import Testing
@testable import MediStock
import Foundation

@Suite(.serialized)
struct MedicineStockViewModelTests {
    var mockService = FirestoreServiceMock()
    
    /// Helper pour attendre qu'une condition soit remplie avec timeout
    private func waitForCondition(
        timeout: UInt64 = 500_000_000, // 500ms
        checkInterval: UInt64 = 10_000_000, // 10ms
        condition: @escaping () -> Bool
    ) async {
        let maxAttempts = Int(timeout / checkInterval)
        var attempts = 0
        while !condition() && attempts < maxAttempts {
            try? await Task.sleep(nanoseconds: checkInterval)
            attempts += 1
        }
    }

    @Test func fetchMedicineOk() async throws {
        let medicine = Medicine(name: "Doliprano 12", stock: 12000, aisle: "Aisle 12", userId: "jeanCare")
        let viewModel = MedicineStockViewModel(firestoreService: mockService)
        mockService.shouldSuccess = true
        mockService.medistockInput = [medicine]
        
        await viewModel.fetchMedicines()
        await waitForCondition { !viewModel.medicines.isEmpty }
        
        #expect(viewModel.medicines.first == medicine)
    }

    @Test func fetchMedicineNOk() async throws {
        let viewModel = MedicineStockViewModel(firestoreService: mockService)
        mockService.shouldSuccess = false
        mockService.medistockInput = []
        mockService.error = .addListenerError("Error.")
        
        await viewModel.fetchMedicines()
        await waitForCondition { viewModel.presentAlertTabViews }
        
        #expect(viewModel.presentAlertTabViews)
        #expect(viewModel.alertTabViews == MedistockError.addListenerError("Error.").errorDescription)
    }

    @Test func fetchHistoryOk() async throws {
        let date = Date()
        let medicine = Medicine(id: "dhbjjhHDVGZV", name: "Doliprano 12", stock: 12000, aisle: "Aisle 12", userId: "jeanCare")
        let historyEntry = HistoryEntry(medicineId: medicine.id!, userId: "cvoucjsn", userEmail: "test@test.com", action: "operation", details: "Increased stock from 12 to 13", timestamp: date)
        let viewModel = MedicineStockViewModel(firestoreService: mockService)
        mockService.shouldSuccess = true
        mockService.medistockInput = [historyEntry]
        
        await viewModel.fetchHistory(for: medicine)
        await waitForCondition { !viewModel.history.isEmpty }
        
        #expect(viewModel.history.first?.medicineId == medicine.id)
        #expect(viewModel.history.first?.details == historyEntry.details)
    }

    @Test func fetchHistoryNOk() async throws {
        let viewModel = MedicineStockViewModel(firestoreService: mockService)
        let medicine = Medicine(id: "dhbjjhHDVGZV", name: "Doliprano 12", stock: 12000, aisle: "Aisle 12", userId: "jeanCare")
        mockService.shouldSuccess = false
        mockService.medistockInput = []
        mockService.error = .addListenerError("Error.")
        
        await viewModel.fetchHistory(for: medicine)
        await waitForCondition { viewModel.presentAlertDetailsView }
        
        #expect(viewModel.presentAlertDetailsView)
        #expect(viewModel.alertDetailsView == MedistockError.addListenerError("Error.").errorDescription)
    }

    @Test func createStockOk() async throws {
        let medicine = Medicine(id: "dhbjjhHDVGZV", name: "Doliprano 12", stock: 12000, aisle: "Aisle 12", userId: "jeanCare")
        let viewModel = MedicineStockViewModel(firestoreService: mockService)
        viewModel.user = User(uid: "ncjsbhbc737848", email: "test@letest.test")
        mockService.shouldSuccess = true
        mockService.medistockInput = [medicine]
        
        await viewModel.fetchMedicines()
        await waitForCondition { !viewModel.medicines.isEmpty }
        
        let medicineToAdd = Medicine(id: "dhbjZV", name: "Smecta 563", stock: 12321, aisle: "Aisle 61", userId: "jean Neymar")
        let result = await viewModel.createStock(for: medicineToAdd)
        
        #expect(result == true)
    }

    @Test func createStockNOkNoNumberInAisleName() async throws {
        let viewModel = MedicineStockViewModel(firestoreService: mockService)
        let medicine = Medicine(id: "dhbjjhHDVGZV", name: "Doliprano 12", stock: 12000, aisle: "Aisle", userId: "jeanCare")
        viewModel.user = User(uid: "ncjsbhbc737848", email: "test@letest.test")
        mockService.shouldSuccess = false
        mockService.medistockInput = []
        
        let result = await viewModel.createStock(for: medicine)
        
        #expect(result == false)
        #expect(viewModel.presentAlertDetailsView)
        #expect(viewModel.alertDetailsView == MedistockError.noNumberInAisleName.errorDescription)
    }

    @Test func createStockNOkEmptyMedicineName() async throws {
        let viewModel = MedicineStockViewModel(firestoreService: mockService)
        let medicine = Medicine(id: "dhbjjhHDVGZV", name: "", stock: 12000, aisle: "Aisle 12", userId: "jeanCare")
        viewModel.user = User(uid: "ncjsbhbc737848", email: "test@letest.test")
        mockService.shouldSuccess = false
        mockService.medistockInput = []
        
        let result = await viewModel.createStock(for: medicine)
        
        #expect(result == false)
        #expect(viewModel.presentAlertDetailsView)
        #expect(viewModel.alertDetailsView == MedistockError.emptyMedicineName.errorDescription)
    }

    @Test func createStockNOkEmptyStock() async throws {
        let viewModel = MedicineStockViewModel(firestoreService: mockService)
        let medicine = Medicine(id: "dhbjjhHDVGZV", name: "Doliprano", stock: 0, aisle: "Aisle 12", userId: "jeanCare")
        viewModel.user = User(uid: "ncjsbhbc737848", email: "test@letest.test")
        mockService.shouldSuccess = false
        mockService.medistockInput = []
        
        let result = await viewModel.createStock(for: medicine)
        
        #expect(result == false)
        #expect(viewModel.presentAlertDetailsView)
        #expect(viewModel.alertDetailsView == MedistockError.emptyStockMedicineCreation.errorDescription)
    }

    @Test func createStockNOkAlreadyExists() async throws {
        let viewModel = MedicineStockViewModel(firestoreService: mockService)
        let medicine = Medicine(id: "dhbjjhHDVGZV", name: "Doliprano 12", stock: 12000, aisle: "Aisle 12", userId: "jeanCare")
        mockService.shouldSuccess = true
        mockService.medistockInput = [medicine]
        
        await viewModel.fetchMedicines()
        await waitForCondition { !viewModel.medicines.isEmpty }
        
        let result = await viewModel.createStock(for: medicine)
        
        #expect(result == false)
        #expect(viewModel.presentAlertDetailsView)
        #expect(viewModel.alertDetailsView == MedistockError.alreadyExists.errorDescription)
    }

    @Test func createStockNOk() async throws {
        let viewModel = MedicineStockViewModel(firestoreService: mockService)
        let medicine = Medicine(id: "dhbjjhHDVGZV", name: "Doliprano 12", stock: 12000, aisle: "Aisle 12", userId: "jeanCare")
        viewModel.user = User(uid: "ncjsbhbc737848", email: "test@letest.test")
        mockService.shouldSuccess = false
        mockService.medistockInput = []

        let result = await viewModel.createStock(for: medicine)

        #expect(result == false)
        #expect(viewModel.presentAlertDetailsView)
        #expect(viewModel.alertDetailsView == MedistockError.createError("error while creating.").errorDescription)
    }

    @Test func createStockNOkPrepareHistoryNoUser() async throws {
        let viewModel = MedicineStockViewModel(firestoreService: mockService)
        let medicine = Medicine(id: "dhbjjhHDVGZV", name: "Doliprano 12", stock: 12000, aisle: "Aisle 12", userId: "jeanCare")
        mockService.shouldSuccess = true
        mockService.medistockInput = []

        let result = await viewModel.createStock(for: medicine)

        #expect(result == false)
    }

    @Test func deleteMedicineOk() async throws {
        let medicine = Medicine(id: "dhbjjhHDVGZV", name: "Doliprano 12", stock: 12000, aisle: "Aisle 12", userId: "jeanCare")
        let viewModel = MedicineStockViewModel(firestoreService: mockService)
        viewModel.user = User(uid: "ncjsbhbc737848", email: "test@letest.test")
        viewModel.medicines = [medicine]
        mockService.shouldSuccess = true

        await viewModel.deleteMedicines(for: 0)
        #expect(viewModel.presentAlertTabViews == false)
    }

    @Test func deleteMedicineOkWithAilse() async throws {
        let medicines = [Medicine(id: "dhbjjhHDVGZV", name: "Doliprano 12", stock: 12000, aisle: "Aisle 12", userId: "jeanCare"), Medicine(id: "dhxsx23GZV", name: "Smecta 3000", stock: 1200, aisle: "Aisle 1", userId: "jeanNeymar")]
        let viewModel = MedicineStockViewModel(firestoreService: mockService)
        viewModel.user = User(uid: "ncjsbhbc737848", email: "test@letest.test")
        viewModel.medicines = medicines
        mockService.shouldSuccess = true

        await viewModel.deleteMedicines(for: 0, and: "Aisle 1")
        #expect(viewModel.presentAlertTabViews == false)
    }

    @Test func deleteMedicineNOk() async throws {
        let medicine = Medicine(id: "dhbjjhHDVGZV", name: "Doliprano 12", stock: 12000, aisle: "Aisle 12", userId: "jeanCare")
        mockService.shouldSuccess = false
        let viewModel = MedicineStockViewModel(firestoreService: mockService)
        viewModel.user = User(uid: "ncjsbhbc737848", email: "test@letest.test")
        viewModel.medicines = [medicine]

        await viewModel.deleteMedicines(for: 0)
        #expect(viewModel.presentAlertTabViews)
        #expect(viewModel.alertTabViews == MedistockError.deleteError("error while deleting.").errorDescription)
    }


    @Test func updateStockOk() async throws {
        let medicine = Medicine(id: "dhbjjhHDVGZV", name: "Doliprano 12", stock: 12000, aisle: "Aisle 12", userId: "jeanCare")
        let viewModel = MedicineStockViewModel(firestoreService: mockService)
        viewModel.user = User(uid: "ncjsbhbc737848", email: "test@letest.test")
        mockService.shouldSuccess = true
        mockService.medistockInput = [medicine]

        await viewModel.fetchMedicines()
        await waitForCondition { !viewModel.medicines.isEmpty }

        await viewModel.updateStock(by: 1, for: medicine)
        #expect(viewModel.presentAlertTabViews == false)
    }

    @Test func updateStockNOk() async throws {
        let medicine = Medicine(id: "dhbjjhHDVGZV", name: "Doliprano 12", stock: 12000, aisle: "Aisle 12", userId: "jeanCare")
        let viewModel = MedicineStockViewModel(firestoreService: mockService)
        viewModel.user = User(uid: "ncjsbhbc737848", email: "test@letest.test")
        viewModel.medicines = [medicine]
        mockService.shouldSuccess = false
        mockService.medistockInput = [medicine]

        await viewModel.updateStock(by: 1, for: medicine)
        #expect(viewModel.presentAlertDetailsView)
        #expect(viewModel.alertDetailsView == MedistockError.updateError("error while updating.").errorDescription)
    }

    @Test func filterMedicineByNameWithFilterInfo() async throws {
        let medicines = [Medicine(id: "dhbjjhHDVGZV", name: "Doliprane 12", stock: 12000, aisle: "Aisle 12", userId: "jeanCare"), Medicine(id: "dhxsx23GZV", name: "Smecta 3000", stock: 1200, aisle: "Aisle 1", userId: "jeanNeymar")]
        let viewModel = MedicineStockViewModel(firestoreService: mockService)
        viewModel.user = User(uid: "ncjsbhbc737848", email: "test@letest.test")
        mockService.shouldSuccess = true
        mockService.medistockInput = medicines

        await viewModel.fetchMedicines()
        await waitForCondition { !viewModel.medicines.isEmpty }

        let medicineFilteredByName = viewModel.filterAndSortMedicines(filterText: "Doliprane", sortOption: .name)
        #expect(medicineFilteredByName.count == 1)
        #expect(medicineFilteredByName[0].stock == 12000)
        #expect(medicineFilteredByName[0].name == "Doliprane 12")
    }

    @Test func filterMedicineByNameWithoutFilterInfo() async throws {
        let medicines = [Medicine(id: "dhbjjhHDVGZV", name: "Doliprane 12", stock: 12000, aisle: "Aisle 12", userId: "jeanCare"), Medicine(id: "dhxsx23GZV", name: "Smecta 3000", stock: 1200, aisle: "Aisle 1", userId: "jeanNeymar")]
        let viewModel = MedicineStockViewModel(firestoreService: mockService)
        viewModel.user = User(uid: "ncjsbhbc737848", email: "test@letest.test")
        mockService.shouldSuccess = true
        mockService.medistockInput = medicines

        await viewModel.fetchMedicines()
        await waitForCondition { !viewModel.medicines.isEmpty }

        let medicineFilteredByName = viewModel.filterAndSortMedicines(filterText: "", sortOption: .name)
        #expect(medicineFilteredByName.count == 2)
        #expect(medicineFilteredByName[0].stock == 12000)
        #expect(medicineFilteredByName[0].name == "Doliprane 12")
    }

    @Test func filterMedicineByStock() async throws {
        let medicines = [Medicine(id: "dhbjjhHDVGZV", name: "Doliprane 12", stock: 12000, aisle: "Aisle 12", userId: "jeanCare"), Medicine(id: "dhxsx23GZV", name: "Smecta 3000", stock: 1200, aisle: "Aisle 1", userId: "jeanNeymar")]
        let viewModel = MedicineStockViewModel(firestoreService: mockService)
        viewModel.user = User(uid: "ncjsbhbc737848", email: "test@letest.test")
        mockService.shouldSuccess = true
        mockService.medistockInput = medicines

        await viewModel.fetchMedicines()
        await waitForCondition { !viewModel.medicines.isEmpty }

        let medicineFilteredByName = viewModel.filterAndSortMedicines(filterText: "", sortOption: .stock)
        #expect(medicineFilteredByName.count == 2)
        #expect(medicineFilteredByName[0].stock == 1200)
        #expect(medicineFilteredByName[0].name == "Smecta 3000")
        #expect(medicineFilteredByName[1].stock == 12000)
        #expect(medicineFilteredByName[1].name == "Doliprane 12")
    }

}
