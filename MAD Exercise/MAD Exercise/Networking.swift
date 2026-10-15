//
//  Networking.swift
//  MAD Exercise
//

import Foundation

final class Networking {
    private let session = URLSession(configuration: .default)
    private let apiKey = "AIzaSyDeLs8S6Hpy642JUPC3Pft-xVx8Ocs-uXY"

    func login(email: String, password: String) {
        let url = URL(string: "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=\(apiKey)")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "email": email,
            "password": password,
            "returnSecureToken": true
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print(NetworkingError.serializationFailed)
            return
        }

        let task = session.dataTask(with: request) { data, response, error in
            // Transport-level failure: the request never got a response at all.
            if let error = error as NSError? {
                switch error.code {
                case URLError.notConnectedToInternet.rawValue,
                     URLError.networkConnectionLost.rawValue,
                     URLError.timedOut.rawValue:
                    print(NetworkingError.networkUnavailable(error.localizedDescription))
                default:
                    print(NetworkingError.unknown(error.localizedDescription))
                }
                return
            }

            guard let data, let httpResponse = response as? HTTPURLResponse else {
                print(NetworkingError.unexpectedResponseFormat)
                return
            }

            if (200..<300).contains(httpResponse.statusCode) {
                guard let user = try? JSONDecoder().decode(User.self, from: data) else {
                    print(NetworkingError.unexpectedResponseFormat)
                    return
                }
                print(user)
                return
            }

            guard let responseError = try? JSONDecoder().decode(ResponseError.self, from: data) else {
                print(NetworkingError.serverError(httpResponse.statusCode))
                return
            }

            switch responseError.message {
            case "INVALID_EMAIL":
                print(NetworkingError.invalidEmailFormat)
            case "EMAIL_NOT_FOUND":
                print(NetworkingError.emailNotFound)
            case "INVALID_PASSWORD":
                print(NetworkingError.wrongPassword)
            case "INVALID_LOGIN_CREDENTIALS":
                print(NetworkingError.invalidCredentials)
            default:
                print(NetworkingError.serverError(httpResponse.statusCode))
            }
        }
        task.resume()
    }
}
