const std = @import("std");

const TokenType = enum { PLUS, MINUS, STAR, NUMBER, EOF };
const Token = struct { type: TokenType, lexeme: []const u8, literal: ?f64 };

// Scanner
const Scanner = struct {
    source: []const u8,
    start: usize = 0,
    current: usize = 0,

    pub fn init(source: []const u8) Scanner {
        return Scanner{ .source = source };
    }
    pub fn isAtEnd(self: Scanner) bool {
        return self.current >= self.source.len;
    }
    pub fn advance(self: *Scanner) u8 {
        self.current += 1;
        return self.source[self.current - 1];
    }

    fn peek(self: Scanner) u8 {
        return if (self.isAtEnd()) 0 else self.source[self.current];
    }
    fn peekNext(self: Scanner) u8 {
        return if (self.current + 1 >= self.source.len) 0 else self.source[self.current + 1];
    }

    pub fn number(self: *Scanner) Token {
        while (!self.isAtEnd() and std.ascii.isDigit(self.peek())) _ = self.advance();
        if (self.peek() == '.' and std.ascii.isDigit(self.peekNext())) {
            _ = self.advance();
            while (!self.isAtEnd() and std.ascii.isDigit(self.peek())) _ = self.advance();
        }
        const value = std.fmt.parseFloat(f64, self.source[self.start..self.current]) catch unreachable;
        return Token{ .type = .NUMBER, .lexeme = self.source[self.start..self.current], .literal = value };
    }

    pub fn scanToken(self: *Scanner) Token {
        self.skipWhitespace();
        self.start = self.current;

        if (self.isAtEnd()) return Token{ .type = .EOF, .lexeme = "", .literal = null };
        const c = self.advance();

        if (std.ascii.isDigit(c)) return self.number();

        return switch (c) {
            '+' => Token{ .type = .PLUS, .lexeme = "+", .literal = null },
            '-' => Token{ .type = .MINUS, .lexeme = "-", .literal = null },
            '*' => Token{ .type = .STAR, .lexeme = "*", .literal = null },
            else => {
                std.debug.panic("Unexpected character.", .{});
            }, // Use panic for unexpected errors
        };
    }

    fn skipWhitespace(self: *Scanner) void {
        while (!self.isAtEnd()) {
            const c = self.peek();
            if (c != ' ' and c != '\r' and c != '\t' and c != '\n') break;
            _ = self.advance();
        }
    }
};

const Parser = struct {
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

const Interpreter = struct {
    parser: Parser,

    pub fn init(parser: Parser) Interpreter {
        return Interpreter{ .parser = parser };
    }

    pub fn interpret(self: *Interpreter) f64 {
        return self.parser.expression();
    }
};

pub fn main() !void {
    var args = std.process.args();
    defer args.deinit();

    const source = try std.fs.cwd().readFileAlloc(std.heap.page_allocator, args.skip(1).next() orelse "calc.txt", std.math.maxInt(usize));
    defer std.heap.page_allocator.free(source);

    var scanner = Scanner.init(source);
    var tokens = std.ArrayList(Token).init(std.heap.page_allocator);
    defer tokens.deinit();

    while (true) {
        const token = scanner.scanToken();
        try tokens.append(token);
        if (token.type == .EOF) break;
    }

    const parser: Parser = Parser.init(tokens.items);
    var interpreter = Interpreter.init(parser);
    const result = interpreter.interpret();
    std.debug.print("Result: {d}\n", .{result});
}

test "basic addition" { 
    const source = "1 + 2";
    var scanner = Scanner.init(source);
    var tokens = std.ArrayList(Token).init(std.heap.page_allocator);
    defer tokens.deinit();

    while (true) {
        const token = scanner.scanToken();
        try tokens.append(token);
        if (token.type == .EOF) break;
    }
    const parser: Parser = Parser.init(tokens.items); // initialize Parser
    var interpreter = Interpreter.init(parser);
    const result = interpreter.interpret();

    try std.testing.expectEqual(result, 3.0);
}
