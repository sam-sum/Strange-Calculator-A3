//
//  MAPD714 F22
//  Assignment 3
//  Group 8
//  Member: Suen, Chun Fung (Alan) 301277969
//          Sum, Chi Hung (Samuel) 300858503
//          Wong, Po Lam (Lizolet) 301258847
//  Date:   Oct 23, 2022
//
//  ViewController.swift
//  Strange Calculator - A simple calculator with a strange key layout
//  Version 0.5
//

import UIKit

class LeftHandViewController: UIViewController {

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    
    let maxStepsChar = 33
    let maxCharInLine = 11

    override func viewDidLoad() {
        super.viewDidLoad()
        resultLabel.text = Calculation.shared.getResult()
        stepsLabel.text = Calculation.shared.getSteps(maxStepsChar)
    }
    
    @IBAction func btnDown(_ sender: UIButton) {
        sender.backgroundColor = UIColor.white
    }

    @IBAction func btnUpOutside(_ sender: UIButton) {
        sender.backgroundColor = UIColor.clear
    }
    
    @IBAction func btnNumbersUpInside(_ sender: UIButton) {
        sender.backgroundColor = UIColor.clear
        let keyText = sender.titleLabel?.text ?? ""
        let (steps, result) = Calculation.shared.handleNumberInput(inNum: keyText, outChar: maxStepsChar)
        stepsLabel.text = steps
        resultLabel.text = result
        alignLabelText()
    }
    
    @IBAction func btnOperatorsUpInside(_ sender: UIButton) {
        sender.backgroundColor = UIColor.clear
        let keyText = sender.titleLabel?.text ?? ""
        let (steps, result) = Calculation.shared.handleOperaters(inKey: keyText, outChar: maxStepsChar)
        stepsLabel.text = steps
        resultLabel.text = result
        alignLabelText()
    }
    
    @IBAction func btnSpecialUpInside(_ sender: UIButton) {
        sender.backgroundColor = UIColor.clear
        let keyText = sender.titleLabel?.text ?? ""
        let (steps, result) = Calculation.shared.handleSpecialKeys(inKey: keyText, outChar: maxStepsChar)
        stepsLabel.text = steps
        resultLabel.text = result
        alignLabelText()
    }

    // *****
    // Right-align the label text if it can be shown in 1 line. Otherwise, make it left-algn.
    // *****
    private func alignLabelText() {
        if stepsLabel.text?.count ?? 0 > maxCharInLine {
            stepsLabel.textAlignment = NSTextAlignment.left
        } else {
            stepsLabel.textAlignment = NSTextAlignment.right
        }
    }
}
