//
//  File.swift
//  SaveMyTime
//
//  Created by Yuan zhou on 5/14/18.
//  Copyright © 2018 Yuan zhou. All rights reserved.
//
import Foundation
import UIKit

class ColorPickViewController: UIViewController {
    
    // Init ColorPicker with yellow
    var selectedColor: UIColor = UIColor.white
    
    // IBOutlet for the ColorPicker
    @IBOutlet var colorPicker: SwiftHSVColorPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Setup Color Picker
        colorPicker.setViewColor(selectedColor)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getSelectedColor(_ sender: UIButton) {
        // Get the selected color from the Color Picker.
        let selectedColor = colorPicker.color
        
        print(selectedColor!)
    }
}