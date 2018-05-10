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
    case UndefinedOperator(Character)
    
    case ExpectedCharacter(Character)
    case ExpectedOperator
    case ExpectedDeclaration
    case ExpectedExpression
    case ExpectedArgumentList
    case ExpectedFunctionName
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
    
    func parse() throws -> [Any] {
        index = 0
        
        var nodes = [Any]()
        while index<tokens.count {
            switch(peek()) {
            case .def:
                let node = try parseDefinition()
                nodes.append(node)
            default:
                let expr = try parseTopLevelExpression()
                nodes.append(expr)

            }
        }
        return nodes
    }
    
    let operatorPrecendences: [BinaryOperator : Int] = [.plus : 20,
                        .minus : 20,
                        .mult : 40,
                        .div : 40]
    
    func getPrecedence() throws -> Int {
        guard hasNext() else {
            return -1
        }
        
        guard case let Token.operator(op) = peek() else {
            return -1
        }
        
        if case let Token.other(opchar) = peek() {
            throw ParsingError.UndefinedOperator(opchar)
        }
        
        guard let precedence = operatorPrecendences[op] else {
            return 0
        }
        return precedence
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
        let node = try parsePrimary()
        return try parseBinaryOpExpression(node: node)
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
    
    func parseBinaryOpExpression(node: ExpressionNode, exprPrec: Int = 0) throws -> ExpressionNode {
        var lhs = node
        
        while true {
            let prec = try getPrecedence()
            
            if(prec < exprPrec) {
                return lhs
            }
            
            //check if middle token is an operator
            guard case let Token.operator(op) = pop() else {
                throw ParsingError.ExpectedOperator
            }
            
            var rhs = try parsePrimary()
            
            let nextPrec = try getPrecedence()
            if(prec < nextPrec) {
                rhs = try parseBinaryOpExpression(node: rhs, exprPrec: prec+1)
            }
            
            lhs = BinaryOperationNode(lhs: lhs, rhs: rhs, op: op)
        }
    }
    
    func readIdentifier() throws -> String {
        guard case let Token.identifier(str) = pop() else {
            throw ParsingError.ExpectedIdentifier
        }
        
        return str
    }
    
    func parseParensList<T>(read: () throws -> T) throws -> [T] {
        
        guard case Token.leftParen = pop() else {
            throw ParsingError.ExpectedCharacter("(")
        }
        if case Token.rightParen = peek() {
            return []
        }
        
        var args = [T]()
        while true {
            let element = try read()
            args.append(element)
            
            if case Token.rightParen = pop() {
                break
            }
            
            guard case Token.comma = pop() else {
                throw ParsingError.ExpectedArgumentList
            }
        }
        guard case Token.rightParen = pop() else {
            throw ParsingError.ExpectedCharacter(")")
        }
        return args
    }
    
    func parseIdentifierOrFunction() throws -> ExpressionNode {
        let name = try readIdentifier()
        
        guard hasNext() else {
            return VariableNode(name: name)
        }
        
        guard case Token.leftParen = pop() else {
            return VariableNode(name: name)
        }
        
        let args = try parseParensList(read: readIdentifier)
        return CallNode(name: name, args: args)
    }
    
    func parsePrototype() throws -> PrototypeNode {
        guard case let Token.identifier(name) = pop() else {
            throw ParsingError.ExpectedFunctionName
        }
        
        let args = try parseParensList(read: readIdentifier)
        
        return PrototypeNode(name: name, args: args)
    }
    
    func parseDefinition() throws -> FunctionNode {
        guard case Token.def = pop() else {
            throw ParsingError.ExpectedDeclaration
        }
        
        let prototype = try parsePrototype()
        let body = try parseExpression()
        
        return FunctionNode(body: body, prototype: prototype)
    }
    
    func parseTopLevelExpression() throws -> FunctionNode {
        let body = try parseExpression()
        return FunctionNode(body: body, prototype: nil)
    }
    
    func parsePrimary() throws -> ExpressionNode {
        switch(peek()) {
        case .def:
            return try parseIdentifierOrFunction()
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
