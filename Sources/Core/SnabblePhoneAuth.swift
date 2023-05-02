import Combine
import Foundation

/// The methods that you use to receive events from an associated SnabblePhoneAuth object
public protocol SnabblePhoneAuthDelegate: AnyObject {

//    /// Tells the delegate that the SnabblePhoneAuth did update the credentials
//    /// - Parameters:
//    ///   - snabblePay: The SnabblePhoneAuth object that received the updated credentials
//    ///   - credentials: The updated `Credentials`
//    func phoneAuth(_ phoneAuth: SnabblePhoneAuth, didUpdateCredentials credentials: Credentials?)
}

/// The object that you use integrate SnabblePhoneAuth
public enum SnabblePhoneAuth {
    public static let name: String = "Snabble Phone Authentication"

//    /// The network manager object that handles the network requests
//    let networkManager: NetworkManager
//
//    /// The environment which is used for all network requests
//    public var environment: Environment = .production
//
//    /// The delegate object to receive update events
//    public weak var delegate: SnabblePhoneAuthDelegate?
//
//    /// Identifier for you project
//    public var apiKey: String {
//        networkManager.authenticator.apiKey
//    }
//
//    /// `URLSession` which is used for all network requests
//    public var urlSession: URLSession {
//        networkManager.urlSession
//    }
//
//    /// An array of type-erasing cancellable objects
//    var cancellables = Set<AnyCancellable>()
//
//    /// The current debug level default value is `.info`
//    public static var logLevel: Logger.Level {
//        get {
//            Logger.shared.logLevel
//        }
//        set {
//            Logger.shared.logLevel = newValue
//        }
//
//    }
//
//    /// The object that you use for SnabblePay
//    /// - Parameters:
//    ///   - apiKey: The key to identify your project
//    ///   - credentials: User credentials if available otherwise these will be created and reported to you via `SnabblePayDelegate`
//    ///   - urlSession: `URLSession` which should be used for network requests. Default is `.shared`
//    public init(apiKey: String, credentials: Credentials?, urlSession: URLSession = .shared) {
//        self.networkManager = NetworkManager(
//            apiKey: apiKey,
//            credentials: credentials?.toDTO(),
//            urlSession: urlSession
//        )
//        self.networkManager.delegate = self
//    }
}
