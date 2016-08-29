//
//  Reachability.swift
//  Apic
//
//  Created by Juan Jose Arreola on 1/24/16.
//

#if os(iOS) || os(OSX) || os(tvOS)
import Foundation
import SystemConfiguration
    
    private let reachabilityQueue: DispatchQueue = DispatchQueue(label: "com.apic.ReachabilityQueue", attributes: [])
    private let syncQueue: DispatchQueue = DispatchQueue(label: "com.apic.SyncQueue", attributes: [])
    
    public enum ReachabilityError: Error {
        case invalidURL
        case inicializationError
    }
    
    open class HostReachabilityInfo {
        open let host: String
        fileprivate let networkReachability: SCNetworkReachability
        open fileprivate(set) var flags: SCNetworkReachabilityFlags?
        
        init(host: String, networkReachability: SCNetworkReachability) {
            self.host = host
            self.networkReachability = networkReachability
        }
        
        open var isReachable: Bool? {
            if let flags = flags {
                return flags.rawValue & UInt32(kSCNetworkFlagsReachable) != 0
            }
            return nil
        }
        
        deinit {
            SCNetworkReachabilitySetCallback(networkReachability, nil, nil)
            SCNetworkReachabilitySetDispatchQueue(networkReachability, nil)
        }
    }

open class Reachability {
    
    fileprivate static var reachabilityInfo = [String: HostReachabilityInfo]()
    
    open class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    open static func reachabilityInfoForURL(_ url: URL) throws -> HostReachabilityInfo {
        
        var reachabilityInfo: HostReachabilityInfo?
        var trackingError: Error?
        
        syncQueue.sync(execute: {
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                trackingError = ReachabilityError.invalidURL
                return
            }
            guard let host = components.host else {
                trackingError = ReachabilityError.invalidURL
                return
            }
            if let info = Reachability.reachabilityInfo[host] {
                reachabilityInfo = info
            } else {
                do {
                    //reachabilityInfo = try startTrackingHost(host)
                    Reachability.reachabilityInfo[host] = reachabilityInfo
                } catch {
                    trackingError = error
                }
            }
        })
        
        if let info = reachabilityInfo {
            return info
        }
        if let error = trackingError {
            throw error
        }
        throw ReachabilityError.inicializationError
        
    }
    
    fileprivate static func getReachabilityInfoForHost(_ host: String) -> HostReachabilityInfo? {
        var info: HostReachabilityInfo?
        reachabilityQueue.sync {
            info = Reachability.reachabilityInfo[host]
        }
        return info
    }
    
    //open static func startTrackingHost(_ host: String) throws -> HostReachabilityInfo {
        //guard let reachability = SCNetworkReachabilityCreateWithName(nil, (host as NSString).utf8String!) else {
        //    throw ReachabilityError.inicializationError
        //}
        //let reachabilityInfo = HostReachabilityInfo(host: host, networkReachability: reachability)
        //let reachabilityInfoRef = bridge(reachabilityInfo)
        //var context = SCNetworkReachabilityContext(version: 0, info: reachabilityInfoRef, retain: nil, release: nil, copyDescription: nil)
        //if SCNetworkReachabilitySetCallback(reachability, { (reachability, flags, info) in
            //let reachabilityInfo = Unmanaged<HostReachabilityInfo>.fromOpaque(OpaquePointer(info)!).takeUnretainedValue()
            //reachabilityInfo.flags = flags
            //}, &context) {
            //    if !SCNetworkReachabilitySetDispatchQueue(reachability, reachabilityQueue) {
            //        throw ReachabilityError.inicializationError
            //    }
            //return reachabilityInfo
        //} else {
        //    throw ReachabilityError.inicializationError
        //}
    //}
    
    //fileprivate static func bridge<T : AnyObject>(_ obj : T) -> UnsafeMutableRawPointer {
    //    return UnsafeMutablePointer(Unmanaged.passUnretained(obj).toOpaque())
    //}
}

#endif
