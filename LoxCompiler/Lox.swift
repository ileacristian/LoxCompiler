//
//  Lox.swift
//  LoxCompiler
//
//  Created by Cristian Ilea on 05/08/2022.
//

import Foundation

class Lox {
    static private var hadError: Bool = false

    static func runFile(_ stringPath: String) {
        guard let filePath = Bundle.main.url(forResource: stringPath, withExtension: "lox") else { return }
        guard let fileContents = try? String(contentsOf: filePath) else { return }
        run(source: fileContents)

        if Lox.hadError {
            print("bai mare")
            // bai mare
        }
    }

    @discardableResult
    static func run(source: String) -> [Token] {
        let scanner = Scanner(source: source)
        let tokens: [Token] = scanner.scanTokens()

        for token in tokens {
            print(token)
        }

        return tokens
    }

    static func error(onLine line: Int, message: String) {
        print("")
    }

    static func report(onLine line: Int, where: String, message: String) {
        print("[line \(line)] Error \(`where`): \(message)")
        Lox.hadError = true
    }
}


