//
//  ViewController.swift
//  ios-cw-5-p2
//
//  Created by ghadeer alqattan on 6/27/20.
//  Copyright © 2020 GeeCodes. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class ViewController: UIViewController {

    @IBOutlet weak var ticTacToe: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var playerScoreLabel: UILabel!
    @IBOutlet weak var computerScoreLabel: UILabel!
    @IBOutlet weak var b1: UIImageView!
    @IBOutlet weak var b2: UIImageView!
    @IBOutlet weak var b3: UIImageView!
    @IBOutlet weak var b4: UIImageView!
    @IBOutlet weak var b5: UIImageView!
    @IBOutlet weak var b6: UIImageView!
    @IBOutlet weak var b7: UIImageView!
    @IBOutlet weak var b8: UIImageView!
    @IBOutlet weak var b9: UIImageView!
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func btnchange(_ sender: UIButton) {
        
        imageView.image = UIImage(named: "second")
    }
    
    var player: AVAudioPlayer?
    
    @IBAction func didTapButton(_ sender: Any) {
        if let player = player, player.isPlaying{
            // stop playback
            player.stop()
        }
        else{
            // set up player, and play

            let urlString = Bundle.main.path(forResource: "tom-jerry", ofType: "mp3")
            do {
                try AVAudioSession.sharedInstance().setMode(.default)
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                guard let urlString = urlString else {
                    return
                }
                player = try AVAudioPlayer (contentsOf: URL(fileURLWithPath: urlString))
                guard let player = player else {
                    return
                }
                player.play()
            }
            catch {
                print("something went wrong")
            }
        }
    }
    
    @IBAction func reset(_ sender: Any) {
       resetGame()

    }
    var lastValue = "o"
    
    var playerChoices: [Box] = []
    var computerChoices: [Box] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTap(on: b1, type: .one)
        createTap(on: b2, type: .two)
        createTap(on: b3, type: .three)
        createTap(on: b4, type: .four)
        createTap(on: b5, type: .five)
        createTap(on: b6, type: .six)
        createTap(on: b7, type: .seven)
        createTap(on: b8, type: .eight)
        createTap(on: b9, type: .nine)

    }
    func getBox(from name: String) -> UIImageView{
        let box = Box(rawValue: name) ?? .one
        switch box {
        case .one:
            return b1
        case .two:
            return b2
        case .three:
            return b3
        case .four:
            return b4
        case .five:
            return b5
        case .six:
            return b6
        case .seven:
            return b7
        case .eight:
            return b8
        case .nine:
            return b9
        }
    }
    
    enum Box: String, CaseIterable{
        case one, two, three, four, five, six, seven, eight, nine
    }
   
    func checkWinner() {
        var correct = [[Box]]()
        let firstRow: [Box] = [.one, .two, .three]
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {}
        let secondRow: [Box] = [.four, .five, .six]
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {}
        let thirdRow: [Box] = [.seven, .eight, .nine]
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {}
        
        let firstCol: [Box] = [.one, .four, .seven]
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {}
        let secondCol: [Box] = [.two, .five, .eight]
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {}
        let thirdCol: [Box] = [.three, .six, .nine]
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {}
        let backwardSlash: [Box] = [.one, .five, .nine]
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {}
        let forwardSlash: [Box] = [.three, .five, .seven]
        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {}
        
        correct.append(firstRow)
        correct.append(secondRow)
        correct.append(thirdRow)
        correct.append(firstCol)
        correct.append(secondCol)
        correct.append(thirdCol)
        correct.append(backwardSlash)
        correct.append(forwardSlash)
        
        for valid in correct {
            let userMatch = playerChoices.filter { valid.contains($0) }.count
            let computerMatch = computerChoices.filter { valid.contains($0) }.count
            
            
            if userMatch == valid.count {
                playerScoreLabel.text = String((Int(playerScoreLabel.text ?? "0") ?? 0) + 1)
                resetGame()
                break
                
            } else if computerMatch == valid.count{
                computerScoreLabel.text = String((Int(computerScoreLabel.text ?? "0") ?? 0) + 1)
                
                resetGame()
                break
            } else if computerChoices.count + playerChoices.count == 9 {
            resetGame()
                break
                
            }
        }
    }
    
    func resetGame() {
               for name in Box.allCases {
                   let box = getBox(from: name.rawValue)
                   box.image = nil
                   lastValue = "o"
                   playerChoices = []
                   computerChoices = []
           }
               
       }
    
    func createTap(on imageView: UIImageView, type box: Box){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.boxClicked(_:)))
        tap.name = box.rawValue
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
    }
    @objc func boxClicked(_ sender: UITapGestureRecognizer){
        let selectedBox = getBox(from: sender.name ?? "")
        makeChoice(selectedBox)
        playerChoices.append(Box(rawValue: sender.name!)!)
        checkWinner()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.computerPlay()
        }
    }
    func computerPlay() {
        var availableSpaces = [UIImageView] ()
        var availableBoxes = [Box]()
        
        for name in Box.allCases {
            let box = getBox(from: name.rawValue)
            if box.image == nil {
                availableSpaces.append(box)
                availableBoxes.append(name)
            }
        }
        guard availableBoxes.count > 0 else
        { return }
        
        let randIndex = Int.random(in: 0 ..< availableSpaces.count)
        makeChoice(availableSpaces[randIndex])
        computerChoices.append(availableBoxes[randIndex])
        checkWinner()
    }
    
    func makeChoice(_ selectedBox: UIImageView) {
        
        guard selectedBox.image == nil else { return }
        if lastValue == "x" {
            selectedBox.image = #imageLiteral(resourceName: "tom")
            lastValue = "o"
        
        } else {
            selectedBox.image = #imageLiteral(resourceName: "jerry")
            lastValue = "x"
        }
    }
    func vibrate() {
    AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {}
}
    
}
