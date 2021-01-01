// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {

  internal enum App {
    /// 
    internal static let name = L10n.tr("Localizable", "app.name")
    internal enum Common {
      /// Arrivals
      internal static let arrivals = L10n.tr("Localizable", "app.common.arrivals")
      /// Board
      internal static let board = L10n.tr("Localizable", "app.common.board")
      /// Departures
      internal static let departures = L10n.tr("Localizable", "app.common.departures")
      /// Dismiss
      internal static let dismiss = L10n.tr("Localizable", "app.common.dismiss")
      /// Save
      internal static let save = L10n.tr("Localizable", "app.common.save")
      /// X
      internal static let x = L10n.tr("Localizable", "app.common.x")
    }
    internal enum Home {
      /// Add stations
      internal static let addStations = L10n.tr("Localizable", "app.home.addStations")
      /// No stations on your favourites
      internal static let disclaimer = L10n.tr("Localizable", "app.home.disclaimer")
      /// +
      internal static let plus = L10n.tr("Localizable", "app.home.plus")
    }
  }

  internal enum Sections {
    /// No results
    internal static let empty = L10n.tr("Localizable", "sections.empty")
  }

  internal enum Stations {
    /// Search...
    internal static let searchbar = L10n.tr("Localizable", "stations.searchbar")
    /// Stations
    internal static let title = L10n.tr("Localizable", "stations.title")
    internal enum Header {
      /// My stations
      internal static let favourites = L10n.tr("Localizable", "stations.header.favourites")
      /// Results
      internal static let results = L10n.tr("Localizable", "stations.header.results")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle = Bundle(for: BundleToken.self)
}
// swiftlint:enable convenience_type
