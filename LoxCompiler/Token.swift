//
//  Token.swift
//  LoxCompiler
//
//  Created by Cristian Ilea on 05/08/2022.
//

import Foundation

enum TokenType {
    // single character tokens
    case LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE, COMMA, DOT, MINUS, PLUS, SEMICOLON, SLASH, STAR

    // One or two character tokens.
    case BANG, BANG_EQUAL, EQUAL, EQUAL_EQUAL, GREATER, GREATER_EQUAL, LESS, LESS_EQUAL

    // literals
    case IDENTIFIER, STRING, NUMBER

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
}

struct Token: CustomStringConvertible {
    let tokenType: TokenType
    let lexeme: String
    let literal: Any?
    let line: Int

    var description: String {
        if let literal = literal {
            return "{\(tokenType) (\(lexeme)):\(String(describing: literal))}"
        } else {
            return "{\(tokenType) (\(lexeme))}"
        }
    }
}
