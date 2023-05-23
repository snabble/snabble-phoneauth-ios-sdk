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
    var appUser: AppUser? { get set }
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

    /// The country using the `CountryCallingCode` struct. If `UserDefaults.selectedCountry` is set to a valid country code e.g. "DE" this will use to create a `CountryCallingCode`.
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
    /// To observe changes in the  flow use:
    ///
    /// ```Swift
    /// .onChange(loginModel.state) { newState in
    ///    // handle state
    /// }
    /// ```
    ///
    @Published public var state: StateMachine.State {
        willSet { leaveState(state) }
        didSet { enterState(state) }
    }
    
    ///
    /// Typically you will bind this value to a TextField.
    ///
    /// ```Swift
    /// TextField("PIN Code", text: $loginModel.pinCode)
    /// ```
    @Published public var pinCode: String = ""
    
    /// The Authenticator manages authentication and provide a new AppUser and need some information implmenting the `AuthenticatorDelegate` protocol.
    public var authenticator: Authenticator {
        return networkManager.authenticator
    }

    ///
    /// A `WaitTimer` which will be started after a code request was sent.
    ///
    /// A `WaitTimer` provides:
    ///
    /// ```Swift
    /// @Published public var startTime: Date?
    /// @Published public var endTime: Date?
    /// ```
    ///
    /// To observe changes use:
    ///
    /// ```Swift
    /// .onChange(loginModel.waitTimer.endTime) { newTime in
    ///     let started = newValue == nil
    ///
    ///     if started {
    ///         // disable request code button to prevent spamming
    ///     }
    /// }
    /// ```
    @Published public var waitTimer: WaitTimer

    public weak var delegate: PhoneLoginDelegate? {
        didSet {
            if let delegate = delegate {
                if let number = delegate.phoneNumber, !number.isEmpty {
                    phoneNumber = number
                    stateMachine = StateMachine(state: .waitingForCode)
                    self.state = stateMachine.state
               }
            }
        }
    }
    
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

    /// The internal `StateMachine` controlling the flow
    private var stateMachine: StateMachine
    
    /// The internal `NetworkManager` providing network services to request OTP's for given phoneNumbers `sendPhoneNumber()` and handle `login()` to an account and request a deletion `deleteAccount()` of an acccount.
    private let networkManager: NetworkManager
    
    private var stateCancellable: AnyCancellable?
    private var loginCancellable: AnyCancellable?
    private var deleteCancellable: AnyCancellable?
    
    /// Initialize a newly created instance
    /// - Parameter waitInterval: A `Double`interval to use by the waitTimer to prevent spamming
    public init(waitInterval: Double = 30.0) {
        self.country = CountryCallingCodes.defaultCountry
        
        self.networkManager = NetworkManager()
        self.waitTimer = WaitTimer(interval: waitInterval)

        self.stateMachine = StateMachine(state: .start)
        self.state = .start
        
        self.stateCancellable = stateMachine.statePublisher.sink { state in
            self.state = state
        }
    }
    
    deinit {
        self.delegate = nil
    }
    
    public func reset() {
        if timerIsRunning {
            waitTimer.stop()
        }
        self.phoneNumber = ""
        self.pinCode = ""
        self.errorMessage = ""
        
        stateMachine.reset(state: .start)
    }
}

extension PhoneLoginModel {
    
    /// Returns `true` if a non empty phone number is stored in UserDefaults
    public var codeWasSendOnce: Bool {
        guard let string = delegate?.phoneNumber else {
            return false
        }
        return !string.isEmpty
    }
    
    /// Returns `true` if a phone number can be sent and state is `.start`, `.waitingForCode` or `.error`.
    public var canSendPhoneNumber: Bool {
        guard phoneNumber.count > 2 else {
            return false
        }
        return [.start, .waitingForCode, .error].contains(state)  // state == .error || state == .start || state == .waitingForCode
    }
    
    /// Returns `true` if a the pinCode has a length of 6  and state is `.waitingForCode` or `.error`.
    public var canLogin: Bool {
        guard pinCode.count == 6 else {
            return false
        }
        return [.waitingForCode, .error].contains(state) // state == .error || state == .waitingForCode
    }

    /// Returns `true` if  state is `.loggedIn`.
    public var isLoggedIn: Bool {
        state == .loggedIn
    }
    
