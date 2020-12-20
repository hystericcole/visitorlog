//
//  VisitorManager.swift
//  VisitorLog
//
//  Created by Eric Cole on 12/12/20.
//

import Foundation

class VisitorManager {
	static let shared = VisitorManager()
	
	enum Access: String {
		case member, guest, create
		
		init(isMember:Bool) {
			self = isMember ? .member : .guest
		}
	}
	
	struct Person: Codable, Hashable {
		let name: String
		let birthdate: Date
	}
	
	struct Visitor: Codable {
		let person: Person
		let isMember: Bool
		let signIn: Date
		
		func isSame(_ other: Visitor) -> Bool { return person == other.person && isMember == other.isMember }
	}
	
	struct PreviousVisitor: Codable {
		let visitor: Visitor
		let signOut: Date
	}
	
	var knownMembers: [Person] = []
	var activeVisitors: [Visitor] = []
	var sessionVisitors: [PreviousVisitor] = []
	
	var visitorCount:(members:Int, guests:Int) {
		var members = 0
		var guests = 0
		
		for visitor in activeVisitors {
			if visitor.isMember {
				members += 1
			} else {
				guests += 1
			}
		}
		
		return (members, guests)
	}
	
	func prepare() {
		refresh()
		
		if let visitors = try? visitorState() {
			activeVisitors = visitors
		}
	}
	
	func refresh() {
		if let members = try? membersFromConfiguration() {
			knownMembers = members
		}
	}
	
	func isActiveVisitor(person:Person) -> Bool {
		return activeVisitors.contains { $0.person == person }
	}
	
	func signIn(person:Person, isMember:Bool, date:Date) {
		activeVisitors.append(Visitor(person: person, isMember: isMember, signIn: date))
		
		let entry = csv(signIn:date, signOut:nil, access:Access(isMember:isMember), person:person)
		let state = activeVisitors
		
		DispatchQueue.utility.async {
			try? self.record(csv:entry)
			try? self.saveVisitorState(active:state)
		}
	}
	
	func signOut(visitor:Visitor, date:Date) {
		activeVisitors.removeAll { $0.isSame(visitor) }
		sessionVisitors.append(PreviousVisitor(visitor: visitor, signOut: date))
		
		let entry = csv(signIn:visitor.signIn, signOut:date, access:Access(isMember:visitor.isMember), person:visitor.person)
		let state = activeVisitors
		
		DispatchQueue.utility.async {
			try? self.record(csv:entry)
			try? self.saveVisitorState(active:state)
		}
	}
	
	func createMember(person:Person) {
		knownMembers.append(person)
		
		let entry = csv(signIn:Date(), signOut:nil, access:.create, person:person)
		let known = knownMembers
		
		DispatchQueue.utility.async {
			try? self.record(csv:entry)
			try? self.saveKnownMembers(known:known)
		}
	}
	
	func membersToSignIn() -> [Person] {
		return knownMembers.filter { member in !activeVisitors.contains { $0.isMember && member == $0.person } }
	}
	
	func membersToSignOut() -> [Visitor] {
		return activeVisitors.filter { $0.isMember }
	}
	
	func guestsToSignOut() -> [Visitor] {
		return activeVisitors.filter { !$0.isMember }
	}
	
	func memberFile() -> URL {
		return FileManager.default.document(path:"member.json")
	}
	
	func activeFile() -> URL {
		return FileManager.default.document(path:"active.json")
	}
	
	func historyFile() -> URL {
		return FileManager.default.document(path:"history.csv")
	}
	
	func encoder() -> JSONEncoder {
		let result = JSONEncoder()
		
		result.outputFormatting = [.prettyPrinted, .sortedKeys]
		result.dateEncodingStrategy = .iso8601
		
		return result
	}
	
	func decoder() -> JSONDecoder {
		let result = JSONDecoder()
		
		result.dateDecodingStrategy = .iso8601
		
		return result
	}
	
	func saveKnownMembers(known:[Person]) throws {
		try encoder().encode(known).write(to:memberFile())
	}
	
	func saveVisitorState(active:[Visitor]) throws {
		try encoder().encode(active).write(to:activeFile())
	}
	
	func visitorState() throws -> [Visitor] {
		return try decoder().decode([Visitor].self, from:Data(contentsOf:activeFile()))
	}
	
	func membersFromConfiguration() throws -> [Person] {
		return try decoder().decode([Person].self, from:Data(contentsOf:memberFile()))
	}
	
	func record(csv:[String]) throws {
		let newline = "\r\n"
		let line = csv.joined(separator:",") + newline
		
		guard let data = line.data(using: .utf8) else { return }
		
		historyFile().fileAppend(data:data) {
			let line = ["Sign In", "Sign Out", "Access", "Name", "Birthdate"].joined(separator:",") + newline
			
			return line.data(using:.utf8)
		}
	}
	
	func csv(signIn:Date, signOut:Date?, access:Access, person:Person) -> [String] {
		let formatter = DateFormatter.rfc3339
		let signIn = formatter.string(from:signIn)
		let signOut = signOut != nil ? formatter.string(from:signOut!) : ""
		let access = access.rawValue
		let name = person.name.csvEscape
		let birthdate = DateFormatter.birthdate.string(from:person.birthdate)
		
		return [signIn, signOut, access, name, birthdate]
	}
}

extension String {
	var csvEscape:String { return "\"" + replacingOccurrences(of:"\"", with:"\"\"") + "\"" }
}

extension FileManager {
	var documentsDirectory:URL {
		return try! url(for:.documentDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
	}
	
	var cachesDirectory:URL {
		return try! url(for:.cachesDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
	}
	
	func document(path:String) -> URL {
		return URL(fileURLWithPath:path, relativeTo:documentsDirectory)
	}
}

extension URL {
	func fileAppend(data:Data, emptyFileHeaderData:(() -> Data?)? = nil) {
		let openStream = withUnsafeFileSystemRepresentation { fopen($0, "a") }
		
		guard let stream = openStream else { return }
		
		if let header = emptyFileHeaderData, ftello(stream) == 0, let data = header() {
			_ = data.withUnsafeBytes { fwrite($0.baseAddress, 1, $0.count, stream) }
		}
		
		_ = data.withUnsafeBytes { fwrite($0.baseAddress, 1, $0.count, stream) }
		
		fclose(stream)
	}
}

extension DispatchQueue {
	static var utility:DispatchQueue { return .global(qos:.utility) }
	static var background:DispatchQueue { return .global(qos:.background) }
}
