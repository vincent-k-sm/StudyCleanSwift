//
//  APIError.swift
//


import Foundation

struct APIError: Error {
    var error: String
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        return NSLocalizedString(self.error, comment: "")
    }
}
