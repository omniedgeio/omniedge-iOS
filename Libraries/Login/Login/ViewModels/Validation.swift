//
//  Validation.swift
//  Login
//
//  Created by samuelsong(samuel.song.bc@gmail.com) on 2021/9/4.
//  
//

import Foundation

class Validation {
    //validate both password and email
    static func checkEmailAndPassword(_ email: String, _ password: String) -> Bool {
        return checkEmail(email) && checkPasswordLength(password) && checkPasswordCharacterSet(password)
    }
    //validate a formal email address
    static func checkEmail(_ email: String) -> Bool {
        let emailRegex =
            "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
            "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
            "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"

        let result = email.range(of: emailRegex, options: .regularExpression)
        return result != nil ? true : false
    }
    //validate a password has a number at least
    static func checkPasswordCharacterSet(_ password: String) -> Bool {
        var rules = 0
         if password.rangeOfCharacter(from: CharacterSet.decimalDigits)?.isEmpty == false {
             rules += 1
         }
         if password.rangeOfCharacter(from: CharacterSet.lowercaseLetters)?.isEmpty == false {
             rules += 1
         }
         if password.rangeOfCharacter(from: CharacterSet.uppercaseLetters)?.isEmpty == false {
             rules += 1
         }
         if password.rangeOfCharacter(from: CharacterSet.symbols)?.isEmpty == false ||
             password.rangeOfCharacter(from: CharacterSet.punctuationCharacters)?.isEmpty == false {
             rules += 1
         }
        return rules >= 4 ? true : false
    }
    //validate a password is between 8 and 20 characters long inclusive
    static  func checkPasswordLength(_ password: String) -> Bool {
        //length is 8 to 20 long
        return password.count >= 8 && password.count <= 20 ? true : false
    }
}
