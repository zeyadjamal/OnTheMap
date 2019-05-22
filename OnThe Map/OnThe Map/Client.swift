//
//  Client.swift
//  OnThe Map
//
//  Created by zico on 5/17/19.
//  Copyright © 2019 mansoura Unversity. All rights reserved.
//

import Foundation
class API{
    static var userInfo = UserInfo()
    static var sessionId: String?
    
    static func postSession(username: String, password: String, completion: @escaping (String?)->Void) {
        guard let url = URL(string: APIConstants.SESSION) else {
            completion("Supplied url is invalid")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            var errString: String?
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode >= 200 && statusCode < 300 {
                    
                    let newData = data?.subdata(in: 5..<data!.count)
                    if let json = try? JSONSerialization.jsonObject(with: newData!, options: []),
                        let dict = json as? [String:Any],
                        let sessionDict = dict["session"] as? [String: Any],
                        let accountDict = dict["account"] as? [String: Any]  {
                        
                        self.userInfo.key = accountDict["key"] as? String
                        self.sessionId = sessionDict["id"] as? String
                        getUserInfo(completion: { (firstName, LastName) in
                            self.userInfo.firstName = firstName
                            self.userInfo.lastName = LastName
                        })
                        
                        
                    } else {
                        errString = "Couldn't parse response"
                    }
                } else {
                    errString = "Provided login credintials didn't match our records"
                }
            } else {
                errString = "Check your internet connection"
            }
            DispatchQueue.main.async {
                completion(errString)
            }
            
        }
        task.resume()
    }
    
    static func deleteSession(compeletion: @escaping (String?)->Void){
        guard let url = URL(string: APIConstants.SESSION) else{
            compeletion("supplied url is invalid")
            return
        }
        var request = URLRequest(url: url)
        var xsrfCookie:HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies!{
            if cookie.name == "XSRF-TOKEN" {xsrfCookie = cookie}
        }
        if let xsrfCookie = xsrfCookie{
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request){ data,respond,error in
            if error != nil{
                return
            }
            let newData = data?.subdata(in: 5..<data!.count)
            
            DispatchQueue.main.async {
                compeletion(nil)
            }
        }
        task.resume()
    }
    static func getUserInfo(completion: @escaping (String?,String?)->Void) {
        guard let userId = self.userInfo.key,let url = URL(string: "\(APIConstants.PUBLIC_USER)/\(userId)") else{
            completion(nil,nil)
            return
        }
        var request = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request){ data, response, error in
            var firstName:String?,lastName : String?,nickname:String = ""
            if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode < 400{
                let newData = data?.subdata(in: 5 ..< data!.count)
                if let json = try? JSONSerialization.jsonObject(with: newData!, options: [.allowFragments]),
                    let dict = json as? [String:Any]
                {
                    
                    nickname = dict["nickname"] as? String ?? ""
                    firstName = dict["first_name"] as? String ?? nickname
                    lastName = dict["last_name"] as? String ?? nickname
                    
                    self.userInfo.firstName = firstName
                    self.userInfo.lastName = lastName
                    
                }
            }
            DispatchQueue.main.async {
                completion(firstName, lastName)
            }
        }
        task.resume()
    }
    
    
    class Parser {
        
        static func getStudentLocations(limit: Int = 100, skip: Int = 0, orderBy: SLParam = .updatedAt, completion: @escaping (LocationsData?)->Void) {
            guard let url = URL(string: "\(APIConstants.STUDENT_LOCATION)?\(APIConstants.ParameterKeys.LIMIT)=\(limit)&\(APIConstants.ParameterKeys.SKIP)=\(skip)&\(APIConstants.ParameterKeys.ORDER)=-\(orderBy.rawValue)") else {
                completion(nil)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue(APIConstants.HeaderValues.PARSE_APP_ID, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_APP_ID)
            request.addValue(APIConstants.HeaderValues.PARSE_API_KEY, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_API_KEY)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                var studentLocations: [StudentLocation] = []
                if let statusCode = (response as? HTTPURLResponse)?.statusCode { //Request sent succesfully
                    if statusCode >= 200 && statusCode < 300 { //Response is ok
                        
                        if let json = try? JSONSerialization.jsonObject(with: data!, options: []),
                            let dict = json as? [String:Any],
                            let results = dict["results"] as? [Any] {
                            
                            for location in results {
                                let data = try! JSONSerialization.data(withJSONObject: location)
                                let studentLocation = try! JSONDecoder().decode(StudentLocation.self, from: data)
                                studentLocations.append(studentLocation)
                            }
                            
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    completion(LocationsData(studentLocations: studentLocations))
                }
                
            }
            task.resume()
        }
        
        static func postLocation(_ location: StudentLocation, completion: @escaping (String?)->Void) {
            guard let accountId = userInfo.key, let url = URL(string: "\(APIConstants.STUDENT_LOCATION)") else{
                completion("invalid URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue(APIConstants.HeaderValues.PARSE_APP_ID, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_APP_ID)
            request.addValue(APIConstants.HeaderValues.PARSE_API_KEY, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_API_KEY)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            guard let firstName = userInfo.firstName,let lastName = userInfo.lastName,let mapString = location.mapString,let mediaURL = location.mediaURL,let latitude = location.latitude,let longitude = location.longitude else {
                completion("invalid Attributes")
                return
            }
            request.httpBody = "{\"uniqueKey\":\"\(accountId)\",\"firstName\":\"\(firstName)\",\"lastName\":\"\(lastName)\",\"mapString\":\"\(mapString)\",\"mediaURL\":\"\(mediaURL)\",\"latitude\":\(latitude),\"longitude\":\(longitude)}".data(using: .utf8)
            
            
            let session = URLSession.shared
            let task = session.dataTask(with: request){ data, response, error in
                
                
                var errString: String?
                if let statusCode = (response as? HTTPURLResponse)?.statusCode{
                    if statusCode >= 400{
                        errString = "couldn't post your location"
                    }
                }else{
                    errString = "check your internet connection"
                }
                DispatchQueue.main.async {
                    completion(errString)
                }
            }
            task.resume()
        }
        
    }
    
}
