//
//  MemeTextFieldDelegate.swift
//  Image Picker Test
//
//  Created by Sean Conrad on 5/20/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import Foundation
import UIKit

class MemeTextFieldDelegate : NSObject, UITextFieldDelegate {
    var defaultText = ""
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        
        let currentText = textField.text
        
        
        if currentText == textField.placeholder {
            clearTextField(textField)
        }
        
        /// clear entered text
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        /// dismiss keyboard
        if let currentText = textField.text {
            if currentText == "" {
                textField.text = textField.placeholder
            }
            
        } else {
            
        }
        textField.resignFirstResponder()
    }
    
    
    func clearTextField(_ textField: UITextField){
        textField.text = ""
    }
    
}
