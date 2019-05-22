//
//  Constrants.swift
//  OnThe Map
//
//  Created by zico on 5/17/19.
//  Copyright © 2019 mansoura Unversity. All rights reserved.
//

import Foundation
struct APIConstants {
    struct HeaderKeys {
        static let PARSE_APP_ID = "X-Parse-Application-Id"
        static let PARSE_API_KEY = "X-Parse-REST-API-Key"
    }
    struct HeaderValues {
        static let PARSE_APP_ID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let PARSE_API_KEY = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    struct ParameterKeys {
        static let LIMIT = "limit"
        static let SKIP = "skip"
        static let ORDER = "order"
    }
    static let SESSION = "https://onthemap-api.udacity.com/v1/session"
    static let PUBLIC_USER = "https://onthemap-api.udacity.com/v1/users"
    static let STUDENT_LOCATION = "https://parse.udacity.com/parse/classes/StudentLocation"
}
