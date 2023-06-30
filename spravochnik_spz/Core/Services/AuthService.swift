//
//  AuthService.swift
//  spravochnik_spz
//
//  Created by Николай Чунихин on 15.05.2023.
//

import UIKit

enum TypeAuth {
    case email
    case google
    case apple
}

protocol AuthServicable {
    func isAuth() -> Bool
    func loginUser(with userRequest: LoginUserRequest?,
                   typeAuth: TypeAuth,
                   viewController: UIViewController?,
                   completion: @escaping (Error?) -> Void)
    func registerUser(with userRequest: RegisterUserRequest?,
                      completion: @escaping (Bool, Error?) -> Void)
    func logout(completion: @escaping (Error?) -> Void)
}

final class AuthService {
    private let eMailProvider: EmailProviderable
    private let appleProvider: AppleProviderable
    private let googleProvider: GoogleProviderable
    private let defaultsManager: DefaultsManagerable
    
    init(defaultsManager: DefaultsManagerable) {
        self.eMailProvider = EmailProvider()
        self.appleProvider = AppleProvider()
        self.googleProvider = GoogleProvider()
        self.defaultsManager = defaultsManager
    }
}

extension AuthService: AuthServicable {
    
    func isAuth() -> Bool {
        return eMailProvider.isAuth()
//        defaultsManager.fetchObject(type: Bool.self,
//                                    for: .isUserAuth) ?? false
    }
    
    func loginUser(with userRequest: LoginUserRequest?,
                   typeAuth: TypeAuth,
                   viewController: UIViewController?,
                   completion: @escaping (Error?) -> Void) {
        switch typeAuth {
        case .email:
            guard let userRequest = userRequest else { return }
            eMailProvider.loginUser(with: userRequest,
                                    completion: completion)
        case .google:
            guard let viewController = viewController else { return }
            googleProvider.signIn(completion: completion,
                                  viewController: viewController)
        case .apple:
            appleProvider.handleAppleIdRequest(completion: completion)
        }
    }
    
    func registerUser(with userRequest: RegisterUserRequest?,
                      completion: @escaping (Bool, Error?) -> Void) {
        guard let userRequest = userRequest else { return }
        self.eMailProvider.registerUser(with: userRequest,
                                        completion: completion)
    }
    
    func logout(completion: @escaping (Error?) -> Void) {
        self.eMailProvider.logout(completion: completion)
        self.defaultsManager.saveObject(false, for: .isUserAuth)
    }
}
