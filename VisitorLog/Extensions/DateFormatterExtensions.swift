//
//  DateFormatterExtensions.swift
//  VisitorLog
//
//  Created by Eric Cole on 12/13/20.
//

import Foundation

extension DateFormatter {
	static var cache:[String:DateFormatter] = [:]
	
	static func with(dateStyle:DateFormatter.Style, timeStyle:DateFormatter.Style, relative:Bool = false, context:DateFormatter.Context = .dynamic) -> DateFormatter {
		let key = "s-d:\(dateStyle.rawValue)-t:\(timeStyle.rawValue)-r:\(relative)-c:\(context.rawValue)"
		
		if let existing = cache[key] {
			return existing
		}
		
		let formatter = DateFormatter()
		
		formatter.doesRelativeDateFormatting = relative
		formatter.formattingContext = context
		formatter.dateStyle = dateStyle
		formatter.timeStyle = timeStyle
		
		cache[key] = formatter
		
		return formatter
	}
	
	static func with(format:String, isTemplate:Bool = false, relative:Bool = false, context:DateFormatter.Context = .dynamic) -> DateFormatter {
		let key = (isTemplate ? "t-" : "f-") + format + "-r:\(relative)-c:\(context.rawValue)"
		
		if let existing = cache[key] {
			return existing
		}
		
		let formatter = DateFormatter()
		
		formatter.doesRelativeDateFormatting = relative
		formatter.formattingContext = context
		
		if isTemplate {
			formatter.setLocalizedDateFormatFromTemplate(format)
		} else {
			formatter.dateFormat = format
		}
		
		cache[key] = formatter
		
		return formatter
	}
	
	static var signIn:DateFormatter { return with(dateStyle:.none, timeStyle:.short, context:.standalone) }
	static var birthdate:DateFormatter { return with(dateStyle:.medium, timeStyle:.none, context:.standalone) }
}
