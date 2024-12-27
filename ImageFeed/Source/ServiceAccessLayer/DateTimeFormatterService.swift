//
//  DateTimeFormatterService.swift
//  ImageFeed
//
//  Created by Ilia Liasin on 25/12/2024.
//

import Foundation

final class DateFormatterService {
    
    // MARK: - Shared Instance
    static let shared = DateFormatterService()
    
    // MARK: - Private Properties
    private let dateFormatter: DateFormatter
    private let isoFormatter: ISO8601DateFormatter
    
    // MARK: - Initializer
    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        isoFormatter = ISO8601DateFormatter()
    }
    
    // MARK: - Public Methods
    func format(_ date: Date?) -> String {
        guard let date else { return "" }
        return dateFormatter.string(from: date)
    }
    
    func parse(_ dateString: String) -> Date? {
        return dateFormatter.date(from: dateString)
    }
    
    func isoFormat(_ date: Date?) -> String {
        guard let date else { return "" }
        return isoFormatter.string(from: date)
    }
    
    func isoParse(_ dateString: String?) -> Date? {
        guard let dateString else { return nil }
        return isoFormatter.date(from: dateString)
    }
}
