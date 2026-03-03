//
//  AlertViewModifier.swift
//  MediStock
//
//  Created by Hugues BOUSSELET on 14/02/2026.
//

import SwiftUI

struct AlertViewModifier: ViewModifier {
    @Binding var presentAlert: Bool
    @Binding var alertMessage: String?
    var needSecondButton: Bool = false
    var removeAlert: (() -> Void)?
    var secondButtonAction: (() async -> Void)?
    func body(content: Content) -> some View {
        content
            .alert("Alert !", isPresented: $presentAlert, actions: {
                Button("OK") {
                    removeAlert?()
                }
                if needSecondButton {
                    Button("Retry") {
                        removeAlert?()
                    }
                }
            }, message: {
                if let error = alertMessage {
                    Text(error)
                } else {
                    Text("Unknown Error")
                }
            })
    }
}

extension View {
    func customAlert(presentAlert: Binding<Bool>, alertMessage: Binding<String?>, needSecondButton: Bool = false, removeAlert: (() -> Void)? = nil, secondButtonAction: (() async -> Void)? = nil) -> some View {
        modifier(AlertViewModifier(presentAlert: presentAlert, alertMessage: alertMessage, needSecondButton: needSecondButton, removeAlert: removeAlert, secondButtonAction: secondButtonAction))
    }
}
