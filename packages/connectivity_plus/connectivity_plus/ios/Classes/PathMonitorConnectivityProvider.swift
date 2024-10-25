import Foundation
import Network

@available(iOS 12, *)
public class PathMonitorConnectivityProvider: NSObject, ConnectivityProvider {

  private let queue = DispatchQueue.global(qos: .background)

  private var _pathMonitor: NWPathMonitor?

  private func connectivityFrom(path: NWPath) -> ConnectivityType {
    if path.status == .satisfied {
      if path.usesInterfaceType(.wifi) {
        return .wifi
      } else if path.usesInterfaceType(.cellular) {
        return .cellular
      } else if path.usesInterfaceType(.wiredEthernet) {
        return .wiredEthernet
      } else if path.usesInterfaceType(.other) {
        return .other
      }
    }
    return .none
  }

  public var currentConnectivityTypes: ConnectivityType {
    let path = ensurePathMonitor().currentPath
    return connectivityFrom(path: path)
  }

  public var connectivityUpdateHandler: ConnectivityUpdateHandler?

  override init() {
    super.init()
    _ = ensurePathMonitor()
  }

  public func start() {
    _ = ensurePathMonitor()
  }

  public func stop() {
    _pathMonitor?.cancel()
    _pathMonitor = nil
  }

  @discardableResult
  private func ensurePathMonitor() -> NWPathMonitor {
    if (_pathMonitor == nil) {
      let pathMonitor = NWPathMonitor()
      pathMonitor.start(queue: queue)
      pathMonitor.pathUpdateHandler = pathUpdateHandler
      _pathMonitor = pathMonitor
    }
    return _pathMonitor!
  }

  private func pathUpdateHandler(path: NWPath) {
    connectivityUpdateHandler?(connectivityFrom(path: path))
  }
}
