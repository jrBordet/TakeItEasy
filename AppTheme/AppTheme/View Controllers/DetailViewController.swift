//
//  DetailViewController.swift
//  AppThemeDemo
//
//  Created by Jean Raphael Bordet on 21/05/2020.
//  Copyright © 2020 Jean Raphael Bordet. All rights reserved.
//

import UIKit
import Styling
import Caprice

class DetailViewController: UIViewController {
    @IBOutlet var mainLabel: UILabel!
    @IBOutlet var field: UITextField!
    
    let theme: AppThemeMaterial = .theme
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view |> theme.detailView
        
        mainLabel
            |> theme.primaryLabel
            <> textLabel("main label")
            <> backgroundLabel(with: .clear)
        
        field |> fontTextField(with: 17)
    }

}
