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

        let parser = Parser(tokens: tokens)

        let statements = parser.parse()

        print(Interpreter().interpret(statements: statements))

//        print(ASTPrinter().print(expr))

//        print(Interpreter().evaluate(expr: expr))

        return tokens
    }

    func error(onLine line: Int, message: String) {
        report(onLine: line, where: "", message: message)
    }

    func error(forToken token: Token, message: String) {
        if token.tokenType == .EOF {
            report(onLine: token.line, where: " at end", message: message)
        } else {
            report(onLine: token.line, where: " at '\(token.lexeme)'", message: message)
        }
    }
    
    func report(onLine line: Int, where: String, message: String) {
        let errorMessage = "[line \(line)] Error \(`where`): \(message)"
        print(errorMessage)
        hadError = true
        self.errorMessage = errorMessage
    }
}


