const Token = @import("token.zig").Token;
const std = @import("std");

// Scanner
pub const Scanner = struct {
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
        return Token{ .type = .NUMBERLITERAL, .lexeme = self.source[self.start..self.current], .literal = value };
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
