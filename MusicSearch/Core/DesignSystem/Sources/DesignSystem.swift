//
//  DesignSystem.swift
//  MusicSearch
//
//  Created by Kiseok on 6/17/26.
//

import SwiftUI

// MARK: - Color Tokens
public enum CustomColor {
	public static let surface = Color(hex: "#121212")
	public static let surfaceDim = Color(hex: "#0A0A0A")
	public static let surfaceBright = Color(hex: "#1E1E1E")
	public static let surfaceContainerLowest = Color(hex: "#000000")
	public static let surfaceContainerLow = Color(hex: "#121212")
	public static let surfaceContainer = Color(hex: "#1C1C1E")
	public static let surfaceContainerHigh = Color(hex: "#2C2C2E")
	public static let surfaceContainerHighest = Color(hex: "#3A3A3C")

	public static let onSurface = Color(hex: "#FFFFFF")
	public static let onSurfaceVariant = Color(hex: "#8E8E93")
	public static let inverseSurface = Color(hex: "#FFFFFF")
	public static let inverseOnSurface = Color(hex: "#000000")

	public static let outline = Color(hex: "#3A3A3C")
	public static let outlineVariant = Color(hex: "#2C2C2E")

	public static let primary = Color(hex: "#FFFFFF")
	public static let onPrimary = Color(hex: "#000000")
	public static let primaryContainer = Color(hex: "#2C2C2E")
	public static let onPrimaryContainer = Color(hex: "#FFFFFF")
	public static let inversePrimary = Color(hex: "#8E8E93")

	public static let secondary = Color(hex: "#A1A1A6")
	public static let onSecondary = Color(hex: "#000000")
	public static let secondaryContainer = Color(hex: "#3A3A3C")
	public static let onSecondaryContainer = Color(hex: "#FFFFFF")

	public static let tertiary = Color(hex: "#48484A")
	public static let onTertiary = Color(hex: "#FFFFFF")
	public static let tertiaryContainer = Color(hex: "#1C1C1E")
	public static let onTertiaryContainer = Color(hex: "#EBEBF5")

	public static let error = Color(hex: "#FF453A")
	public static let onError = Color(hex: "#FFFFFF")
	public static let errorContainer = Color(hex: "#3A0A0A")
	public static let onErrorContainer = Color(hex: "#FF8A80")

	public static let surfaceTint = Color(hex: "#FFFFFF")
	public static let surfaceVariant = Color(hex: "#1C1C1E")

	public static let primaryFixed = Color(hex: "#FFFFFF")
	public static let primaryFixedDim = Color(hex: "#EBEBF5")
	public static let onPrimaryFixed = Color(hex: "#000000")
	public static let onPrimaryFixedVariant = Color(hex: "#3A3A3C")

	public static let secondaryFixed = Color(hex: "#EBEBF5")
	public static let secondaryFixedDim = Color(hex: "#A1A1A6")
	public static let onSecondaryFixed = Color(hex: "#000000")
	public static let onSecondaryFixedVariant = Color(hex: "#2C2C2E")

	public static let tertiaryFixed = Color(hex: "#A1A1A6")
	public static let tertiaryFixedDim = Color(hex: "#8E8E93")
	public static let onTertiaryFixed = Color(hex: "#000000")
	public static let onTertiaryFixedVariant = Color(hex: "#1C1C1E")

	public static let background = Color(hex: "#000000")
	public static let onBackground = Color(hex: "#FFFFFF")
}

// MARK: - Spacing Tokens
public enum CustomSpacing {
	public static let base: CGFloat = 8
	public static let gutter: CGFloat = 16
	public static let containerMargin: CGFloat = 24

	public static let stackSm: CGFloat = 12
	public static let stackMd: CGFloat = 24
	public static let stackLg: CGFloat = 48
}

// MARK: - Radius Tokens
public enum CustomRadius {
	public static let sm: CGFloat = 4
	public static let base: CGFloat = 8
	public static let md: CGFloat = 12
	public static let lg: CGFloat = 16
	public static let xl: CGFloat = 24
	public static let xxl: CGFloat = 32
	public static let full: CGFloat = 9999
}

// MARK: - Typography Tokens
public enum CustomTextStyle {
	case displayLg
	case displayLgMobile
	case headlineMd
	case bodyLg
	case bodyMd
	case labelSm
	case monoLabel
}

public struct CustomTypographyModifier: ViewModifier {
	let style: CustomTextStyle

	public func body(content: Content) -> some View {
		switch style {
		case .displayLg:
			content
				.font(.system(size: 48, weight: .heavy))
				.lineSpacing(48 * 0.1)
				.tracking(48 * -0.04)
		case .displayLgMobile:
			content
				.font(.system(size: 36, weight: .heavy))
				.lineSpacing(36 * 0.1)
				.tracking(36 * -0.04)
		case .headlineMd:
			content
				.font(.system(size: 24, weight: .semibold))
				.lineSpacing(24 * 0.3)
				.tracking(24 * -0.02)
		case .bodyLg:
			content
				.font(.system(size: 18, weight: .regular))
				.lineSpacing(18 * 0.6)
		case .bodyMd:
			content
				.font(.system(size: 16, weight: .regular))
				.lineSpacing(16 * 0.5)
		case .labelSm:
			content
				.font(.system(size: 12, weight: .semibold))
				.lineSpacing(0)
				.tracking(12 * 0.08)
		case .monoLabel:
			content
				.font(.system(size: 11, weight: .medium, design: .monospaced))
				.lineSpacing(0)
		}
	}
}

// MARK: - Modifiers
public struct LiquidGlassModifier: ViewModifier {
    let cornerRadius: CGFloat

    public init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.15),
                                        Color.white.opacity(0.0),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.0),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: - View Extensions
public extension View {
	func customText(_ style: CustomTextStyle) -> some View {
		self.modifier(CustomTypographyModifier(style: style))
	}

    func liquidGlass(cornerRadius: CGFloat = CustomRadius.xl) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Button Styles
public struct BouncyButtonStyle: ButtonStyle {
	public init() {}

	public func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed ? 0.95 : 1.0)
			.opacity(configuration.isPressed ? 0.9 : 1.0)
			.animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: configuration.isPressed)
	}
}

// MARK: - Hex Color Extension
fileprivate extension Color {
	init(hex: String) {
		let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var int: UInt64 = 0
		Scanner(string: hex).scanHexInt64(&int)
		let a, r, g, b: UInt64
		switch hex.count {
		case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
		case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		default: (a, r, g, b) = (1, 1, 1, 0)
		}
		self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
	}
}
