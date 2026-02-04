//
//  Extensions.swift
//  MediStock
//
//  Created by Hugues BOUSSELET on 04/02/2026.
//

import Foundation


public extension String {
    func containsANumber() -> Bool {
        range(of: "[0-9]", options: .regularExpression) != nil
    }
}

