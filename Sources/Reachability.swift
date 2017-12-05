#if os(iOS) || os(OSX) || os(tvOS)
    import Foundation
    import SystemConfiguration
    
    private let reachabilityQueue = DispatchQueue(label: "com.apic.ReachabilityQueue", attributes: [])
    private let syncQueue = DispatchQueue(label: "com.apic.SyncQueue", attributes: [])
    
    public enum ReachabilityError: Error {
        case invalidURL
        case inicializationError
    }
    
    public class Reachability {
        
        fileprivate static var reachabilityInfo = [String: HostReachabilityInfo]()
        
        public class func isConnectedToNetwork() -> Bool {
            guard let flags = getFlags() else { return false }
            let isReachable = flags.contains(.reachable)
            let needsConnection = flags.contains(.connectionRequired)
            return (isReachable && !needsConnection)
        }
        
        @available(iOS 9.0, OSX 10.11, *)
        public class func isConnectedToWiFi() -> Bool {
            guard let flags = getFlags() else { return false }
            let isReachable = flags.contains(.reachable)
            let needsConnection = flags.contains(.connectionRequired)
            #if os(iOS)
                let isWiFi = !flags.contains(.isWWAN)
                return isReachable && !needsConnection && isWiFi
            #else
                return isReachable && !needsConnection
            #endif
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
            
            return withUnsafePointer(to: &zeroAddress, body())
        }
        
        private class func ipv4Reachability() -> SCNetworkReachability? {
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            zeroAddress.sin_family = sa_family_t(AF_INET)
            
            return withUnsafePointer(to: &zeroAddress, body())
        }
        
        private class func body<T>() -> (UnsafePointer<T>) -> SCNetworkReachability? {
            return {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    SCNetworkReachabilityCreateWithAddress(nil, $0)
                }
            }
        }
        
        public static func reachabilityInfo(forURL url: URL) throws -> HostReachabilityInfo {
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                let host = components.host else {
                throw ReachabilityError.invalidURL
            }
            if let info = Reachability.reachabilityInfo[host] {
                return info
            }
            
            var trackingError: Error?
            syncQueue.sync(execute: {
                do {
                    Reachability.reachabilityInfo[host] = try startTracking(host: host)
                } catch {
                    trackingError = error
                }
            })
            if let info = Reachability.reachabilityInfo[host] {
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
            var context = SCNetworkReachabilityContext(version: 0, info: bridge(reachabilityInfo),
                                                       retain: nil, release: nil, copyDescription: nil)
            if SCNetworkReachabilitySetCallback(reachability, { (reachability, flags, info) in
                HostReachabilityInfo.from(pointer: info)?.flags = flags
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
    
    extension HostReachabilityInfo {
        static func from(pointer: UnsafeMutableRawPointer?) -> HostReachabilityInfo? {
            if let pointer = pointer {
                return Unmanaged<HostReachabilityInfo>.fromOpaque(pointer).takeUnretainedValue()
            }
            return nil
        }
    }
    
#endif
