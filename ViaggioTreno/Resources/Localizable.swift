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
      /// Dismiss
      internal static let dismiss = L10n.tr("Localizable", "app.common.dismiss")
      /// Save
      internal static let save = L10n.tr("Localizable", "app.common.save")
    }
    internal enum Home {
      /// Add stations
      internal static let addStations = L10n.tr("Localizable", "app.home.addStations")
      /// +
      internal static let plus = L10n.tr("Localizable", "app.home.plus")
    }
  }

  internal enum Form {
    internal enum Alarm {
      /// Create
      internal static let create = L10n.tr("Localizable", "form.alarm.create")
      /// Time
      internal static let date = L10n.tr("Localizable", "form.alarm.date")
      /// Days
      internal static let days = L10n.tr("Localizable", "form.alarm.days")
      /// Delete
      internal static let delete = L10n.tr("Localizable", "form.alarm.delete")
      /// Enable
      internal static let enable = L10n.tr("Localizable", "form.alarm.enable")
      /// Media
      internal static let media = L10n.tr("Localizable", "form.alarm.media")
      /// Title
      internal static let title = L10n.tr("Localizable", "form.alarm.title")
      /// title
      internal static let titlePlaceholder = L10n.tr("Localizable", "form.alarm.title_placeholder")
    }
    internal enum Days {
      /// everyday
      internal static let everyday = L10n.tr("Localizable", "form.days.everyday")
      /// friday
      internal static let friday = L10n.tr("Localizable", "form.days.friday")
      /// monday
      internal static let monday = L10n.tr("Localizable", "form.days.monday")
      /// saturday
      internal static let saturday = L10n.tr("Localizable", "form.days.saturday")
      /// sunday
      internal static let sunday = L10n.tr("Localizable", "form.days.sunday")
      /// thursday
      internal static let thursday = L10n.tr("Localizable", "form.days.thursday")
      /// tuesday
      internal static let tuesday = L10n.tr("Localizable", "form.days.tuesday")
      /// wednesday
      internal static let wednesday = L10n.tr("Localizable", "form.days.wednesday")
      /// weekend
      internal static let weekend = L10n.tr("Localizable", "form.days.weekend")
    }
  }

  internal enum Media {
    /// Confirm
    internal static let confirm = L10n.tr("Localizable", "media.confirm")
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
