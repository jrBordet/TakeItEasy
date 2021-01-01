// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSColor
  internal typealias Color = NSColor
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIColor
  internal typealias Color = UIColor
#endif

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Colors

// swiftlint:disable identifier_name line_length type_body_length
internal struct ColorName {
  internal let rgbaValue: UInt32
  internal var color: Color { return Color(named: self) }

  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#fafafa"></span>
  /// Alpha: 100% <br/> (0xfafafaff)
  internal static let backgroundColor = ColorName(rgbaValue: 0xfafafaff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#121212"></span>
  /// Alpha: 100% <br/> (0x121212ff)
  internal static let backgroundColorDark = ColorName(rgbaValue: 0x121212ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#b00200"></span>
  /// Alpha: 100% <br/> (0xb00200ff)
  internal static let errorColor = ColorName(rgbaValue: 0xb00200ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#000000"></span>
  /// Alpha: 100% <br/> (0x000000ff)
  internal static let onBackgroundColor = ColorName(rgbaValue: 0x000000ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#000000"></span>
  /// Alpha: 0% <br/> (0x00000000)
  internal static let onBackgroundColorDark = ColorName(rgbaValue: 0x00000000)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffffff"></span>
  /// Alpha: 100% <br/> (0xffffffff)
  internal static let onErrorColor = ColorName(rgbaValue: 0xffffffff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffffff"></span>
  /// Alpha: 100% <br/> (0xffffffff)
  internal static let onPrimaryColor = ColorName(rgbaValue: 0xffffffff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffffff"></span>
  /// Alpha: 100% <br/> (0xffffffff)
  internal static let onPrimaryColorDark = ColorName(rgbaValue: 0xffffffff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffffff"></span>
  /// Alpha: 100% <br/> (0xffffffff)
  internal static let onSecondaryColor = ColorName(rgbaValue: 0xffffffff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffffff"></span>
  /// Alpha: 100% <br/> (0xffffffff)
  internal static let onSecondaryColorDark = ColorName(rgbaValue: 0xffffffff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#535353"></span>
  /// Alpha: 100% <br/> (0x535353ff)
  internal static let onSurfaceColor = ColorName(rgbaValue: 0x535353ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#b3b3b3"></span>
  /// Alpha: 100% <br/> (0xb3b3b3ff)
  internal static let onSurfaceColorDark = ColorName(rgbaValue: 0xb3b3b3ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#008080"></span>
  /// Alpha: 100% <br/> (0x008080ff)
  internal static let primaryColor = ColorName(rgbaValue: 0x008080ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#018286"></span>
  /// Alpha: 100% <br/> (0x018286ff)
  internal static let primaryColorDark = ColorName(rgbaValue: 0x018286ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#00a0a0"></span>
  /// Alpha: 100% <br/> (0x00a0a0ff)
  internal static let primaryColorVariant = ColorName(rgbaValue: 0x00a0a0ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#280680"></span>
  /// Alpha: 100% <br/> (0x280680ff)
  internal static let primaryColorVariantDark = ColorName(rgbaValue: 0x280680ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#5e35b1"></span>
  /// Alpha: 100% <br/> (0x5e35b1ff)
  internal static let secondaryColor = ColorName(rgbaValue: 0x5e35b1ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#280680"></span>
  /// Alpha: 100% <br/> (0x280680ff)
  internal static let secondaryColorDark = ColorName(rgbaValue: 0x280680ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#9162e4"></span>
  /// Alpha: 100% <br/> (0x9162e4ff)
  internal static let secondaryColorVariant = ColorName(rgbaValue: 0x9162e4ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#280680"></span>
  /// Alpha: 100% <br/> (0x280680ff)
  internal static let secondaryColorVariantDark = ColorName(rgbaValue: 0x280680ff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#ffffff"></span>
  /// Alpha: 100% <br/> (0xffffffff)
  internal static let surfaceColor = ColorName(rgbaValue: 0xffffffff)
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#212121"></span>
  /// Alpha: 100% <br/> (0x212121ff)
  internal static let surfaceColorDark = ColorName(rgbaValue: 0x212121ff)
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

internal extension Color {
  convenience init(rgbaValue: UInt32) {
    let components = RGBAComponents(rgbaValue: rgbaValue).normalized
    self.init(red: components[0], green: components[1], blue: components[2], alpha: components[3])
  }
}

private struct RGBAComponents {
  let rgbaValue: UInt32

  private var shifts: [UInt32] {
    [
      rgbaValue >> 24, // red
      rgbaValue >> 16, // green
      rgbaValue >> 8,  // blue
      rgbaValue        // alpha
    ]
  }

  private var components: [CGFloat] {
    shifts.map {
      CGFloat($0 & 0xff)
    }
  }

  var normalized: [CGFloat] {
    components.map { $0 / 255.0 }
  }
}

internal extension Color {
  convenience init(named color: ColorName) {
    self.init(rgbaValue: color.rgbaValue)
  }
}
