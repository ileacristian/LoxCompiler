//
//  Lox.swift
//  LoxCompiler
//
//  Created by Cristian Ilea on 05/08/2022.
//

import Foundation

class Lox {

    public static let shared = Lox()

    private var hadError: Bool = false
    @Published var errorMessage: String = ""


    private init() {

    }

    func runFile(_ stringPath: String) {
        hadError = false
        errorMessage = ""

        guard let filePath = Bundle.main.url(forResource: stringPath, withExtension: "lox") else { return }
        guard let fileContents = try? String(contentsOf: filePath) else { return }
        run(source: fileContents)

        if hadError {
            print("bai mare")
            // bai mare
        }
    }

    @discardableResult
    func run(source: String) -> [Token] {
        hadError = false
        errorMessage = ""

        let scanner = Scanner(source: source)
        let tokens: [Token] = scanner.scanTokens()

        for token in tokens {
            print(token)
        }

        return tokens
    }

    func error(onLine line: Int, message: String) {
        report(onLine: line, where: "", message: message)
    }

    func report(onLine line: Int, where: String, message: String) {
        let errorMessage = "[line \(line)] Error \(`where`): \(message)"
        print(errorMessage)
        hadError = true
        self.errorMessage = errorMessage
    }
}


