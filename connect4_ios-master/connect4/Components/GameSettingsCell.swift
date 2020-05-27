//
//  GameSettingsCell.swift
//  connect4
//
//  Created by Nanway Chen on 25/12/19.
//  Copyright © 2019 Nanway Chen. All rights reserved.
//

import UIKit

class GameSettingsCell: UITableViewCell {

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var cellLabel: UILabel!
    
    static let identifier = "GameSettingsCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellLabel.font = Style.mainFont
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
