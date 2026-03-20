//
//  CodableUserDefault.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 23/03/25.
//

@propertyWrapper
public struct CodableUserDefault<T: Codable> {
    
    let key: String
    let defaultValue: T
    let suiteName: String?
    
    public init(
        _ key: String,
        defaultValue: T,
        suiteName: String? = nil
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.suiteName = suiteName
    }
    
    public var wrappedValue: T {
        get {
            let defaults = suiteName != nil ? UserDefaults(
                suiteName: suiteName!
            ): UserDefaults.standard
            
            guard let data = defaults?.data(forKey: key) else {
                return defaultValue
            }
            
            return (
                try? JSONDecoder().decode(T.self, from: data)
            ) ?? defaultValue
        }
        set {
            let defaults = suiteName != nil ? UserDefaults(
                suiteName: suiteName!
            ): UserDefaults.standard
            
            let encoded = try? JSONEncoder().encode(newValue)
            
            defaults?.set(encoded, forKey: key)
        }
    }
}
