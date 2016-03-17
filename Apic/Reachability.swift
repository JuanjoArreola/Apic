//
//  Reachability.swift
//  Apic
//
//  Created by Juan Jose Arreola on 1/24/16.
//

#if os(iOS) || os(OSX) || os(tvOS)
import Foundation
import SystemConfiguration
    
    private let reachabilityQueue: dispatch_queue_t = dispatch_queue_create("com.apic.ReachabilityQueue", DISPATCH_QUEUE_CONCURRENT)
    private let syncQueue: dispatch_queue_t = dispatch_queue_create("com.apic.SyncQueue", DISPATCH_QUEUE_CONCURRENT)
    
    public enum ReachabilityError: ErrorType {
        case InvalidURL
        case InicializationError
    }
    
    public class HostReachabilityInfo {
        public let host: String
        private let networkReachability: SCNetworkReachability
        public private(set) var flags: SCNetworkReachabilityFlags?
        
        init(host: String, networkReachability: SCNetworkReachability) {
            self.host = host
            self.networkReachability = networkReachability
        }
        
        public var isReachable: Bool? {
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
    
    private static var reachabilityInfo = [String: HostReachabilityInfo]()
    
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    public static func reachabilityInfoForURL(url: NSURL) throws -> HostReachabilityInfo {
        guard let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else {
            throw ReachabilityError.InvalidURL
        }
        guard let host = components.host else {
            throw ReachabilityError.InvalidURL
        }
        if let info = getReachabilityInfoForHost(host) {
            return info
        } else {
            var info: HostReachabilityInfo?
            var trackingError: ErrorType?
            dispatch_barrier_async(syncQueue) {
                do {
                    info = try startTrackingHost(host)
                    Reachability.reachabilityInfo[host] = info
                } catch {
                    trackingError = error
                }
            }
            if let error = trackingError {
                throw error
            }
            if let info = getReachabilityInfoForHost(host) {
                return info
            }
            throw ReachabilityError.InicializationError
        }
    }
    
    private static func getReachabilityInfoForHost(host: String) -> HostReachabilityInfo? {
        var info: HostReachabilityInfo?
        dispatch_sync(syncQueue) {
            info = Reachability.reachabilityInfo[host]
        }
        return info
    }
    
    public static func startTrackingHost(host: String) throws -> HostReachabilityInfo {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, (host as NSString).UTF8String) else {
            throw ReachabilityError.InicializationError
        }
        let reachabilityInfo = HostReachabilityInfo(host: host, networkReachability: reachability)
        let reachabilityInfoRef = bridge(reachabilityInfo)
        var context = SCNetworkReachabilityContext(version: 0, info: reachabilityInfoRef, retain: nil, release: nil, copyDescription: nil)
        if SCNetworkReachabilitySetCallback(reachability, { (reachability, flags, info) in
            let reachabilityInfo = Unmanaged<HostReachabilityInfo>.fromOpaque(COpaquePointer(info)).takeUnretainedValue()
            reachabilityInfo.flags = flags
            }, &context) {
                if !SCNetworkReachabilitySetDispatchQueue(reachability, reachabilityQueue) {
                    throw ReachabilityError.InicializationError
                }
            return reachabilityInfo
        } else {
            throw ReachabilityError.InicializationError
        }
    }
    
    private static func bridge<T : AnyObject>(obj : T) -> UnsafeMutablePointer<Void> {
        return UnsafeMutablePointer(Unmanaged.passUnretained(obj).toOpaque())
    }
}

#endif