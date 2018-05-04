//
//  Parser.swift
//  Ice Lang
//
//  Created by Drew Wilken on 5/3/18.
//  Copyright © 2018 Drew Wilken. All rights reserved.
//

import Foundation

enum ParsingError: Error {
    case ExpectedNumber
    case ExpectedIdentifier
    case UnexpectedToken
    case UndefinedOperator(String)
    
    case ExpectedCharacter(Character)
    case ExpectedExpression
    case ExpectedArgumentList
    case ExpectedFunctionName
}

protocol ExpressionNode: CustomStringConvertible {
}

struct NumberNode: ExpressionNode {
    let value: Double
    var description: String {
        return "NumberNode(\(value))"
    }
}

struct IdentifierNode: ExpressionNode {
    let name: String
    var description: String {
        return "IdentifierNode(\(name))"
    }
}

struct BinaryOperationNode: ExpressionNode {
    let lhs: ExpressionNode
    let rhs: ExpressionNode
    let op: String
    
    var description: String {
        return "BinaryOperationNode(\(op) lhs: \(lhs) rhs: \(rhs)"
    }
}

class Parser {
    
    var tokens: [Token]
    var index = 0
    
    init(for tokens: [Token]) {
        self.tokens = tokens
    }
    
    func peek() -> Token {
        return tokens[index]
    }
    
    func hasNext() -> Bool {
        return index < tokens.count;
    }
    
    func pop() -> Token {
        let ret = tokens[index]
        index+=1
        return ret
    }
    
    func parseNumber() throws -> ExpressionNode {
        guard case let Token.number(value) = pop() else {
            throw ParsingError.ExpectedNumber
        }
        return NumberNode(value: value)
    }
    
    func parseIdentifier() throws -> ExpressionNode {
        guard case let Token.identifier(identifier) = pop() else {
            throw ParsingError.ExpectedIdentifier
        }
        return IdentifierNode(name: identifier)
    }
    
    func parseExpression() throws -> ExpressionNode {
        return IdentifierNode(name: "Hi")
    }
    
    func parseParenthesis() throws -> ExpressionNode {
        guard case Token.leftParen = pop() else {
            throw ParsingError.ExpectedCharacter("(")
        }
        
        let expression = try parseExpression()
        
        guard case Token.rightParen = pop() else {
            throw ParsingError.ExpectedCharacter(")")
        }
        return expression
    }
    
    func parsePrimary() throws -> ExpressionNode {
        switch(peek()) {
        case .number:
            return try parseNumber()
        case .identifier:
            return try parseIdentifier()
        case .leftParen:
            return try parseParenthesis()
        default:
            throw ParsingError.ExpectedExpression
            
        }
    }
}
