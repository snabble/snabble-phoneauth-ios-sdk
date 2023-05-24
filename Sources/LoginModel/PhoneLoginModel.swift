//
//  PhoneLoginModel.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 18.01.23.
//

import Foundation
import Combine
import SnabbleNetwork

public protocol PhoneLoginProviding: AnyObject {
    /// The `Configuration` used for backend communication
    var configuration: Configuration { get }
    var phoneNumber: String? { get set }
    var oneTimePassword: String? { get set }
    var appUser: AppUser? { get set }
    
    func reset(deleteAccount: Bool)
}

public typealias PhoneLoginDelegate = CountryProviding & PhoneLoginProviding

/// The `PhoneLoginModel` manages  a login service by sending a phone number and receiving a OTP (One Time Password) via SMS. A user can login using this OTP. Once logged-in the account could be deleted on the backend by request. A logout() function will reset to the initial state. All stored info like phone number, pin code and appUser will be cleared.
/// 
/// The `PhoneLoginModel` can used as a viewModel to control the flow of:
/// * Registering by sending a phone number and request an OTP (One Time Password) via SMS `sendPhoneNumber()`
/// * Login to an account using a valid OTP `loginWithCode(_ code: String)`
/// * Logout from an account by reseting all locally stored data `logout()`
/// * Requesting the deletion of an account `deleteAccount()`
///
/// Typically a `PhoneLoginModel` will be created for different server environments, like `testing`, `stagig` or `production`.
/// The `Configuration` struct provides `appId` and `appSecret` configurations for these environments. An additional `projectID` specifies the concrete project providing the phone login workflow.
///
/// ```Swift
/// let loginModel = PhoneLoginModel(configuration: .testing, projectID: Configuration.projectId)
/// ```
///
open class PhoneLoginModel: ObservableObject {

    /// The country using the `CountryCallingCode` struct.
    @Published public var country: CountryCallingCode
    
    ///
    /// Typically you will bind this value to a TextField
    ///
    /// ```Swift
    /// TextField("Mobile #", text: $loginModel.phoneNumber)
    /// ```
    @Published public var phoneNumber: String = ""
    
    /// If an error occured the errorMessage is not empty. A user view should be informed about this message.
    @Published public var errorMessage: String = ""
    
    ///
    /// Typically you will bind this value to a TextField.
    ///
    /// ```Swift
    /// TextField("PIN Code", text: $loginModel.oneTimePassword)
    /// ```
    @Published public var oneTimePassword: String = ""
    
    /// Returns `true`  if a network request is running.
    @Published public var isWaiting: Bool = false
    
    /// The `state` can be
    /// * `.start` initial state. No phone number has been send to backend
    /// * `.registered` A phone number was send to backend
    /// * `.loggedIn` A otp was send to backend
    public enum State {
        case start
        case registered
        case loggedIn
    }
    
    @Published public var state: State = .start {
        willSet { if state != newValue { leaveState(state) }}
        didSet { if state != oldValue { enterState(state) }}
    }
    
    private var currentState: State {
        if !phoneNumber.isEmpty, !oneTimePassword.isEmpty {
            return appUser != nil ? .loggedIn : .registered
        }
        if !phoneNumber.isEmpty {
            return .registered
        }
        return .start
    }

    /// The Authenticator manages authentication and provide a new AppUser and need some information implmenting the `AuthenticatorDelegate` protocol.
    public var authenticator: Authenticator {
        return networkManager.authenticator
    }
    
    /// Returns `true` if the current wait timer is running.
    @Published public var spamTimerIsActive: Bool = false

    public weak var delegate: PhoneLoginDelegate? {
        didSet {
            phoneNumber = delegate?.phoneNumber ?? ""
            oneTimePassword = delegate?.oneTimePassword ?? ""
            state = currentState
        }
    }
    
    /// Returns the delegate's `AppUser`
    public var appUser: AppUser? {
        return delegate?.appUser
    }
    
    /// The `Configuration` used for backend communication
    var configuration: Configuration {
        guard let delegate = self.delegate else {
            fatalError("A delegate must be set")
        }
        return delegate.configuration
    }
    
    /// The internal `NetworkManager` providing network services to request OTP's for given phoneNumbers `sendPhoneNumber()` and handle `login()` to an account and request a deletion `deleteAccount()` of an acccount.
    private let networkManager: NetworkManager
    
    private var stateCancellable: AnyCancellable?
    private var loginCancellable: AnyCancellable?
    private var deleteCancellable: AnyCancellable?
    
    private let spamPublisher: Timer.TimerPublisher
    private var spamCancellable: AnyCancellable?

    /// Initialize a newly created instance
    /// - Parameter waitInterval: A `Double`interval to use by the waitTimer to prevent spamming
    public init(waitInterval: Double = 30.0) {
        self.country = CountryCallingCodes.defaultCountry
        
        self.networkManager = NetworkManager()
        self.spamPublisher = Timer.publish(every: waitInterval, tolerance: 0.5, on: .main, in: .default)

    }
    
    deinit {
        self.delegate = nil
    }
    
    public func reset(deleteAccount: Bool = false) {
        DispatchQueue.main.async {
            if self.spamTimerIsActive {
                self.stopSpamTimer()
            }
            self.phoneNumber = ""
            self.oneTimePassword = ""
            self.errorMessage = ""
            self.state = .start
            
            self.delegate?.reset(deleteAccount: deleteAccount)
        }
    }
    
