//
//  Item.swift
//  Nasseq
//
//  Created by Ahmed on 25/08/1447 AH.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
