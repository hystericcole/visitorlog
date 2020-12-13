//
//  Style.swift
//  VisitorLog
//
//  Created by Eric Cole on 12/12/20.
//

import UIKit

struct Style {
	typealias Attributes = [NSAttributedString.Key:Any]

	enum Font {
		case system, bold, italic
		case weighted(UIFont.Weight)
		case monospace(UIFont.Weight)
		case monospaceDigit(UIFont.Weight)
		case name(String)
		case style(UIFont.TextStyle)
		case traits(UIFont.TextStyle, UITraitCollection?, UIFontDescriptor.SymbolicTraits?)
		case descriptor(UIFontDescriptor)
		case attributes([UIFontDescriptor.AttributeName:Any])
		
		static var commonSize:CGFloat { return UIFont.systemFontSize }
		
		func displayFont(size:CGFloat? = nil) -> UIFont {
			switch self {
			case .system:
				return UIFont.systemFont(ofSize:size ?? Font.commonSize)
			case .bold:
				return UIFont.boldSystemFont(ofSize:size ?? Font.commonSize)
			case .italic:
				return UIFont.italicSystemFont(ofSize:size ?? Font.commonSize)
			case .weighted(let weight):
				return UIFont.systemFont(ofSize:size ?? Font.commonSize, weight:weight)
			case .monospace(let weight):
				return UIFont.monospacedSystemFont(ofSize:size ?? Font.commonSize, weight:weight)
			case .monospaceDigit(let weight):
				return UIFont.monospacedDigitSystemFont(ofSize:size ?? Font.commonSize, weight:weight)
			case .name(let name):
				return UIFont(name:name, size:size ?? Font.commonSize) ?? UIFont.systemFont(ofSize:size ?? Font.commonSize)
			case .style(let style):
				let font = UIFont.preferredFont(forTextStyle:style)
				
				if let size = size {
					return font.withSize(size)
				} else {
					return font
				}
			case .descriptor(let descriptor):
				return UIFont(descriptor:descriptor, size:size ?? descriptor.pointSize)
			case .attributes(let attributes):
				let descriptor = UIFontDescriptor(fontAttributes:attributes)
				
				return UIFont(descriptor:descriptor, size:size ?? descriptor.pointSize)
			case .traits(let style, let traits, let symbolic):
				var descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle:style, compatibleWith:traits)
				
				if let symbolic = symbolic {
					descriptor = descriptor.withSymbolicTraits(symbolic) ?? descriptor
				}
				
				return UIFont(descriptor:descriptor, size:size ?? descriptor.pointSize)
			}
		}
		
		static let title = Font.name("Futura")
		static let body = Font.style(.body)
		static let date = Font.monospaceDigit(.medium)
		static let number = Font.monospaceDigit(.regular)
	}
	
	let font:Font
	let size:CGFloat?
	let color:UIColor?
	let alignment:NSTextAlignment
	
	var attributes:Attributes {
		var attributes:Attributes = [.font:font.displayFont(size:size)]
		
		if let color = color {
			attributes[.foregroundColor] = color
		}
		
		let paragraph = NSMutableParagraphStyle()
		
		paragraph.alignment = alignment
		
		attributes[.paragraphStyle] = paragraph
		
		return attributes
	}
	
	init(font:Font, size:CGFloat?, color:UIColor?, alignment:NSTextAlignment = .natural) {
		self.font = font
		self.size = size
		self.color = color
		self.alignment = alignment
	}
	
	func with(font:Font? = nil, size:CGFloat? = nil, color:UIColor? = nil, alignment:NSTextAlignment? = nil) -> Style {
		return Style(
			font:font ?? self.font,
			size:size ?? self.size,
			color:color ?? self.color,
			alignment:alignment ?? self.alignment
		)
	}
}

class Theme {
	static let common = Theme(
		primaryBackground:UIColor(white:1, alpha:1),
		primaryText:UIColor(white:2/16, alpha:1),
		memberBackground:UIColor(hue:1/3, saturation:1/8, brightness:1, alpha:1/6),
		guestBackground:UIColor(hue:2/3, saturation:1/8, brightness:1, alpha:1/8),
		buttonBackground:UIColor(white:1, alpha:1/2),
		buttonBorder:UIColor(white:3/16, alpha:1),
		separator:UIColor(white:14/16, alpha:1)
	)
	
	let primaryBackground:UIColor
	let memberBackground:UIColor
	let guestBackground:UIColor
	let primaryText:UIColor
	let buttonBackground:UIColor
	let buttonBorder:UIColor
	let separator:UIColor
	
	var buttonDisabled:UIColor { return primaryText.withAlphaComponent(0.5) }
	
	internal init(
		primaryBackground:UIColor,
		primaryText:UIColor,
		memberBackground:UIColor,
		guestBackground:UIColor,
		buttonBackground:UIColor,
		buttonBorder:UIColor,
		separator:UIColor)
	{
		self.primaryBackground = primaryBackground
		self.primaryText = primaryText
		self.memberBackground = memberBackground
		self.guestBackground = guestBackground
		self.buttonBackground = buttonBackground
		self.buttonBorder = buttonBorder
		self.separator = separator
	}
}

extension UILabel {
	convenience init(style:Style, minimumScale:CGFloat, maximumLines:Int? = nil) {
		self.init()
		
		applyStyle(style, minimumScale:minimumScale, maximumLines:maximumLines)
	}
	
	var style:Style {
		get {
			return Style(font:font.styleFont, size:font.pointSize, color:textColor, alignment:textAlignment)
		}
		set {
			font = newValue.font.displayFont(size:newValue.size ?? font.pointSize)
			textAlignment = newValue.alignment
			if let color = newValue.color, color != textColor { textColor = color }
		}
	}
	
	func applyStyle(_ style:Style, minimumScale:CGFloat = 1, maximumLines:Int? = nil) {
		self.style = style
		
		if let lines = maximumLines {
			numberOfLines = lines
			lineBreakMode = lines > 0 ? .byTruncatingTail : .byWordWrapping
		}
		
		minimumScaleFactor = minimumScale
		adjustsFontSizeToFitWidth = minimumScale < 1
		allowsDefaultTighteningForTruncation = minimumScale < 1
	}
}

extension UITextField {
	var style:Style {
		get {
			return Style(font:font?.styleFont ?? .system, size:font?.pointSize, color:textColor, alignment:textAlignment)
		}
		set {
			font = newValue.font.displayFont(size:newValue.size ?? font?.pointSize)
			textAlignment = newValue.alignment
			if let color = newValue.color, color != textColor { textColor = color }
		}
	}
	
	func applyStyle(_ style:Style, minimumScale:CGFloat = 1) {
		self.style = style
		
		if let size = font?.pointSize ?? style.size {
			minimumFontSize = size * minimumScale
		}
		
		adjustsFontSizeToFitWidth = minimumScale < 1
	}
}

extension UIFont {
	var styleFont:Style.Font {
		return .descriptor(fontDescriptor)
	}
}

extension UIButton {
	func applyStyle(_ style:Style, minimumScale:CGFloat = 1, maximumLines:Int? = nil) {
		titleLabel?.applyStyle(style, minimumScale:minimumScale, maximumLines:maximumLines)
		
		contentHorizontalAlignment = style.alignment.contentAlignment
		
		if let color = style.color { setTitleColor(color, for:.normal) }
	}
}

extension NSTextAlignment {
	var contentAlignment:UIControl.ContentHorizontalAlignment {
		switch self {
		case .center: return .center
		case .justified: return .fill
		case .left: return .left
		case .right: return .right
		default: return .leading
		}
	}
}
