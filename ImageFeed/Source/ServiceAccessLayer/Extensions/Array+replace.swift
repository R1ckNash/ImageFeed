//
//  Array+replace.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 19/12/2024.
//

import Foundation

extension Array {
    
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        guard indices.contains(index) else {
            assertionFailure("Index out of bounds: \(index)")
            return self
        }
        
        var newArray = self
        newArray[index] = newValue
        return newArray
    }
}
