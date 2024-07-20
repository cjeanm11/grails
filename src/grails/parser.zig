const Token = @import("token.zig").Token;
const TokenType = @import("token.zig").TokenType;
const std = @import("std");

pub const Parser = struct {
    tokens: []const Token,
    current: usize = 0,

    pub fn init(tokens: []const Token) Parser {
        return Parser{ .tokens = tokens };
    }

    pub fn matchToken(self: *Parser, token_type: TokenType) bool {
        if (self.check(token_type)) {
            _ = self.advance(); 
            return true;
        }
        return false;
    }

    pub fn check(self: Parser, token_type: TokenType) bool {
        if (self.isAtEnd()) return false; 
        return self.tokens[self.current].type == token_type;
    }

    pub fn advance(self: *Parser) Token {
        if (!self.isAtEnd()) self.current += 1;
        return self.tokens[self.current - 1];
    }

    pub fn isAtEnd(self: Parser) bool {
        return self.peek().type == .EOF;
    }

    pub fn peek(self: Parser) Token {
        return self.tokens[self.current];
    }

    pub fn primary(self: *Parser) !f64 {
          if (self.matchToken(.NUMBERLITERAL)) { 
              if (self.tokens[self.current - 1].literal) |value| {
                  return value.number;
              } else {
                  std.debug.print("Error: Expected a number literal.\n", .{});
                  return error.UnexpectedToken;
              }
          } 
          std.debug.print("Error: Expected expression.\n", .{});
          return error.UnexpectedToken;
    }
    
    // Handle more operations: +, -, *, /, //, %
    pub fn term(self: *Parser) !f64 {
        var expr = try self.unary();
    
        while (self.matchToken(.STAR) or self.matchToken(.SLASH) or self.matchToken(.DOUBLESLASH) or self.matchToken(.PERCENT)) {
            const operator = self.tokens[self.current - 1];
            const right = try self.unary();
            expr = switch (operator.type) {
                .STAR => return expr * right,
                .SLASH => {
                    if (right == 0.0) return error.DivisionByZero;
                    return expr / right; 
                },
                .DOUBLESLASH => return @divFloor(expr, right),
                .PERCENT => return @mod(expr, right),        
                else => unreachable,
            };
        }
    
        return expr;
    }        
    
    pub fn unary(self: *Parser) !f64 {
        if (self.matchToken(.MINUS)) {
            return -try self.primary();
        }
        return self.primary(); 
    }
    pub fn expression(self: *Parser) !f64 {
        var expr = try self.term();

        while (self.matchToken(.PLUS) or self.matchToken(.MINUS)) {
            const operator = self.tokens[self.current - 1];
            const right = try self.term(); 
            expr = switch (operator.type) {
                .PLUS => expr + right,
                .MINUS => expr - right,
                else => unreachable,
            };
        }
        return expr;
    }
};
