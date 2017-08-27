import Foundation

public class ReachabilityManager {
    
    public static var shared = ReachabilityManager()
    
    func checkReachability(route: Route) throws {
        #if os(iOS) || os(OSX) || os(tvOS)
            let url = try route.getURL()
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