    /// Start a timer to prevent spamming the backend for a SMS code request.
    public func startSpamTimer() {
        guard !spamTimerIsActive else {
            return
        }
       spamTimerIsActive = true
        
        spamCancellable = self.spamPublisher
            .autoconnect()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                self?.stopSpamTimer()
            })
    }

    /// Stop a current spam timer.
    public func stopSpamTimer() {
        spamCancellable = nil
        spamTimerIsActive = false
    }

}

extension PhoneLoginModel {
        
    /// Returns `true` if a phonenumber can be sent.
    public var canRequestCode: Bool {
        guard state == .start || state == .registered else {
            return false
        }
        guard phoneNumber.count > 2 else {
            return false
        }
        return true
    }

    /// Returns `true` if a the pinCode has a length of 6  and state is `.waitingForCode` or `.error`.
    public var canLogin: Bool {
        guard state == .registered, oneTimePassword.count == 6 else {
            return false
        }
        return true
    }
    
    /// Returns `true` if state is `.loggedIn`.
    public var isLoggedIn: Bool {
        return appUser != nil && state == .loggedIn
    }
}

extension PhoneLoginModel {
    /// Returns  a `String` formatted with the required backend format like `+49123456789`
    public var dialString: String {
        return country.dialString(self.phoneNumber)
    }
    
    /// Returns  a `String` formatted the country calling code with a preceiding plus sign and the entered phoneNumber separeated by a space (e.g: `+49 123456789`).
    public var phoneNumberPrettyPrint: String {
        return country.prettyPrint(self.phoneNumber)
    }
}

extension PhoneLoginModel {

    /// Try to send a phone number to the backend and requesting a OTP (One Time Password)
    public func sendPhoneNumber() {
        guard canRequestCode else {
            return
        }
        pushToServer()
    }

    /// Try to login with a given `String`
    /// - Parameters:
    ///   - string: The pinCode to use for the login request.
    public func loginWithCode(_ string: String) {
        guard canLogin else {
            return
        }
        sendCode(string)
    }

    /// Try to login with the var `pinCode`
    /// - Parameters:
    ///   - string: The pinCode to use for the login request.
   public func login() {
        loginWithCode(oneTimePassword)
    }

    /// Try to delete the current account
   public func deleteAccount() {
        guard let number = delegate?.phoneNumber, !number.isEmpty else {
            return
        }
        delete()
    }
    
    /// Logout the current user by calling `reset()`
    public func logout(deleteAccount: Bool = false) {
        reset(deleteAccount: deleteAccount)
    }

    /// Start the waitTimer to prevent spamming the backend for a SMS code request.
    private func startTimer() {
        guard !spamTimerIsActive else {
            return
        }
        startSpamTimer()
    }

    private func pushToServer() {

        let endpoint = Endpoints.Phone.auth(configuration: self.configuration, phoneNumber: dialString)

        errorMessage = ""
        isWaiting = true
        
        loginCancellable = networkManager.publisher(for: endpoint)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let strongSelf = self else { return }
                
                switch completion {
                case .finished:
                    strongSelf.startSpamTimer()
                    strongSelf.delegate?.phoneNumber = strongSelf.phoneNumber

                case .failure(let error):
                    strongSelf.errorMessage = error.localizedDescription
                }
                strongSelf.isWaiting = false
                strongSelf.state = strongSelf.currentState

            } receiveValue: { _ in
            }
    }
        
    private func sendCode(_ otp: String) {
        let endpoint = Endpoints.Phone.login(configuration: self.configuration, phoneNumber: dialString, OTP: otp)

        errorMessage = ""
        isWaiting = true
        
        loginCancellable = networkManager.publisher(for: endpoint)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let strongSelf = self else { return }
            
                switch completion {
                case .finished:
                    strongSelf.oneTimePassword = otp
                    strongSelf.delegate?.oneTimePassword = otp
                    strongSelf.state = .loggedIn

                case .failure(let error):
                    strongSelf.oneTimePassword = ""
                    strongSelf.delegate?.oneTimePassword = nil
                    strongSelf.errorMessage = error.localizedDescription
                    strongSelf.state = strongSelf.currentState

                }
                strongSelf.isWaiting = false

            } receiveValue: { _ in
            }
    }
    
    private func delete() {
        
        let endpoint = Endpoints.Phone.delete(configuration: self.configuration, phoneNumber: dialString)
        
        errorMessage = ""
        isWaiting = true
        
        deleteCancellable = networkManager.publisher(for: endpoint)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let strongSelf = self else { return }
            
                switch completion {
                case .finished:
                    strongSelf.logout(deleteAccount: true)

                case .failure(let error):
                    strongSelf.errorMessage = error.localizedDescription
                }
                
                strongSelf.isWaiting = false
                strongSelf.state = strongSelf.currentState
            } receiveValue: { _ in
            }
    }
}

public protocol StateChanging {
    func leaveState(_ state: PhoneLoginModel.State)
    func enterState(_ state: PhoneLoginModel.State)
}

// MARK: - State changes
extension PhoneLoginModel: StateChanging {
    
    public func leaveState(_ state: PhoneLoginModel.State) {
        guard let stateDelegate = self.delegate as? any StateChanging else {
            return
        }
        stateDelegate.leaveState(state)
    }
    
    public func enterState(_ state: PhoneLoginModel.State) {
        if let stateDelegate = self.delegate as? any StateChanging {
            stateDelegate.enterState(state)
        }
    }
}
