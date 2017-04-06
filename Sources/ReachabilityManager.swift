//
//  ReachabilityManager.swift
//  Apic
//
//  Created by Juan Jose Arreola on 06/04/17.
//
//

import Foundation

public class ReachabilityManager {
    
    public static var shared = ReachabilityManager()
    
    func checkReachability(url: URL) throws {
        #if os(iOS) || os(OSX) || os(tvOS)
            guard let info = try? Reachability.reachabilityInfo(forURL: url) else {
                return
            }
            guard let reachable = info.isReachable else {
                return
            }
            if !reachable {
                throw RepositoryError.networkConnection
            }
        #endif
    }
}
