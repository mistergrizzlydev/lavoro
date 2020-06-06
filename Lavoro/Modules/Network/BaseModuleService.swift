//
//  BaseModuleService.swift
//  Lavoro
//
//  Created by Manish on 06/06/20.
//  Copyright © 2020 Manish. All rights reserved.
//

import UIKit

class BaseModuleService: NSObject {
    let NS = NetworkService()
    
    func getCode(from data: Any) -> Int? {
        guard let json = data as? [String: Any], let data = json["data"] as? [String: Any] else {
            return nil
        }
        if let code = data["code"] as? Int {
            return code
        }
        return nil
    }
    
    func getMessage(from data: Any) -> String? {
        guard let json = data as? [String: Any], let data = json["data"] as? [String: Any] else {
            return nil
        }
        if let message = data["message"] as? String {
            return message
        }
        return nil
    }
}
