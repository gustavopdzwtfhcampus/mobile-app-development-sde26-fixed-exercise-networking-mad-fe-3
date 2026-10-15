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
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: [])

        let task = session.dataTask(with: request) { data, response, error in
            if let data {
                let httpResponse = response as! HTTPURLResponse
                if (200..<300).contains(httpResponse.statusCode) {
                    let user = try! JSONDecoder().decode(User.self, from: data)
                    print(user)
                } else {
                    let responseError = try! JSONDecoder().decode(ResponseError.self, from: data)
                    print(responseError)
                }
            }
            print(response as Any)
            print(error as Any)
        }
        task.resume()
    }
}
