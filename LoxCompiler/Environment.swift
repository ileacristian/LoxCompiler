//
//  Environment.swift
//  LoxCompiler
//
//  Created by Cristian Ilea on 29/08/2022.
//

import Foundation



class Environment {
    private var values: [String: Value] = [:]
    var parent: Environment?

    init(parent: Environment? = nil) {
        self.parent = parent
    }

    func define(name: String, value: Value) {
        values[name] = value
    }

    func get(name: Token) throws -> Value {
        if let value = values[name.lexeme] {
            return value
        }

        if let parent {
            return try parent.get(name: name)
        }

        throw RuntimeError(token: name, message: "Undefined variable \(name.lexeme).")
    }

    func assign(name: Token, value: Value) throws {
        if values[name.lexeme] != nil {
            values[name.lexeme] = value
            return
        }

        if let parent {
            return try parent.assign(name: name, value: value)
        }

        throw RuntimeError(token: name, message: "Undefined variable \(name.lexeme).")
    }
}
