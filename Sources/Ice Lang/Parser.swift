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
    case ExpectedToken(Token)
    case ExpectedOperator
    case ExpectedDeclaration
    case ExpectedExpression
    case ExpectedArgumentList
    case ExpectedFunctionName
}

class Parser {
    // TODO: Add if/else conditional support
    
    var tokens: [Token]
    var index = 0
    
    //precedences for different operators
    let precedences: [BinaryOperator : Int] = [.plus : 20,
                                               .minus : 20,
                                               .div : 40,
                                               .mult : 40,
                                               .equals : 0]
    
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
    
    func parse() throws -> File {
        let file = File()
        
        while hasNext() {
            switch(peek()) {
            case .def:
                file.addDefinition(try parseDefinition())
            case .EOF:
                return file
            default:
                file.addExpression(try parseExpression());
            }
            guard case Token.semicolon = pop() else {throw ParsingError.ExpectedCharacter(";")}
        }
        return file
    }
    
    func getTokenPrecedence() -> Int {
        // handle all the cases here - because it should never throw an error
        // it should always at least give a -1 so that the binary operation parser works
        guard hasNext() else {
            return -1
        }
        
        guard case let Token.operator(op) = peek() else {
            return -1
        }
        
        guard let precedence = precedences[op] else {
            return -1
        }
        
        return precedence
    }
    
    func parseNumber() throws -> expr {
//          Parses a token - expects a number and if it is a number
//          it returns a node for it
        
        guard case let Token.number(num) = pop() else {
            throw ParsingError.ExpectedNumber
        }
        
        return .number(num)
    }
    
    func parseIdentifier() throws -> String {
//        Parses a token and returns an identifier node for the
//        string of the identifier
        guard case let Token.identifier(str) = pop() else {
            throw ParsingError.ExpectedIdentifier
        }
        
        return str
    }
    
    func parseParens() throws -> expr {
//        Affirms that the current expression is inside parenthesis, if not, throws errors.
//        returns an expression node
        guard case Token.leftParen = pop() else {
            throw ParsingError.ExpectedCharacter("(")
        }
        
        let expr = try parseExpression()
        
        guard case Token.rightParen = pop() else {
            throw ParsingError.ExpectedCharacter(")")
        }
        return expr
    }
    
    func parseArgsList<E>(_ fn: () throws -> E) throws -> [E] {
        //eat opening paren
        guard case Token.leftParen = pop() else {
            throw ParsingError.ExpectedCharacter("(")
        }
        var args = [E]()
        if case Token.rightParen = peek() {
            _ = pop()
            return []
        }
        while true {
            let arg = try fn()
            args.append(arg)
            
            if case Token.rightParen = peek() {
                break
            }
            //if no end paren, there must be a comma coming up
            guard case Token.comma = pop() else {
                throw ParsingError.ExpectedCharacter(",")
            }
        }
        //consume paren and leave
        _ = pop()
        return args
    }
    
    func parseIdentifierExpression() throws -> expr {
        guard case let Token.identifier(name) = pop() else {
            throw ParsingError.ExpectedIdentifier
        }
        
        //check if current identifier is a variable
        //we can assume this if the identifier isn't followed by parens
        guard case Token.leftParen = peek() else {
            return .variable(name)
        }
        //grab args from the parens
        let args = try parseArgsList(parseExpression)
        
        return .call(name, args)
        
    }
    func parseBinaryOperation(lhs: expr, exprPrecedence: Int = 0) throws -> expr {
        var lhs = lhs
        while true {
            //get precedence of next token
            let prec = getTokenPrecedence()
            
            //if the precedence is less than the expression precedence, then return the lhs
            if(prec < exprPrecedence) {
                return lhs
            }
        
            //this is the binOp - eat it and save it
            guard case let Token.operator(op) = pop() else {
                return lhs
            }
            
            //parse the expression after the binary operator
            var rhs = try parsePrimaryExpression()

            //get the next operator's precedence if there is one
            let nextPrec = getTokenPrecedence()
                
            if(prec < nextPrec) {
                rhs = try parseBinaryOperation(lhs: rhs, exprPrecedence: prec+1)
            }
            
            lhs = expr.binOp(lhs, op, rhs)
        }
    }
    
    func parsePrimaryExpression() throws -> expr {
        //Parses a primary expression which can start in multiple ways
        var node: expr
        
        switch(peek()) {
        case .identifier: node = try parseIdentifierExpression()
        case .number: node = try parseNumber()
        case .leftParen: node = try parseParens()
        case .if:
            _ = pop() //consume if
            let cond = try parseExpression()
            let ifBody = try parseExpression()
            guard case .else = pop() else {
                throw ParsingError.ExpectedToken(.else)
            }
            let elseBody = try parseExpression()
            return .ifelse(cond, ifBody, elseBody)
        default: throw ParsingError.ExpectedExpression
        }
        return node
    }
    
    func parseExpression() throws -> expr {
        let lhs = try parsePrimaryExpression()
        
        return try parseBinaryOperation(lhs: lhs)
    }
    
    func parseDefinition() throws -> FunctionNode {
        guard case Token.def = pop() else {
            throw ParsingError.ExpectedDeclaration
        }
        let proto = try parsePrototype()
        let e = try parseExpression()

        return FunctionNode(body: e, prototype: proto)
    }
    
    func parsePrototype() throws -> PrototypeNode {
        guard case let Token.identifier(name) = pop() else {
            throw ParsingError.ExpectedFunctionName
        }
        //parse any args that this may have
        let args = try parseArgsList(parseIdentifier)
        
        return PrototypeNode(name: name, args: args)
        
    }
}
