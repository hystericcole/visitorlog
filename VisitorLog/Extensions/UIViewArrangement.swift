//
//  UIViewArrangement.swift
//  VisitorLog
//
//  Created by Eric Cole on 12/13/20.
//

import UIKit

extension UIView {
	typealias ArrangeAxis = NSLayoutConstraint.Axis
	typealias ArrangeDistribution = UIStackView.Distribution
	enum ArrangeAlignment { case fill, leading, center, trailing }
	
	static func arrangeSizes(_ sizes:[CGSize], within frame:CGRect, spacing:CGFloat, slope:CGFloat = 0, axis:ArrangeAxis, alignment:ArrangeAlignment, distribution:ArrangeDistribution) -> [CGRect] {
		guard !sizes.isEmpty else { return [] }
		
		let count = CGFloat(sizes.count)
		let equal:CGSize
		let sum = sizes.reduce(CGSize.zero) { $0 + $1 }
		let isRTL = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft
		
		var viewFrame: CGRect = .zero
		var spacing = spacing
		var sizes = sizes
		var frames:[CGRect] = []
		
		if axis == .vertical {
			viewFrame.origin.y = frame.origin.y
			equal = CGSize(width:frame.width, height:(frame.height + spacing) / count - spacing)
		} else {
			viewFrame.origin.x = frame.origin.x
			equal = CGSize(width:(frame.width + spacing) / count - spacing, height:frame.height)
		}
		
		if distribution == .fillEqually {
			if axis == .vertical {
				for index in sizes.indices { sizes[index].height = equal.height }
			} else {
				for index in sizes.indices { sizes[index].width = equal.width }
			}
		} else {
			if axis == .vertical {
				let available = frame.size.height - (count - 1) * spacing
				
				if sum.height < available && distribution != .equalSpacing {
					if distribution != .equalCentering {
						for index in sizes.indices { sizes[index].height *= available / sum.height }
					}
				} else if sum.height < frame.size.height {
					spacing = (frame.size.height - sum.height) / (count - 1)
				} else {
					spacing = 0
					
					for index in sizes.indices { sizes[index].height *= frame.size.height / sum.height }
				}
			} else {
				let available = frame.size.width - (count - 1) * spacing
				
				if sum.width < available && distribution != .equalSpacing {
					if distribution != .equalCentering {
						for index in sizes.indices { sizes[index].width *= available / sum.width }
					}
				} else if sum.width < frame.size.width {
					spacing = (frame.size.width - sum.width) / (count - 1)
				} else {
					spacing = 0
					
					for index in sizes.indices { sizes[index].width *= frame.size.width / sum.width }
				}
			}
		}
		
		if distribution == .equalCentering {
			if axis == .vertical {
				let available = frame.size.height - sizes[0].height * 0.5 - sizes[sizes.count - 1].height * 0.5
				
				spacing = available / (count - 1)
			} else {
				let available = frame.size.width - sizes[0].width * 0.5 - sizes[sizes.count - 1].width * 0.5
				
				spacing = available / (count - 1)
			}
		}
		
		for index in sizes.indices {
			if distribution == .equalCentering && index > 0 {
				if axis == .vertical {
					viewFrame.origin.y -= viewFrame.size.height * 0.5 + sizes[index].height * 0.5
				} else {
					viewFrame.origin.x -= viewFrame.size.width * 0.5 + sizes[index].width * 0.5
				}
			}
			
			viewFrame.size = sizes[index]
			
			if axis == .vertical {
				switch alignment {
				case .fill: viewFrame.origin.x = 0; viewFrame.size.width = frame.size.width
				case .center: viewFrame.origin.x = (frame.size.width - viewFrame.size.width) * 0.5
				case .leading: viewFrame.origin.x = isRTL ? frame.size.width - viewFrame.size.width : 0
				case .trailing: viewFrame.origin.x = isRTL ? 0 : frame.size.width - viewFrame.size.width
				}
				
				viewFrame.origin.x += frame.origin.x
				viewFrame.origin.x = viewFrame.origin.x.advanced(by:slope * (viewFrame.origin.y - frame.origin.y))
			} else {
				switch alignment {
				case .fill: viewFrame.origin.y = 0; viewFrame.size.height = frame.size.height
				case .center: viewFrame.origin.y = (frame.size.height - viewFrame.size.height) * 0.5
				case .leading: viewFrame.origin.y = 0
				case .trailing: viewFrame.origin.y = frame.size.height - viewFrame.size.height
				}
				
				viewFrame.origin.y += frame.origin.y
				viewFrame.origin.y += slope * (viewFrame.origin.x - frame.origin.x)
			}
			
			let arranged = CGRect(center:viewFrame.center.rounded(rule:.toNearestOrAwayFromZero), size:viewFrame.size.rounded(rule:.up))
			frames.append(arranged)
			
			if axis == .vertical {
				viewFrame.origin.y += viewFrame.size.height + spacing
			} else {
				viewFrame.origin.x += viewFrame.size.width + spacing
			}
		}
		
		return frames
	}
	
	static func arrangeViews(_ views:[UIView], within frame:CGRect, axis:ArrangeAxis, spacing:CGFloat, slope:CGFloat = 0, alignment:ArrangeAlignment, distribution:ArrangeDistribution) {
		let count = CGFloat(views.count)
		let sizes:[CGSize]
		let equal:CGSize
		
		switch distribution {
		case .fillProportionally, .equalCentering:
			sizes = views.map { view in view.intrinsicContentSize }
		default:
			if axis == .vertical {
				equal = CGSize(width:frame.width, height:(frame.height + spacing) / count - spacing)
			} else {
				equal = CGSize(width:(frame.width + spacing) / count - spacing, height:frame.height)
			}
			
			sizes = views.map { view in view.sizeThatFits(equal) }
		}
		
		let frames = arrangeSizes(sizes, within:frame, spacing:spacing, slope:slope, axis:axis, alignment:alignment, distribution:distribution)
		
		for index in views.indices {
			views[index].frame = frames[index]
		}
	}
	
	static func measureSize(for texts:[NSAttributedString], width:CGFloat, spacing:CGFloat, preserveEmptyTexts:Bool = false) -> CGSize {
		let texts = !preserveEmptyTexts ? texts.filter { !$0.string.isEmpty } : texts
		
		guard !texts.isEmpty else { return .zero }
		
		let limit = CGSize(width:width, height:0)
		var result:CGSize = .zero
		
		for text in texts {
			guard !text.string.isEmpty else { continue }
			
			let bounds = text.boundingRect(with:limit, options: .usesLineFragmentOrigin, context: nil)
			
			result.width = max(result.width, ceil(bounds.size.width))
			result.height += ceil(bounds.size.height)
		}
		
		result.height += spacing * CGFloat(texts.count - 1)
		
		return result
	}
}
