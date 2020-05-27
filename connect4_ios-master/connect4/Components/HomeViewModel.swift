//
//  HomeViewModel.swift
//  connect4
//
//  Created by Nanway Chen on 29/12/19.
//  Copyright © 2019 Nanway Chen. All rights reserved.
//

import Foundation
import UIKit

// Player name to file info

class HomeViewModel : NSObject {
    // Table items
    var items = [
        ItemType(label: "Player One", type: .playerType),
        ItemType(label: "Player Two", type: .playerType),
        ItemType(label: "Player One RNG", type: .randomness, visible: false),
        ItemType(label: "Player Two RNG", type: .randomness, visible: false)
    ]
    
    // Hardcoded for now, but in future this should read from a JSON
    // and generate players
    
    // Picker Items
    let redPlayerTypePickerItems : [GameType] = DataModel.getDataModel().redGameTypes
    let bluPlayerTypePickerItems : [GameType] = DataModel.getDataModel().bluGameTypes
    let randomnessPickerItems = Array(0...100)
    
    // Plyer settings
    
    
    var gameConfig : [(GameType, Int)] = [(.Human, 0), (.Human, 0)]
    
    override init() {
        super.init()
    }
    
    func selectRedPlayerType(_ selected : Int, tag : Int) {
        gameConfig[tag].0 = redPlayerTypePickerItems[selected]
        let relatedIndex = tag == 0 ? 2 : 3
        switch redPlayerTypePickerItems[selected] {
        case .AI(_):
            items[relatedIndex].visible = true
        default:
            items[relatedIndex].visible = false
        }
    }

    func selectBluPlayerType(_ selected : Int, tag : Int) {
        gameConfig[tag].0 = bluPlayerTypePickerItems[selected]
        let relatedIndex = tag == 0 ? 2 : 3
        switch bluPlayerTypePickerItems[selected] {
        case .AI(_):
            items[relatedIndex].visible = true
        default:
            items[relatedIndex].visible = false
        }
    }
    
    func selectRandomness(_ selected : Int, tag : Int) {
        gameConfig[tag - 2].1 = randomnessPickerItems[selected]
    }
}

enum CellType {
    case playerType
    case randomness
}

struct ItemType : Hashable {
    var label : String
    var type : CellType
    var visible : Bool?
}
