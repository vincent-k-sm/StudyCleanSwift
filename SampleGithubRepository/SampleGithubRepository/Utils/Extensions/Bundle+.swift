//
//  Bundle+.swift
//


import Foundation

extension Bundle {
    
    func apiKey(plist fileName: String) -> String {
        var result: String = ""
        if let file = self.path(forResource: fileName, ofType: "plist"),
           let resource = NSDictionary(contentsOfFile: file),
           let key = resource["API_KEY"] as? String
        {
            result = key
        }
        
        return result
    }
    
}
