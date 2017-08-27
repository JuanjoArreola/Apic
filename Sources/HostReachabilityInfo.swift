import Foundation

#if os(iOS) || os(OSX) || os(tvOS)
    import Foundation
    import SystemConfiguration
    
    open class HostReachabilityInfo {
        open let host: String
        fileprivate let networkReachability: SCNetworkReachability
        open internal(set) var flags: SCNetworkReachabilityFlags?
        
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
    
#endif
