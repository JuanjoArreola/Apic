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

public class Reachability {
    
    fileprivate static var reachabilityInfo = [String: HostReachabilityInfo]()
    
    public class func isConnectedToNetwork() -> Bool {
        guard let flags = getFlags() else { return false }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    public class func isConnectedToWiFi() -> Bool {
        guard let flags = getFlags() else { return false }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let isWiFi = !flags.contains(.isWWAN)
        return (isReachable && !needsConnection && isWiFi)
    }
    
    private class func getFlags() -> SCNetworkReachabilityFlags? {
        guard let reachability = ipv4Reachability() ?? ipv6Reachability() else {
            return nil
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(reachability, &flags) {
            return nil
        }
        return flags
    }
    
    private class func ipv6Reachability() -> SCNetworkReachability? {
        var zeroAddress = sockaddr_in6()
        zeroAddress.sin6_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin6_family = sa_family_t(AF_INET6)
        
        return withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        })
    }
    
    private class func ipv4Reachability() -> SCNetworkReachability? {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        return withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        })
    }
    
    public static func reachabilityInfo(forURL url: URL) throws -> HostReachabilityInfo {
        
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
                    reachabilityInfo = try startTracking(host: host)
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
    
    public static func getReachabilityInfoForHost(_ host: String) -> HostReachabilityInfo? {
        var info: HostReachabilityInfo?
        reachabilityQueue.sync {
            info = Reachability.reachabilityInfo[host]
        }
        return info
    }
    
    public static func startTracking(host: String) throws -> HostReachabilityInfo {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, (host as NSString).utf8String!) else {
            throw ReachabilityError.inicializationError
        }
        let reachabilityInfo = HostReachabilityInfo(host: host, networkReachability: reachability)
        let reachabilityInfoRef = bridge(reachabilityInfo)
        var context = SCNetworkReachabilityContext(version: 0, info: reachabilityInfoRef, retain: nil, release: nil, copyDescription: nil)
        if SCNetworkReachabilitySetCallback(reachability, { (reachability, flags, info) in
            if let info = info {
                let reachabilityInfo = Unmanaged<HostReachabilityInfo>.fromOpaque(info).takeUnretainedValue()
                reachabilityInfo.flags = flags
            }
        }, &context) {
            return reachabilityInfo
        } else {
            throw ReachabilityError.inicializationError
        }
    }
    
    private static func bridge<T : AnyObject>(_ obj : T) -> UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer(Unmanaged.passRetained(obj).toOpaque())
    }
}

#endif
