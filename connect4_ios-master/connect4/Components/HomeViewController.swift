//
//  HomeViewController.swift
//  connect4
//
//  Created by Nanway Chen on 24/12/19.
//  Copyright © 2019 Nanway Chen. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var settingsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var settingsTableView: UITableView!
    
    let viewModel = HomeViewModel()
    var redPlayerTypePickerDelegate : PickerViewDelegate<GameType>?
    var bluPlayerTypePickerDelegate : PickerViewDelegate<GameType>?
    var randomnessPickerDelegate : PickerViewDelegate<Int>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        
        let nib = UINib(nibName: "GameSettingsCell", bundle: nil)
        settingsTableView.register(nib, forCellReuseIdentifier: "GameSettingsCell")
        
        playButton.layer.cornerRadius = Style.buttonCornerRadius
        
        redPlayerTypePickerDelegate = PickerViewDelegate(pickerItems: viewModel.redPlayerTypePickerItems, onSelect: selectedRedPlayerType(selected:tag:))
        
        bluPlayerTypePickerDelegate = PickerViewDelegate(pickerItems: viewModel.bluPlayerTypePickerItems, onSelect: selectedBluPlayerType(selected:tag:))
        
        randomnessPickerDelegate = PickerViewDelegate(pickerItems: viewModel.randomnessPickerItems, onSelect: viewModel.selectRandomness(_:tag:))
    }
    
    private func selectedRedPlayerType(selected: Int, tag : Int) {
        viewModel.selectRedPlayerType(selected, tag: tag)
        settingsTableView.reloadData()
    }

    private func selectedBluPlayerType(selected: Int, tag : Int) {
        viewModel.selectBluPlayerType(selected, tag: tag)
        settingsTableView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? GameViewController {
            destination.playerSettings = viewModel.gameConfig
        }
    }
}

extension HomeViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GameSettingsCell.identifier, for: indexPath) as? GameSettingsCell else {
            fatalError("dafuq")
        }
        
        cell.pickerView.tag = indexPath.row
        cell.cellLabel.text = viewModel.items[indexPath.row].label
        switch viewModel.items[indexPath.row].type {
        case .playerType:
            if (indexPath.row == 0) {
                cell.pickerView.delegate = redPlayerTypePickerDelegate
                cell.pickerView.dataSource = redPlayerTypePickerDelegate
            } else {
                cell.pickerView.delegate = bluPlayerTypePickerDelegate
                cell.pickerView.dataSource = bluPlayerTypePickerDelegate
            }

        case .randomness:
            cell.pickerView.delegate = randomnessPickerDelegate
            cell.pickerView.dataSource = randomnessPickerDelegate
            if let enabled = viewModel.items[indexPath.row].visible {
                cell.isHidden = !enabled
            } else {
                cell.isHidden = true
            }
        }
        return cell
    }
}

final class PickerViewDelegate<T : CustomStringConvertible> : NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    var pickerItems : Array<T>
    var onSelect : (Int, Int) -> Void
    
    init(pickerItems : Array<T>, onSelect : @escaping (Int, Int) -> Void) {
        self.pickerItems = pickerItems
        self.onSelect = onSelect
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerItems.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel;

        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            pickerLabel?.font = Style.mainFont
            pickerLabel?.textAlignment = NSTextAlignment.center
        }

        pickerLabel?.text = String(describing: pickerItems[row])
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        onSelect(row, pickerView.tag)
    }
}
