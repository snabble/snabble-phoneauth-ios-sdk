//
//  PhoneLoginModel.swift
//  PhoneLogin
//
//  Created by Uwe Tilemann on 18.01.23.
//

import Foundation
import Combine
import SnabbleNetwork

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
public class PhoneLoginModel: ObservableObject {

    /// The country using the `CountryCallingCode` struct. If `UserDefaults.selectedCountry` is set to a valid country code e.g. "DE" this will use to create a `CountryCallingCode`.
    @Published public var country: CountryCallingCode {
        didSet {
            UserDefaults.selectedCountry = country.countryCode
        }
    }
    
    ///
    /// Typically you will bind this value to a TextField
    ///
    /// ```Swift
    /// TextField("Mobile #", text: $loginModel.phoneNumber)
    /// ```
    @Published public var phoneNumber: String = ""
    
    /// If an error occured the errorMessage is not empty. A user view should be informed about this message.
    @Published public var errorMessage: String = "" {
        didSet {
            if !errorMessage.isEmpty {
                if self.logActions {
                    ActionLogger.shared.add(log: LogAction(action: "error", info: errorMessage))
                }
                print("error received: \(errorMessage)")
            }
        }
    }
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

    /// The current valid `AppUser` or nil if not yet set or the `reset()` function was called.
    /// The appUser will set by implementing the `AuthenticatorDelegate` protocol.
    public private(set) var appUser: AppUser? {
        didSet {
            if appUser?.id != UserDefaults.appUser?.id {
                DispatchQueue.main.async {
                    if self.logActions {
                        if let user = self.appUser {
                            ActionLogger.shared.add(log: LogAction(action: "appID", info: user.id))
                        } else {
                            ActionLogger.shared.add(log: LogAction(action: "remove appID"))
                        }
                    }
                    UserDefaults.appUser = self.appUser
                }
            }
        }
    }
    
    /// The `Configuration` used for backend communication
    let configuration: Configuration
    /// A `String`with the project identifier used for backend communication
    let projectID: String
    
#if DEBUG
    /// Logging `LogActions` is enabled by default for `DEBUG` mode.
    public var logActions = true
#else
    /// Logging `LogActions` is enabled by default for `DEBUG` mode.
    public var logActions = false
#endif

    /// The internal `StateMachine` controlling the flow
    private let stateMachine: StateMachine
    
    /// The internal `NetworkManager` providing network services to request OTP's for given phoneNumbers `sendPhoneNumber()` and handle `login()` to an account and request a deletion `deleteAccount()` of an acccount.
    private let networkManager: NetworkManager
    
    private var stateCancellable: AnyCancellable?
    private var loginCancellable: AnyCancellable?
    private var deleteCancellable: AnyCancellable?
    
    /// Initialize a newly created instance
    /// - Parameter configuration: The `Configuration` used for backend communication
    /// - Parameter projectID: A `String`with the project identifier used for backend communication
    /// - Parameter logActions: A `Bool` flag if running actions should be logged
    /// - Parameter waitInterval: A `Double`interval to use by the waitTimer to prevent spamming
    public init(configuration: Configuration, projectID: String, logActions: Bool? = nil, waitInterval: Double = 30.0) {

        self.projectID = projectID
        self.country = CountryCallingCodes.defaultCountry
        
        if let savedCountry = UserDefaults.selectedCountry, let country = CountryCallingCodes.country(for: savedCountry) {
            self.country = country
        }
        self.configuration = configuration
        self.networkManager = NetworkManager()
        
        if let flag = logActions {
            self.logActions = flag
        }
        
        let stateMachine: StateMachine
        
        if let number = UserDefaults.phoneNumber, !number.isEmpty {
            phoneNumber = number
            stateMachine = StateMachine(state: .waitingForCode)
        } else {
            stateMachine = StateMachine(state: .start)
        }
        self.stateMachine = stateMachine
        self.state = stateMachine.state
        
        self.waitTimer = WaitTimer(interval: waitInterval)

        self.appUser = UserDefaults.appUser

        self.stateCancellable = stateMachine.statePublisher.sink { state in
            self.state = state
        }
        if self.logActions, let appUser = self.appUser {
            ActionLogger.shared.add(log: LogAction(action: "appID", info: appUser.id))
        }
        self.authenticator.delegate = self
    }
    
    public func reset() {
        if timerIsRunning {
            waitTimer.stop()
        }
        self.appUser = nil
        self.phoneNumber = ""
        self.pinCode = ""
        self.errorMessage = ""
        UserDefaults.phoneNumber = nil

        stateMachine.tryEvent(.enterPhoneNumber)
    }
}

extension PhoneLoginModel: AuthenticatorDelegate {
    /// Provide the `Authenticator` with a stored AppUser struct or nil if not yet exists or was resetted.
    public func authenticator(_ authenticator: SnabbleNetwork.Authenticator, appUserForConfiguration configuration: SnabbleNetwork.Configuration) -> SnabbleNetwork.AppUser? {
        self.appUser
    }
    
    /// make sure to store/save an updated `AppUser`
    public func authenticator(_ authenticator: SnabbleNetwork.Authenticator, appUserUpdated appUser: SnabbleNetwork.AppUser) {
        self.appUser = appUser
    }
    
    /// Provide the `Authenticator` with a project identifier.
    public func authenticator(_ authenticator: SnabbleNetwork.Authenticator, projectIdForConfiguration configuration: SnabbleNetwork.Configuration) -> String {
        self.projectID
    }
}

extension PhoneLoginModel {
    
    /// Returns `true` if a non empty phone number is stored in UserDefaults
    public var codeWasSendOnce: Bool {
        guard let string = UserDefaults.phoneNumber else {
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
        if logActions {
            ActionLogger.shared.add(log: LogAction(action: "request code for", info: "\(dialString)"))
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
        
        if logActions {
            ActionLogger.shared.add(log: LogAction(action: "Login with OTP", info: "\(pinCode)"))
        }
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
        guard UserDefaults.appUser != nil, let number = UserDefaults.phoneNumber, !number.isEmpty else {
            return
        }
        if logActions {
            ActionLogger.shared.add(log: LogAction(action: "Deleting Account", info: "\(dialString)"))
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
        
        if logActions {
            ActionLogger.shared.add(log: LogAction(action: "deleting account..."))
        }
        let endpoint = Endpoints.Phone.delete(configuration: self.configuration, phoneNumber: dialString)
        
        deleteCancellable = networkManager.publisher(for: endpoint)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let strongSelf = self else { return }
            
                switch completion {
                case .finished:
                    ActionLogger.shared.add(log: LogAction(action: "Account deleted"))
                    strongSelf.logout()

                case .failure(let error):
                    strongSelf.errorMessage = error.localizedDescription
                    strongSelf.stateMachine.tryEvent(.failure)
                }
                
            } receiveValue: { _ in
            }
    }
}

// MARK: - State changes
extension PhoneLoginModel {

    func leaveState(_ state: StateMachine.State) {
        if logActions {
            ActionLogger.shared.add(log: LogAction(action: "leave state", info: "\(state)"))
        }
    }
    
    func enterState(_ state: StateMachine.State) {
        if logActions {
            ActionLogger.shared.add(log: LogAction(action: "enter state", info: "\(state)"))
        }
        
        if case .waitingForCode = state {
            UserDefaults.phoneNumber = self.phoneNumber
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
