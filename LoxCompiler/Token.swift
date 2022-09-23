//
//  Token.swift
//  LoxCompiler
//
//  Created by Cristian Ilea on 05/08/2022.
//

import Foundation

enum TokenType: Equatable {
    // single character tokens
    case LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE, COMMA, DOT, MINUS, PLUS, SEMICOLON, SLASH, STAR

    // One or two character tokens.
    case BANG, BANG_EQUAL, EQUAL, EQUAL_EQUAL, GREATER, GREATER_EQUAL, LESS, LESS_EQUAL

    // literals
    case IDENTIFIER
    case STRING(Value)
    case NUMBER(Value)

    // keywords
    case AND, CLASS, ELSE, FALSE, FUN, FOR, IF, NIL, OR, PRINT, RETURN, SUPER, THIS, TRUE, VAR, WHILE

    // other
    case EOF

    static var keywords: [String: TokenType] = [
        "and"    : .AND,
        "class"  : .CLASS,
        "else"   : .ELSE,
        "false"  : .FALSE,
        "fun"    : .FUN,
        "for"    : .FOR,
        "if"     : .IF,
        "nil"    : .NIL,
        "or"     : .OR,
        "print"  : .PRINT,
        "return" : .RETURN,
        "super"  : .SUPER,
        "this"   : .THIS,
        "true"   : .TRUE,
        "var"    : .VAR,
        "while"  : .WHILE,
    ]

    static func ~=(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
            case (.NUMBER(_), .NUMBER(_)):
                return true
            case (.STRING(_), .STRING(_)):
                return true
            default:
                return lhs == rhs
        }
    }
}

enum Value: Equatable {
    case StringValue(String)
    case DoubleValue(Double)
    case BoolValue(Bool)
    case AnyValue
    case NilValue
    case Error(String)
}

struct Token: CustomStringConvertible {
    let tokenType: TokenType
    let lexeme: String
    let line: Int

    var description: String {
        "{\(tokenType) (\(lexeme))}"
    }
}
