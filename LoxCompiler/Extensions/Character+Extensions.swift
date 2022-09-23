//
//  Character+Extensions.swift
//  LoxCompiler
//
//  Created by Cristian Ilea on 05/08/2022.
//

import Foundation

extension Character {
    var isDigit: Bool {
        self >= "0" && self <= "9"
    }

    var isAlpha: Bool {
        self >= "a" && self <= "z" ||
        self >= "A" && self <= "Z" ||
        self == "_"
    }

    var isAlphaNumeric: Bool {
        isAlpha || isDigit
    }
}
