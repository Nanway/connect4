//
//  Style.swift
//  connect4
//
//  Created by Nanway Chen on 25/12/19.
//  Copyright © 2019 Nanway Chen. All rights reserved.
//

import Foundation
import UIKit

struct Style {
    static let fontDescriptor = UIFontDescriptor(name: "American Typewriter", size: Style.mainFontSize)
    static let mainFont : UIFont = UIFont(descriptor: fontDescriptor, size: Style.mainFontSize)
    
    static let gameLabelFont = UIFont(descriptor: fontDescriptor, size: gameFontSize)
    
    static let mainFontSize = CGFloat(20)
    static let gameFontSize = CGFloat(36)
    
    static let buttonCornerRadius = CGFloat(7.5)
    
}
