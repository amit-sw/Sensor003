//
//  ViewController.swift
//  Sensor003
//
//  Created by Amit Gupta on 3/2/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var displayLabel: UILabel!
    
    @IBOutlet weak var buttonOne: UIButton!
    
    @IBOutlet weak var buttonTwo: UIButton!
    
    @IBOutlet weak var buttonThree: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("ViewController viewDidLoad")
        fixupUI()
    }

    @IBAction func buttonOnePressed(_ sender: Any) {
        print("Button one pressed")
        appDelegate().aranet4Manager.updateAranet4Interval(2);
        print("DONE: Button one pressed")
    }
    
    @IBAction func buttonTwoPressed(_ sender: Any) {
        print("Button two pressed")
        appDelegate().aranet4Manager.updateAranet4Interval(5);
        
    }
    
    
    @IBAction func buttonThreePressed(_ sender: Any) {
        print("Button three pressed")
    }
    
    func fixupUI() {
        displayLabel.text="No changes yet"
        buttonOne.setTitle("Two minutes", for: .normal)
        buttonTwo.setTitle("Five minutes", for: .normal)
        buttonThree.setTitle("Get history", for: .normal)
        
        buttonOne.backgroundColor = .clear
        buttonOne.layer.cornerRadius = 25
        buttonOne.layer.borderWidth = 1
        buttonOne.layer.borderColor = UIColor.black.cgColor
        buttonOne.backgroundColor = UIColor.blue
        buttonOne.setTitleColor(UIColor.white, for: UIControl.State.normal)
        
        buttonTwo.backgroundColor = .clear
        buttonTwo.layer.cornerRadius = 25
        buttonTwo.layer.borderWidth = 1
        buttonTwo.layer.borderColor = UIColor.black.cgColor
        buttonTwo.backgroundColor = UIColor.blue
        buttonTwo.setTitleColor(UIColor.white, for: UIControl.State.normal)
        
        buttonThree.backgroundColor = .clear
        buttonThree.layer.cornerRadius = 25
        buttonThree.layer.borderWidth = 1
        buttonThree.layer.borderColor = UIColor.black.cgColor
        buttonThree.backgroundColor = UIColor.blue
        buttonThree.setTitleColor(UIColor.white, for: UIControl.State.normal)
    }
    
    func appDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
}

