//
//  LightweightReactive.swift
//  LightweightReactive
//
//  Created by Hidemune Takahashi on 9/17/17.
//  Copyright © 2017 Hidemune Takahashi. All rights reserved.
//

import Foundation

public class LightweightReactive: NSObject {
    public typealias Closure = (_ keyPath: String?, _ object: Any?, _ change: [NSKeyValueChangeKey : Any]?, _ context:
        UnsafeMutableRawPointer?) -> Void
    
    public static let lr = LightweightReactive()
    
    private typealias KeyPathAndClosure = [String : Closure]
    
    private var objectAndKeyPathClosure: [NSObject: KeyPathAndClosure] = [:]
    
    private override init() {
        
    }
    
    public func registObserve(source: NSObject, keyPath: String, options: NSKeyValueObservingOptions = [], context: UnsafeMutableRawPointer?, closure: LightweightReactive.Closure?) {
        source.addObserver(self, forKeyPath: keyPath, options: options, context: context)
        
        registClosureOf(source: source, keyPath: keyPath, closure: closure)
    }

    public func removeObseving(source: NSObject, keypath: String) {
        source.removeObserver(self, forKeyPath: keypath)
        removeClosureOf(source: source, keyPath: keypath)
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath,
            let object = object else {
                return
        }
        guard let source = object as? NSObject,
            let closure = searchClosureOf(source: source, keyPath: keyPath) else {
            return
        }
        closure(keyPath, object, change, context)
    }
    
    private func registClosureOf(source: NSObject, keyPath: String, closure: LightweightReactive.Closure?) {
        if closure == nil {
            return
        }
        
        var keyPathAndClosure = KeyPathAndClosure()
        
        let extractedKeyPathAndClosure = objectAndKeyPathClosure[source]
        if let existExtractedKeyPathAndClosure = extractedKeyPathAndClosure {
            keyPathAndClosure = existExtractedKeyPathAndClosure
        }
        
        keyPathAndClosure[keyPath] = closure
        
        objectAndKeyPathClosure[source] = keyPathAndClosure
    }
    
    private func searchClosureOf(source: NSObject, keyPath: String) -> LightweightReactive.Closure? {
        guard let keyPathAndClosure = objectAndKeyPathClosure[source],
            let closure = keyPathAndClosure[keyPath] else {
                return nil
        }
        return closure
    }
    
    private func removeClosureOf(source: NSObject, keyPath: String) {
        guard var keyPathAndClosure = objectAndKeyPathClosure[source] else {
            return
        }
        
        keyPathAndClosure.removeValue(forKey: keyPath)
    }
}
