//
//  Reachability.swift
//  Apic
//
//  Created by Juan Jose Arreola on 1/24/16.
// http://stackoverflow.com/questions/30743408/check-for-internet-connection-in-swift-2-ios-9
//

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Foundation
#endif

#if os(iOS) || os(OSX)
import SystemConfiguration

public class Reachability {
    
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
}
#endif