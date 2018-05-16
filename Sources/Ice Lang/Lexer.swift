//
//  Lexer.swift
//  Ice Lang
//
//  Created by Drew Wilken on 4/30/18.
//  Copyright © 2018 Drew Wilken. All rights reserved.
//
//  Lexer used to grab tokens from the input
//

import Foundation
import Darwin

enum BinaryOperator: UnicodeScalar {
    case plus = "+"
    case minus = "-"
    case mult = "*"
    case div = "/"
    case mod = "%"
    case equals = "="
}

enum Token: Equatable {
    case leftParen, rightParen, def, extern, comma, semicolon, `if`, then, `else`, colon
    case identifier(String)
    case number(Double)
    case `operator`(BinaryOperator)
    case other(Character)
    case EOF
    
    static func ==(lhs: Token, rhs: Token) -> Bool {
        switch (lhs, rhs) {
        case (.leftParen, .leftParen), (.rightParen, .rightParen),
             (.def, .def), (.extern, .extern), (.comma, .comma),
             (.semicolon, .semicolon), (.if, .if), (.then, .then),
             (.else, .else), (.colon, .colon):
            return true
        case let (.identifier(id1), .identifier(id2)):
            return id1 == id2
        case let (.number(n1), .number(n2)):
            return n1 == n2
        case let (.operator(op1), .operator(op2)):
            return op1 == op2
        default:
            return false
        }
    }
}

extension Character {
    var value: Int32 {
        return Int32(String(self).unicodeScalars.first!.value)
    }
    var isSpace: Bool {
        return isspace(value) != 0
    }
    var isAlphanumeric: Bool {
        return isalnum(value) != 0 || self == "_"
    }
}

class Lexer {
    var input: String
    var index: String.Index
    
    init(for input: String) {
        self.input = input
        self.index = input.startIndex
    }
    
    func lex() ->[Token]? {
        var toks = [Token]()
        while let nextTok = nextToken() {
            toks.append(nextTok)
        }
        toks.append(.EOF)
        return toks
    }
    
    var hasNext: Bool {
        return index < input.endIndex ? true : false
    }
    
    var currentChar: Character? {
        return index < input.endIndex ? input[index] : nil
    }
    
    func nextIndex() {
        input.formIndex(after: &index)
    }
    
    //parses an identifier or number
    func parseIdentifierOrNum() -> String{
        var str = ""
        
        while let char = currentChar, char.isAlphanumeric || char == "." {
            str.append(char)
            nextIndex()
        }
        return str
    }
    
    //grabs the next token in the given string
    func nextToken() -> Token? {

        // Eats spaces until next token
        while let char = currentChar, char.isSpace {
            nextIndex()
        }
        
        guard let char = currentChar else {
            return nil
        }
        
        let singleTokMapping: [Character: Token] = [
            ",": .comma, "(": .leftParen, ")": .rightParen,
            ";": .semicolon, "+": .operator(.plus), "-": .operator(.minus),
            "*": .operator(.mult), "/": .operator(.div),
            "%": .operator(.mod), "=": .operator(.equals),
            ":": .colon
        ]
        
        //if current character is one of single-scalar tokens
        if let tok = singleTokMapping[char] {
            nextIndex();
            return tok;
        }

        if char.isAlphanumeric {
            let str = parseIdentifierOrNum()
            
            //if it's a double
            if let double = Double(str) {
                return .number(double)
            }
            
            switch(str) {
                case "def": return .def
                case "extern": return .extern
                case "if": return .if
                case "then": return .then
                case "else": return .else
            default:
                return .identifier(str)
            }
        }
        let tok = Token.other(input[index])
        nextIndex()
        return tok
    }
}
