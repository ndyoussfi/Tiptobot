//
//  ViewController.swift
//  Tiptobot
//
//  Created by Nour on 12/9/15.
//  Copyright © 2015 Nour. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var lowTip: Float = 0.0
    var midTip: Float = 0.0
    var highTip: Float = 0.0

    
    @IBOutlet weak var billField: UITextField!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tipControl: UISegmentedControl!
    
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var totalStringLabel: UILabel!
    
    @IBOutlet weak var peopleView: UIView!
    @IBOutlet weak var SplitLabel: UILabel!
    @IBOutlet weak var line: UIView!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    var isUp : Bool = false
    var isDown : Bool = false
    var viewFlag : Bool = false
    
    @IBOutlet weak var peopleStepper: UIStepper!
    @IBOutlet weak var totalPerPersonLabel: UILabel!
    @IBOutlet weak var valueTotalPerPersonLabel: UILabel!
    @IBOutlet weak var splitCount: UILabel!
    
    

    var NumPeople : Int = 0
    var valueToTPerson : Float = 0.0
    var tip : Float = 0.0
    var total : Float = 0.0
    var numOfPeople : Double = 0.00
    
    let CurrencyFormat = NSNumberFormatter()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationController?.navigationBar.barTintColor = self.view.backgroundColor
        self.topView.transform = CGAffineTransformTranslate( self.bottomView.transform, 0.0, 155.0  )
        
        
        splitCount.hidden = false
        totalPerPersonLabel.hidden = false
        valueTotalPerPersonLabel.hidden = false
        
        CurrencyFormat.locale = NSLocale.currentLocale()
        let currencySymbol = CurrencyFormat.currencySymbol
        billField.placeholder = currencySymbol
        tipLabel.text = "\(currencySymbol)0.00"
        totalLabel.text = "\(currencySymbol)0.00"
        valueTotalPerPersonLabel.text = "\(currencySymbol)0.0"

        
        let defaults = NSUserDefaults.standardUserDefaults()
        
       
        billField.text = defaults.stringForKey("lastAmount")
        tipLabel.text = defaults.stringForKey("lasttipAmount")
        totalLabel.text = defaults.stringForKey("lasttotalAmount")
        

        valueTotalPerPersonLabel.text = defaults.stringForKey("lastValueTotalPersonAmount")
        splitCount.text = defaults.stringForKey("lastNumPPLindicatorAmount")
        
        peopleStepper.value = Double(defaults.floatForKey("lastStepperAmount"))
        tipControl.selectedSegmentIndex = defaults.integerForKey("lasttipControlAmount")
        
        
        if (billField.text != "" && peopleStepper.value > 1){
            valueTotalPerPersonLabel.hidden = false
        }else{
            self.billField.becomeFirstResponder()
            valueTotalPerPersonLabel.hidden = true
        }
        bottomView.hidden = true
        
        if (billField.text != ""){
            bottomView.hidden = false
            moveTopViewUp()
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
            let userDefaults = NSUserDefaults.standardUserDefaults()
    
        let defaultTip = userDefaults.integerForKey("default_tip")
        print("got default tip: \(defaultTip)")
        switch defaultTip {
        case 0...2:
            tipControl.selectedSegmentIndex = defaultTip
        default:
            tipControl.selectedSegmentIndex = 0
        }
       
        
        
            lowTip = userDefaults.floatForKey("low_tip")
            midTip = userDefaults.floatForKey("mid_tip")
            highTip = userDefaults.floatForKey("high_tip")


            tipControl.setTitle("\(Int(lowTip * 100))%", forSegmentAtIndex: 0)
            tipControl.setTitle("\(Int(midTip * 100))%", forSegmentAtIndex: 1)
            tipControl.setTitle("\(Int(highTip * 100))%", forSegmentAtIndex: 2)

        updateTip()
        
        // ========= LAST THING YOU DID =========
        updateViews()
        // ===========================
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("View Will Disapear")
        let BillText = billField.text
        let tipAmount = tipLabel.text
        let totalAmount = totalLabel.text
        let ValueTotalPersonAmount = valueTotalPerPersonLabel.text
        
        let NumPPLindicatorAmount = splitCount.text
        
        let stepperAmount = peopleStepper.value
        let tipControlAmount = tipControl.selectedSegmentIndex
        
        
        
        NSUserDefaults.standardUserDefaults().setObject(BillText, forKey: "lastAmount")
        NSUserDefaults.standardUserDefaults().setObject(tipAmount, forKey: "lasttipAmount")
        NSUserDefaults.standardUserDefaults().setObject(totalAmount, forKey: "lasttotalAmount")
        

       NSUserDefaults.standardUserDefaults().setObject(ValueTotalPersonAmount, forKey: "lastValueTotalPersonAmount")
        
        NSUserDefaults.standardUserDefaults().setObject(NumPPLindicatorAmount, forKey: "lastNumPPLindicatorAmount")
        
        NSUserDefaults.standardUserDefaults().setObject(stepperAmount, forKey: "lastStepperAmount")
        NSUserDefaults.standardUserDefaults().setObject(tipControlAmount, forKey: "lasttipControlAmount")
        
        if (billField.text != ""){
            moveTopViewUp()
            bottomView.hidden = false
        } else {

            bottomView.hidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

    @IBAction func onStepperChanged(sender: AnyObject) {
        CurrencyFormat.locale = NSLocale.currentLocale()
        let currencySymbol = CurrencyFormat.currencySymbol

        NumPeople = Int(peopleStepper.value)
        
        valueToTPerson = (total / Float(NumPeople))
        valueTotalPerPersonLabel.text = String(format: "\(currencySymbol)%.2f/ea", valueToTPerson)

        splitCount.text = "\(NumPeople)"

        valueTotalPerPersonLabel.text = String(format: "\(currencySymbol)%.2f/ea", valueToTPerson)
        if (NumPeople>1){
            totalPerPersonLabel.hidden = false
            valueTotalPerPersonLabel.hidden = false
            view.endEditing(true)
        }else {
            totalPerPersonLabel.hidden = true
            valueTotalPerPersonLabel.hidden = true
            self.billField.becomeFirstResponder()
        }

    }


    
    

    @IBAction func onEditingChanged(sender: AnyObject) {
        
        CurrencyFormat.locale = NSLocale.currentLocale()
        let currencySymbol = CurrencyFormat.currencySymbol
        
        var tipPercentages = [lowTip, midTip, highTip]
        let tipPercentage = tipPercentages[tipControl.selectedSegmentIndex]
        
        let billAmount = NSString(string: billField.text!).floatValue
        tip = billAmount * tipPercentage
        total = billAmount + tip
        
        tipLabel.text = "\(currencySymbol)\(tip)"
        totalLabel.text = "\(currencySymbol)\(total)"
        tipLabel.text = String(format: "\(currencySymbol)%.2f", tip)
        totalLabel.text = String(format: "\(currencySymbol)%.2f", total)
        
        updateTip()
        updateViews()
    }

    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
        peopleView.hidden = true
    }
    
    func updateViews(){
        if (billField.text != ""){
            bottomView.hidden = false
            peopleView.hidden = false
            tipControl.hidden = false
            tipsLabel.hidden = false
            totalStringLabel.hidden = false
            SplitLabel.hidden = false
            peopleStepper.hidden = false
            splitCount.hidden = false
            tipLabel.hidden = false
            totalLabel.hidden = false
            line.hidden = false
            
            if (!viewFlag){
                moveTopViewUp()
                viewFlag = true
            }
            
            
        } else {
            bottomView.hidden = true
            tipControl.hidden = true
            tipsLabel.hidden = true
            totalStringLabel.hidden = true
            SplitLabel.hidden = true
            peopleStepper.hidden = true
            splitCount.hidden = true
            tipLabel.hidden = true
            totalLabel.hidden = true
            line.hidden = true
            if (viewFlag){
                moveTopViewDown()
                viewFlag = false
            }
            
            
        }
    }
    func moveTopViewUp(){
        
        
        if (!isUp){
            UIView.animateWithDuration(0.4) { () -> Void in
                
                self.topView.transform = CGAffineTransformTranslate(self.topView.transform, 0.0, -152)
                
            }
            UIView.animateWithDuration(0.4) { () -> Void in
                
                self.bottomView.transform = CGAffineTransformTranslate(self.bottomView.transform, 0.0, -295)
                
            }
            
            isUp = true
            isDown = false
        }
        
    }
    
    func moveTopViewDown(){
        
        if (!isDown){
            UIView.animateWithDuration(0.4) { () -> Void in
                
                self.topView.transform = CGAffineTransformTranslate(self.topView.transform, 0.0, 152)
                
            }
            UIView.animateWithDuration(0.4) { () -> Void in
                
                self.bottomView.transform = CGAffineTransformTranslate(self.bottomView.transform, 0.0, 295)
                
            }
            isDown = true
            isUp = false
        }
    }
    
    func updateTip(){
        CurrencyFormat.locale = NSLocale.currentLocale()
        var tipPercentages = [lowTip,midTip,highTip]
        let tipPercentage = tipPercentages[tipControl.selectedSegmentIndex]
        
        let billAmount = NSString(string: billField.text!).doubleValue
        let tip = billAmount * Double(tipPercentage)
        total = Float(billAmount + tip)
        
        valueToTPerson = total / Float(numOfPeople)
        
        tipLabel.text = String(format: "\(CurrencyFormat.currencySymbol)%.2f", tip)
        totalLabel.text = String(format: "\(CurrencyFormat.currencySymbol)%.2f", total)
        
        numOfPeople = Double(peopleStepper.value)
        valueToTPerson = total / Float(numOfPeople)
        valueTotalPerPersonLabel.text = String(format: "\(CurrencyFormat.currencySymbol)%.2f", valueToTPerson)
        
        
    }
}