    /// Returns `true` if state is `.pushedToServer`, `.sendCode` or `.deletingAccount` indicating a running network request.
    public var isWaiting: Bool {
        [.pushedToServer, .sendCode, .deletingAccount].contains(state)
    }

    /// Returns `true` if the current `WaitTimer` is running.
    public var timerIsRunning: Bool {
        return waitTimer.isRunning
    }

    /// Returns `true` if a phonenumber can be sent and no `WaitTimer` is running.
    public var canRequestCode: Bool {
        if canSendPhoneNumber {
            guard !timerIsRunning else {
                return false
            }
            return true
        } else {
            return false
        }
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
        stateMachine.tryEvent(.sendingPhoneNumber)
    }

    /// Try to login with a given `String`
    /// - Parameters:
    ///   - string: The pinCode to use for the login request.
    public func loginWithCode(_ string: String) {
        guard canLogin else {
            return
        }
        pinCode = string
        stateMachine.tryEvent(.loggingIn)
    }

    /// Try to login with the var `pinCode`
    /// - Parameters:
    ///   - string: The pinCode to use for the login request.
   public func login() {
        loginWithCode(pinCode)
    }

    /// Try to delete the current account
   public func deleteAccount() {
        guard delegate?.appUser != nil, let number = delegate?.phoneNumber, !number.isEmpty else {
            return
        }
        stateMachine.tryEvent(.trashAccount)
    }
    
    /// Logout the current user by calling `reset()`
    public func logout() {
        reset()
    }

    /// Start the waitTimer to prevent spamming the backend for a SMS code request.
    public func startTimer() {
        guard !timerIsRunning else {
            return
        }
        waitTimer.start()
    }

    private func pushToServer() {

        let endpoint = Endpoints.Phone.auth(configuration: self.configuration, phoneNumber: dialString)
        
        loginCancellable = networkManager.publisher(for: endpoint)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let strongSelf = self else { return }
                
                switch completion {
                case .finished:
                    strongSelf.stateMachine.tryEvent(.sendingPhoneNumber)

                case .failure(let error):
                    strongSelf.errorMessage = error.localizedDescription
                    strongSelf.stateMachine.tryEvent(.failure)
                }

            } receiveValue: { _ in
            }
    }

    private func sendCode() {
        let endpoint = Endpoints.Phone.login(configuration: self.configuration, phoneNumber: dialString, OTP: pinCode)

        loginCancellable = networkManager.publisher(for: endpoint)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let strongSelf = self else { return }
            
                switch completion {
                case .finished:
                    strongSelf.stateMachine.tryEvent(.success)
                    
                case .failure(let error):
                    strongSelf.errorMessage = error.localizedDescription
                    strongSelf.stateMachine.tryEvent(.failure)
                }
                
            } receiveValue: { _ in
            }
    }
    
    private func delete() {
        
        let endpoint = Endpoints.Phone.delete(configuration: self.configuration, phoneNumber: dialString)
        
        deleteCancellable = networkManager.publisher(for: endpoint)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let strongSelf = self else { return }
            
                switch completion {
                case .finished:
                    strongSelf.logout()

                case .failure(let error):
                    strongSelf.errorMessage = error.localizedDescription
                    strongSelf.stateMachine.tryEvent(.failure)
                }
                
            } receiveValue: { _ in
            }
    }
}

public protocol StateChanging {
    func leaveState(_ state: StateMachine.State)
    func enterState(_ state: StateMachine.State)
}

// MARK: - State changes
extension PhoneLoginModel: StateChanging {

    public func leaveState(_ state: StateMachine.State) {
        guard let stateDelegate = self.delegate as? any StateChanging else {
            return
        }
        stateDelegate.leaveState(state)
    }
    
    public func enterState(_ state: StateMachine.State) {
        if let stateDelegate = self.delegate as? any StateChanging {
            stateDelegate.enterState(state)
        }
        
        if case .waitingForCode = state {
            delegate?.phoneNumber = self.phoneNumber
            startTimer()
        }
        if case .pushedToServer = state {
            errorMessage = ""
            pushToServer()
        }
        if case .sendCode = state {
            errorMessage = ""
            sendCode()
        }
        if case .deletingAccount = state {
            errorMessage = ""
            delete()
        }
   }
}
