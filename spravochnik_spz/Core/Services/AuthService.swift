//
//  AuthService.swift
//  spravochnik_spz
//
//  Created by Николай Чунихин on 15.05.2023.
//

import UIKit
import FirebaseAuth

enum TypeAuth {
    case email
    case google
    case apple
}

protocol AuthServicable {
    func isAuth() -> Bool
    func getUserName() -> String
    func loginUser(with userRequest: LoginUserRequest?,
                   typeAuth: TypeAuth,
                   viewController: UIViewController?,
                   completion: @escaping (Error?) -> Void)
    func registerUser(with userRequest: RegisterUserRequest?,
                      completion: @escaping (Bool, Error?) -> Void)
    func logout(completion: @escaping (Error?) -> Void)
    func deleteUser(completion: @escaping (Result<Void, Error>) -> Void)
}

final class AuthService {
    private let eMailProvider: EmailProviderable
    private let appleProvider: AppleProviderable
    private let googleProvider: GoogleProviderable
    private let defaultsManager: DefaultsManagerable
    private let firestore: FirebaseServiceProtocol
    
    init(defaultsManager: DefaultsManagerable,
         firestore: FirebaseServiceProtocol) {
        self.eMailProvider = EmailProvider(firestore: firestore)
        self.appleProvider = AppleProvider(firestore: firestore)
        self.googleProvider = GoogleProvider(firestore: firestore)
        self.defaultsManager = defaultsManager
        self.firestore = firestore
    }
}

extension AuthService: AuthServicable {
    func getUserName() -> String {
        guard let userId = Auth.auth().currentUser?.displayName else { return "" }
        return userId
    }
    
    
    func isAuth() -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else { return false }
        firestore.addUserID(userID: userId)
        return true
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
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch let error {
            completion(error)
        }
        self.defaultsManager.saveObject(false, for: .isUserAuth)
    }
    
    func deleteUser(completion: @escaping (Result<Void, Error>) -> Void) {
        let user = Auth.auth().currentUser

        user?.delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(Void()))
            }
        }
    }
}
