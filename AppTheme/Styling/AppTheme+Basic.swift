//
//  AppTheme+Basic.swift
//  AppThemeDemo
//
//  Created by Jean Raphael Bordet on 19/05/2020.
//  Copyright © 2020 Jean Raphael Bordet. All rights reserved.
//

import UIKit

// https://material.io/design/color/the-color-system.html#color-theme-creation
// https://www.color-hex.com/color/000000

extension UIColor {
    static func color(light: UIColor, dark: UIColor) -> UIColor {
        guard #available(iOS 13.0, *) else {
            return light
        }
        
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            guard UITraitCollection.userInterfaceStyle == .dark else {
                return light
            }
            
            return dark
        }
    }
    
    // The color displayed most frequently across your app’s screens and components.
    public static var primaryColorDark: UIColor {
        UIColor.color(
            light: ColorName.primaryColorDark.color,
            dark: ColorName.primaryColorDark.color
        )
    }
    
    // The color displayed most frequently across your app’s screens and components.
    public static var primaryColor: UIColor {
        UIColor.color(
            light: ColorName.primaryColor.color,
            dark: ColorName.primaryColorDark.color
        )
    }
    
    // A light or dark variation of the primary color.
    public static var primaryColorVariant: UIColor {
        UIColor.color(
            light: ColorName.primaryColorVariant.color,
            dark: ColorName.primaryColorVariantDark.color
        )
    }
    
    // Provides ways to accent and distinguish your product. Floating action buttons use the secondary color.
    public static var secondaryColor: UIColor {
        UIColor.color(
            light: ColorName.secondaryColor.color,
            dark: ColorName.secondaryColorDark.color
        )
    }
    
    public static var secondaryColorVariant: UIColor {
        UIColor.color(
            light: ColorName.secondaryColorVariant.color,
            dark: ColorName.secondaryColorVariantDark.color
        )
    }
    
    // The indication of errors within components such as text fields.
    public static var errorColor: UIColor {
        UIColor.color(
            light: ColorName.errorColor.color,
            dark: ColorName.errorColor.color
        )
    }
    
    // Typically maps to the background of components such as cards, sheets, and dialogs.
    public static var surfaceColor: UIColor {
        UIColor.color(
            light: ColorName.surfaceColor.color,
            dark: ColorName.surfaceColorDark.color
        )
    }
    
    // Typically found behind scrollable content.
    public static var backgroundColor: UIColor {
        UIColor.color(
            light: ColorName.backgroundColor.color,
            dark: ColorName.backgroundColorDark.color
        )
    }
    
    // MARK: - On color
    
    // Text/iconography drawn on top of primaryColor.
    public static var onPrimaryColor: UIColor {
        UIColor.color(
            light:ColorName.onPrimaryColor.color,
            dark: ColorName.onPrimaryColorDark.color
        )
    }
    
    // Text/iconography drawn on top of secondaryColor.
    public static var onSecondaryColor: UIColor {
        UIColor.color(
            light: ColorName.onSecondaryColor.color,
            dark: ColorName.onSecondaryColorDark.color
        )
    }
    
    // Text/iconography drawn on top of errorColor.
    public static var onErrorColor: UIColor {
        UIColor.color(
            light: ColorName.onErrorColor.color,
            dark: ColorName.onErrorColor.color
        )
    }
    
    // Text/iconography drawn on top of surfaceColor.
    public static var onSurfaceColor: UIColor {
        UIColor.color(
            light: ColorName.onSurfaceColor.color,
            dark: ColorName.onSurfaceColorDark.color
        )
    }
    
    // Text/iconography drawn on top of backgroundColor.
    public static var onBackgroundColor: UIColor {
        UIColor.color(
            light: ColorName.onBackgroundColor.color,
            dark: ColorName.onBackgroundColor.color
        )
    }
}
