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

    pub fn primary(self: *Parser) f64 {
        if (self.matchToken(.NUMBER)) {
            return self.tokens[self.current - 1].literal.?;
        } else {
            std.debug.print("Expect expression.\n", .{});
            std.process.exit(1);
        }
    }
    pub fn term(self: *Parser) f64 {
        var expr = self.primary();

        while (self.matchToken(.STAR)) {
            const operator = self.tokens[self.current - 1];
            const right = self.primary();
            expr = switch (operator.type) {
                .STAR => expr * right,
                else => unreachable,
            };
        }

        return expr;
    }

    pub fn expression(self: *Parser) f64 {
        var expr = self.term();

        while (self.matchToken(.PLUS) or self.matchToken(.MINUS)) {
            const operator = self.tokens[self.current - 1];
            const right = self.term();
            expr = switch (operator.type) {
                .PLUS => expr + right,
                .MINUS => expr - right,
                else => unreachable,
            };
        }

        return expr;
    }
};
