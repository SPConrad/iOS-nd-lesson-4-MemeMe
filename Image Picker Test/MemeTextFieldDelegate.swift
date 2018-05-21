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
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        /// clear entered text
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        /// dismiss keyboard
        
        textField.resignFirstResponder()
    }
    
    
    
}
