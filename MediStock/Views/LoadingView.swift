//
//  LoadingView.swift
//  MediStock
//
//  Created by Hugues BOUSSELET on 02/02/2026.
//

import SwiftUI

struct LoadingView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            Rectangle()
                .fill(colorScheme == .light ? .gray.opacity(0.7) : .white)
                .opacity(0.75)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                Text("Loading...")
            }
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorScheme == .light ? .white : .black)
                .frame(width: 200, height: 200)
            }
            .offset(y: -70)
        }
    }
}
