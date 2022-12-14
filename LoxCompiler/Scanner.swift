//
//  Scanner.swift
//  LoxCompiler
//
//  Created by Cristian Ilea on 05/08/2022.
//

import Foundation

class Scanner {
    private let source: String
    private var start: Int = 0
    private var current: Int = 0
    private var line: Int = 0
    private var tokens: [Token] = []

    var isAtEnd: Bool {
        current >= source.count
    }

    init(source: String) {
        self.source = source
    }

    func add(token tokenType: TokenType) {
        let text = String(source[start..<current])
        tokens.append(Token(tokenType: tokenType, lexeme: text, line: line))
    }

    func scanTokens() -> [Token] {
        while !isAtEnd {
            start = current
            scanToken()
        }

        tokens.append(Token(tokenType: .EOF, lexeme: "", line: line))
        return tokens
    }

    func scanToken() {
        let char = advance()
        switch char {
            case "(": add(token: .LEFT_PAREN)
            case ")": add(token: .RIGHT_PAREN)
            case "{": add(token: .LEFT_BRACE)
            case "}": add(token: .RIGHT_BRACE)
            case ",": add(token: .COMMA)
            case ".": add(token: .DOT)
            case "-": add(token: .MINUS)
            case "+": add(token: .PLUS)
            case ";": add(token: .SEMICOLON)
            case "*": add(token: .STAR)
            case "!": add(token: match(expected: "=") ? .BANG_EQUAL    : .BANG)
            case "=": add(token: match(expected: "=") ? .EQUAL_EQUAL   : .EQUAL)
            case "<": add(token: match(expected: "=") ? .LESS_EQUAL    : .LESS)
            case ">": add(token: match(expected: "=") ? .GREATER_EQUAL : .GREATER)

            case "/":
                if match(expected: "/") {
                    while peek() != "\n" && !isAtEnd { advance() }
                } else {
                    add(token: .SLASH)
                }

            case " " : break
            case "\r": break
            case "\t": break
            case "\n": line += 1

            case "\"": stringLiteral()

            case "o":
                if match(expected: "r") {
                    add(token: .OR)
                }
            default:
                if char.isDigit {
                    numberLiteral()
                } else if char.isAlpha {
                    identifier()
                } else {
                    Lox.shared.error(onLine: line, message: "Unexpected character \(char).")
                }
        }
    }

    @discardableResult
    func advance() -> Character {
        defer { current += 1 }
        return source[current]
    }

    func peek() -> Character {
        guard !isAtEnd else { return "\0" }
        return source[current]
    }

    func peekNext() -> Character {
        if current + 1 >= source.count {
            return "\0"
        }
        return source[current + 1]
    }

    func match(expected: Character) -> Bool {
        guard !isAtEnd else { return false }
        guard source[current] == expected else { return false }

        current += 1
        return true
    }

    func numberLiteral() {
        while peek().isDigit { advance() }

        if peek() == "." && peekNext().isDigit {
            // consume the "."
            advance()

            while peek().isDigit { advance() }
        }

        guard let number = Double(source[start..<current]) else {
            // ideally unreachable
            Lox.shared.error(onLine: line, message: "Unable to read number.")
            return
        }
        add(token: .NUMBER(.DoubleValue(number)))
    }

    func stringLiteral() {
        while peek() != "\"" && !isAtEnd {
            if peek() == "\n" { line += 1 }
            advance()
        }

        if isAtEnd {
            Lox.shared.error(onLine: line, message: "Unterminated string.")
            return
        }

        // the closing "
        advance()

        // trim the surrounding quotes
        let literalString = String(source[start+1..<current-1])
        add(token: .STRING(.StringValue(literalString)))
    }

    func identifier() {
        while peek().isAlphaNumeric { advance() }

        let text = String(source[start..<current])
        let tokenType = TokenType.keywords[text] ?? .IDENTIFIER
        add(token: tokenType)
    }
}
