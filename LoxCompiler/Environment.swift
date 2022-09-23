//
//  Environment.swift
//  LoxCompiler
//
//  Created by Cristian Ilea on 29/08/2022.
//

import Foundation



class Environment {
    private var values: [String: Value] = [:]

    func define(name: String, value: Value) {
        values[name] = value
    }

    func get(name: Token) throws -> Value {
        if let value = values[name.lexeme] {
            return value
        }

        throw RuntimeError(token: name, message: "Undefined variable \(name.lexeme).")
    }
}
