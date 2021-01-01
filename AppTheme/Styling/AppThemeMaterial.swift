//
//  AppThemeMaterial.swift
//  Styling
//
//  Created by Jean Raphael Bordet on 04/06/2020.
//

import Foundation
import UIKit
import Caprice

//if let navBar = navigationController?.navigationBar {
// uiNavigationBar
//  navBar
//    |> { $0.barTintColor = self.theme.primaryColor }
//    <> { $0.tintColor = .white }
//    <> { $0.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white] }
//}

// https://icolorpalette.com/color/hulk-green
// https://encycolorpedia.it/1e5945
public func backgroundLabel(with color: UIColor) -> LabelStyle {
    return {
        $0.backgroundColor = color
    }
}

public func fontLabel(with size: CGFloat, weight: UIFont.Weight = .regular) -> LabelStyle {
    return {
        $0.font = UIFont.systemFont(ofSize: size, weight: weight)
    }
}

public func fontTextField(with size: CGFloat, weight: UIFont.Weight = .regular) -> TextFieldStyle {
    return {
        $0.font = FontFamily.Roboto.thin.font(size: size)
    }
}

public func titleFont(size: CGFloat, weight: UIFont.Weight = .regular) -> ButtonStyle {
    return {
        $0.titleLabel?.font = UIFont.systemFont(ofSize: size, weight: weight)
    }
}

public struct AppThemeMaterial {
    public var primaryLabel: LabelStyle
    public var primaryButton: ButtonStyle
    public var cardView: ViewStyle
    public var detailView: ViewStyle
    public var background: ViewStyle
    public var errorView: ViewStyle
    public var errorLabel: LabelStyle
    public var primaryColor: UIColor
    public var backgroundColor: UIColor
    public var selectionColor: UIColor
    
    public init (
        primaryLabel: @escaping LabelStyle,
        primaryButton: @escaping ButtonStyle,
        card: @escaping ViewStyle,
        detailView: @escaping ViewStyle,
        background: @escaping ViewStyle,
        error: @escaping ViewStyle,
        errorStyle: @escaping LabelStyle,
        primaryColor: UIColor,
        backgroundColor: UIColor,
        selectionColor: UIColor
    ) {
        self.primaryLabel = primaryLabel
        self.primaryButton = primaryButton
        self.cardView = card
        self.detailView = detailView
        self.background = background
        self.errorView = error
        self.errorLabel = errorStyle
        self.primaryColor = primaryColor
        self.backgroundColor = backgroundColor
        self.selectionColor = selectionColor
    }
}

extension AppThemeMaterial {
    public static let theme = AppThemeMaterial(
        primaryLabel:
        lightLabelStyle
            <> { $0.font = FontFamily.Roboto.thin.font(size: 56) }
            <> backgroundLabel(with: .clear)
            <> textColor(color: .onSurfaceColor),
        primaryButton:
        { $0.setTitleColor(.white, for: .normal) }
            <> filledButton(.primaryColor)
            <> titleFont(size: 23, weight: .thin)
            <> rounded(with: 5),
        card:
        shadowStyle
            <> { $0.backgroundColor = .surfaceColor } ,
        detailView: { $0.backgroundColor = .backgroundColor } ,
        background: { $0.backgroundColor = .backgroundColor },
        error: { $0.backgroundColor = .errorColor } <> rounded(with: 5),
        errorStyle:
        lightLabelStyle
            <> fontLabel(with: 23, weight: .thin)
            <> textColor(color: .onErrorColor)
            <> rounded(with: 5),
        primaryColor: .primaryColor,
        backgroundColor: .backgroundColor,
        selectionColor: .primaryColorVariant
    )
}

public func fontThin(with size: CGFloat) -> LabelStyle {
    return {
        $0.font = FontFamily.Roboto.thin.font(size: size)
    }
}

public func fontRegular(with size: CGFloat) -> LabelStyle {
    return {
        $0.font = FontFamily.Roboto.regular.font(size: size)
    }
    
}

public func fontMedium(with size: CGFloat) -> LabelStyle {
    return {
        $0.font = FontFamily.Roboto.medium.font(size: size)
    }
}

