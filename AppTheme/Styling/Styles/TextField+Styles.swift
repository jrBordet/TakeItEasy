//
//  TextField+Styles.swift
//  Styling
//
//  Created by Jean Raphael Bordet on 15/06/2020.
//

import UIKit
import Caprice

public typealias TextFieldStyle = (UITextField) -> Void

public let lightTextFieldStyle: TextFieldStyle = { field in
    field.textColor = UIColor.lightGray
}

public func fontTextFieldStyle(of font: UIFont) -> TextFieldStyle {
    return { field in
        field.font = font
    }
}
