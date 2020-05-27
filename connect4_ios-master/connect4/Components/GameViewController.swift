//
//  GameViewController.swift
//  connect4
//
//  Created by Nanway Chen on 22/12/19.
//  Copyright © 2019 Nanway Chen. All rights reserved.
//

import UIKit
import Cheers

class GameViewController: UIViewController {

    @IBOutlet weak var gameBoard: UIStackView!
    @IBOutlet weak var playerTurnLabel: UILabel!
    @IBOutlet var playerTurnImage: UIImageView!
    @IBOutlet weak var resetButton: UIButton!
    
    var playerSettings : [(GameType, Int)] = []
    
    private var columns: [UIStackView]! = []
    private var viewModel : GameViewModel!
    private var cheerView = CheerView()
    private var chips : [UIImageView]! = []
    private var chipImages : [Color : UIImage] = [Color.red : #imageLiteral(resourceName: "redTile"), Color.blu : #imageLiteral(resourceName: "yellowTile")]
    private var isReset : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = GameViewModel(config: playerSettings)
        viewModel.delegate = self
        
        initialiseBoardViews()
        
        cheerView.config.particle = .confetti(allowedShapes: Particle.ConfettiShape.all)
        
        resetButton.layer.cornerRadius = Style.buttonCornerRadius
        
        playerTurnLabel.font = Style.gameLabelFont
        updatePlayerTurnImage()
    }
    
    private func updatePlayerTurnImage() {
        let resizedImg = chipImages[viewModel.playerTurn]?.resizedImage(newSize: playerTurnImage.frame.size)
        playerTurnImage.image = resizedImg
    }
    
    private func initialiseBoardViews() {
        for col in 0 ..< viewModel.width {
            let columnView = UIStackView()
            columnView.axis = .vertical
            columnView.distribution = .fillEqually
            columnView.translatesAutoresizingMaskIntoConstraints = false
            columnView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
            columnView.tag = col
            for _ in 0 ..< viewModel.height {
                let gridTile = #imageLiteral(resourceName: "gridTile")
                columnView.addArrangedSubview(UIImageView(image: gridTile))
            }
            columns.append(columnView)
            gameBoard.addArrangedSubview(columnView)

        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let columnView = sender?.view as! UIStackView? else {
            return
        }
        
        let action = columnView.tag
        
        guard viewModel.awaitingPlayerMove else {
            return
        }

        guard viewModel.playMove(action) else {
            return
        }
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        if (isReset) {
            viewModel.gameReset()
        } else {
            viewModel.gameStart()
        }
        isReset = !isReset

    }
}

extension GameViewController : GameViewModelDelegate {
    func gameViewModelDraw() {
        playerTurnLabel.text = "Draw!"
        view.addSubview(cheerView)
        cheerView.center = CGPoint(x: view.frame.width/2, y: 0)
        cheerView.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.cheerView.stop()
            self.resetButton.setBackgroundImage(UIImage(systemName: "gobackward"), for: .normal)
            self.resetButton.isHidden = false
            UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                self.resetButton.alpha = 1.0 // Here you will get the animation you want
            }, completion: { _ in
                self.resetButton.isHidden = false // Here you hide it when animation done
            })
        }
    }
    
    func gameViewModel(player: Color, playedMove: Int) {
        let column = columns[playedMove]
        let height = column.frame.height
        let width = column.frame.width
        
        let row = CGFloat(column.subviews.count - viewModel.height)
        let x = width/2
        let cellHeight = height/CGFloat(viewModel.height)
        let y = height - (cellHeight)/2 - row*cellHeight
        
        var chipImg = chipImages[player]
        chipImg = chipImg!.resizedImage(newSize: CGSize(width: width, height: height/CGFloat(viewModel.height)))
        let chipImgView = UIImageView(image: chipImg)
        chips.append(chipImgView)
        chipImgView.center = CGPoint(x: x, y: 0)
        column.addSubview(chipImgView)
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.80,
                       initialSpringVelocity: 1,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: ({
                        chipImgView.center = CGPoint(x: x, y: y)
                        }),
                        completion: nil)
        updatePlayerTurnImage()
    }
    
    func gameViewModelStart() {
        UIView.animate(withDuration: 0.1, delay: 0, options: [], animations: {
            self.resetButton.alpha = 0 // Here you will get the animation you want
        }, completion: { _ in
            self.resetButton.isHidden = true
        })
    }
    
    func gameViewModelReset() {
        for chip in chips {
            chip.removeFromSuperview()
        }
        UIView.animate(withDuration: 0.1, delay: 0, options: [], animations: {
            self.resetButton.alpha = 0 // Here you will get the animation you want
        }, completion: { _ in
            self.playerTurnLabel.text = "Turn:"
            self.updatePlayerTurnImage()
            
            self.resetButton.setBackgroundImage(UIImage(systemName: "play"), for: .normal)
            
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                self.resetButton.alpha = 1 // Here you will get the animation you want
            }, completion: { _ in
                self.playerTurnLabel.text = "Turn:"
                self.updatePlayerTurnImage()
            })
        })
    }
    
    func gameViewModel(wonGame: Color) {
        playerTurnLabel.text = "Winner:"
        view.addSubview(cheerView)
        cheerView.center = CGPoint(x: view.frame.width/2, y: 0)
        cheerView.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.cheerView.stop()
            self.resetButton.setBackgroundImage(UIImage(systemName: "gobackward"), for: .normal)
            self.resetButton.isHidden = false
            UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                self.resetButton.alpha = 1.0 // Here you will get the animation you want
            }, completion: { _ in
                self.resetButton.isHidden = false // Here you hide it when animation done
            })
        }
    }
    
    
}

extension UIImage {
    /// Returns a image that fills in newSize
    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
}
