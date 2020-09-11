//
//  ViewController.swift
//  AppThemeDemo
//
//  Created by Jean Raphael Bordet on 18/05/2020.
//  Copyright © 2020 Jean Raphael Bordet. All rights reserved.
//

import UIKit
import SceneBuilder
import Styling
import Caprice

//#1db954    (29,185,84)
//#212121    (33,33,33)
//#121212    (18,18,18)
//#535353    (83,83,83)
//#b3b3b3    (179,179,179)

class ViewController: UIViewController {
    @IBOutlet var mainCard: UIView!
    @IBOutlet var mainLabel: UILabel!

    @IBOutlet var secondMainCard: UIView!
    @IBOutlet var secondMainaLabel: UILabel!
    
    @IBOutlet var errorCard: UIView!
    @IBOutlet var errorLabel: UILabel!
    
    @IBOutlet var genericButton: UIButton!
    
    let theme: AppThemeMaterial = .alarmSoundsGood
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view |> theme.background
        
        if let navBar = navigationController?.navigationBar {
            navBar |> { $0.barTintColor = UIColor.primaryColorDark }
        }
        
        mainCard |> theme.cardView
        
        mainLabel
            |> theme.primaryLabel
            <> textLabel("main label")
            <> fontThin(with: 31)
        
        
        secondMainCard |> theme.cardView
        
        secondMainaLabel
            |> theme.primaryLabel
            <> textLabel("second-main label")
            //<> textColor(color: .systemPink)
            //<> { $0.font = Fontfa }
        
        errorCard |> theme.errorView
        errorLabel |> theme.errorLabel <> textLabel("error")
        
        genericButton |> titleButton("generic button") <> theme.primaryButton
    }
    
    @IBAction func openDetailTap(_ sender: Any) {
        navigationLink(
            from: self,
            destination: Scene<DetailViewController>(),
            completion: { _ in },
            isModal: true
        )
    }
}
