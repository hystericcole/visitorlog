//
//  DateFormatterExtensions.swift
//  VisitorLog
//
//  Created by Eric Cole on 12/13/20.
//

import Foundation

protocol AnyDateFormatter: AnyObject {
	func date(from:String) -> Date?
	func string(from:Date) -> String
}

extension DateFormatter: AnyDateFormatter {}
extension ISO8601DateFormatter: AnyDateFormatter {}

extension ISO8601DateFormatter.Options {
	static let rfc3339:ISO8601DateFormatter.Options = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime, .withColonSeparatorInTimeZone]
}

extension DateFormatter {
	enum Format {
		case style(date:DateFormatter.Style, time:DateFormatter.Style)
		case string(String)
		case template(String)
		
		var keyPrefix:String {
			switch self {
			case .style(let date, let time): return "s-d:\(date.rawValue)-t:\(time.rawValue)"
			case .string(let format): return "f-" + format
			case .template(let template): return "t-" + template
			}
		}
		
		func apply(to formatter:DateFormatter) {
			switch self {
			case .style(let date, let time):
				formatter.dateStyle = date
				formatter.timeStyle = time
			case .string(let format):
				formatter.dateFormat = format
			case .template(let template):
				formatter.setLocalizedDateFormatFromTemplate(template)
			}
		}
	}
	
	struct Options {
		enum Posix: Int {
			case no, yes, utc
			
			func apply(to dateFormatter:DateFormatter) {
				guard self != .no else { return }
				
				dateFormatter.calendar = Calendar(identifier:.gregorian)
				dateFormatter.locale = Locale(identifier:"en_US_POSIX")
				
				if self == .utc {
					dateFormatter.timeZone = TimeZone(secondsFromGMT:0)
				}
			}
		}
		
		let doesRelativeDateFormatting:Bool
		let formatterBehavior:DateFormatter.Behavior
		let formattingContext:DateFormatter.Context
		let isLenient:Bool
		let posix:Posix
		
		var keySuffix:String {
			return ""
				+ "-r:\(doesRelativeDateFormatting)"
				+ "-c:\(formattingContext.rawValue)"
				+ "-p:\(posix.rawValue)"
				+ "-l:\(isLenient)"
				+ "-b:\(formatterBehavior.rawValue)"
		}
		
		init(context:DateFormatter.Context = .dynamic, relative:Bool = false, posix:Posix = .no, lenient:Bool = false, behavior:DateFormatter.Behavior = .behavior10_4) {
			self.doesRelativeDateFormatting = relative
			self.formatterBehavior = behavior
			self.formattingContext = context
			self.isLenient = lenient
			self.posix = posix
		}
		
		func apply(to dateFormatter:DateFormatter) {
			dateFormatter.doesRelativeDateFormatting = doesRelativeDateFormatting
			dateFormatter.formattingContext = formattingContext
			dateFormatter.formatterBehavior = formatterBehavior
			dateFormatter.isLenient = isLenient
			
			posix.apply(to:dateFormatter)
		}
	}
	
	enum Configuration {
		case standard(Format, Options)
		case iso8601(ISO8601DateFormatter.Options)
		
		static let rfc3339 = Configuration.iso8601(.rfc3339)
		
		var key:String {
			switch self {
			case .iso8601(let options):
				return "iso-\(options.rawValue)"
			case .standard(let configuration, let options):
				return configuration.keyPrefix + options.keySuffix
			}
		}
		
		var formatter:AnyDateFormatter {
			return DateFormatter.cached(self)
		}
		
		func createDateFormatter() -> AnyDateFormatter {
			switch self {
			case .iso8601(let options):
				let formatter = ISO8601DateFormatter()
				
				formatter.formatOptions = options
				
				return formatter
			
			case .standard(let configuration, let options):
				let formatter = DateFormatter()
				
				options.apply(to:formatter)
				configuration.apply(to:formatter)
				
				return formatter
			}
		}
	}
	
	static var cache:[String:AnyDateFormatter] = [:]
	
	static func cached(_ configuration:Configuration) -> AnyDateFormatter {
		let key = configuration.key
		
		if let existing = cache[key] {
			return existing
		}
		
		let formatter = configuration.createDateFormatter()
		
		DispatchQueue.main.async {
			cache[key] = formatter
		}
		
		return formatter
	}
	
	static func with(iso8601 options:ISO8601DateFormatter.Options) -> AnyDateFormatter {
		return cached(.iso8601(options))
	}
	
	static func with(_ format:Format, options:Options) -> AnyDateFormatter {
		return cached(.standard(format, options))
	}
	
	static func with(_ format:Format, context:DateFormatter.Context = .dynamic, relative:Bool = false) -> AnyDateFormatter {
		return with(format, options:Options(context:context, relative:relative))
	}
	
	static var rfc3339:AnyDateFormatter { return Configuration.rfc3339.formatter }
}

extension DateFormatter {
	static let signInConfiguration = Configuration.standard(.style(date:.none, time:.short), Options(context:.standalone))
	static var signIn:AnyDateFormatter { return signInConfiguration.formatter }
	
	static let birthdateConfiguration = Configuration.iso8601([.withFullDate, .withDashSeparatorInDate])
	static var birthdate:AnyDateFormatter { return birthdateConfiguration.formatter }
}
