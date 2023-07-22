//
//  Environment.swift
//  Spotimy
//
//  Created by Andreas Garcia on 2023-07-22.
//

import Foundation

struct Environment {
    static func value(for key: String) -> String {
        guard let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let plistXML = FileManager.default.contents(atPath: plistPath),
              let infoDictionary = try? PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: nil) as? [String: Any],
              let environmentDict = infoDictionary["LSEnvironment"] as? [String: Any],
              let value = environmentDict[key] as? String else {
            fatalError("Could not find environment variables in Info.plist.")
        }
        return value
    }
}
