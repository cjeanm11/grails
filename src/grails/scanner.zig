const Token = @import("token.zig").Token;
const std = @import("std");

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
        return Token { 
                .type = .NUMBERLITERAL, 
                .lexeme = self.source[self.start..self.current], 
                .literal = .{ .number = value }
            };
    }

    fn string(self: *Scanner) Token {
        while (self.peek() != '"' and !self.isAtEnd()) {
            _ = self.advance();
        }

        if (self.isAtEnd()) {
            const err = error.UnterminatedString; 
            std.log.err("String scanning error: {}", .{err});
            std.debug.panic("String scanning failed.", .{});
        }

        _ = self.advance(); 
        const literal = self.source[self.start + 1 .. self.current - 1];
        
        return Token{ 
                .type = .STRINGLITERAL, 
                .lexeme = self.source[self.start..self.current], 
                .literal = .{ .str = literal }
            };
    }



    fn identifier(self: *Scanner) Token {
        while (std.ascii.isLower(self.peek()) or std.ascii.isUpper(self.peek()) or self.peek() == '_') {
            _ = self.advance();
        }

        const lexeme = self.source[self.start..self.current];
        if (std.mem.eql(u8, lexeme, "if")) {
            return Token{ .type = .IF, .lexeme = lexeme, .literal = null };
        } else if (std.mem.eql(u8, lexeme, "else")) {
            return Token{ .type = .ELSE, .lexeme = lexeme, .literal = null };
        } else if (std.mem.eql(u8, lexeme, "elif")) {
            return Token{ .type = .ELIF, .lexeme = lexeme, .literal = null };
        } // more ...
        return Token{ .type = .IDENTIFIER, .lexeme = lexeme, .literal = null };
    }

    pub fn scanToken(self: *Scanner) Token {
        self.skipWhitespace();
        self.start = self.current;

        if (self.isAtEnd()) return Token{ .type = .EOF, .lexeme = "", .literal = null };
        const c = self.advance();

        if (std.ascii.isDigit(c)) return self.number();
        if (c == '"') return self.string();
        if (std.ascii.isLower(self.peek()) or std.ascii.isUpper(self.peek())) return self.identifier();

        return switch (c) {
            ',' => Token{ .type = .COMMA, .lexeme = ",", .literal = null },
            '.' => Token{ .type = .DOT, .lexeme = ".", .literal = null },
            ';' => Token{ .type = .SEMICOLON, .lexeme = ";", .literal = null },
            '=' => {
                if (self.peek() == '=') {
                    _ = self.advance();
                    return Token{ .type = .EQUAL, .lexeme = "==", .literal = null };
                }
                return Token{ .type = .ASSIGN, .lexeme = "=", .literal = null };
            },
            '<' => {
                if (self.peek() == '=') {
                    _ = self.advance();
                    return Token{ .type = .LESSEQUAL, .lexeme = "<=", .literal = null };
                }
                return Token{ .type = .LESS, .lexeme = "<", .literal = null };
            },
            '>' => {
                if (self.peek() == '=') {
                    _ = self.advance();
                    return Token{ .type = .GREATEREQUAL, .lexeme = ">=", .literal = null };
                }
                return Token{ .type = .GREATER, .lexeme = ">", .literal = null };
            },
            '+' => Token{ .type = .PLUS, .lexeme = "+", .literal = null },
            '-' => Token{ .type = .MINUS, .lexeme = "-", .literal = null },
            '(' => Token{ .type = .LEFTPAREN, .lexeme = "(", .literal = null },
            ')' => Token{ .type = .RIGHTPAREN, .lexeme = ")", .literal = null },
            '{' => Token{ .type = .LEFTBRACE, .lexeme = "{", .literal = null },
            '}' => Token{ .type = .RIGHTBRACE, .lexeme = "}", .literal = null },
            '*' => {
                if (self.peek() == '*') {
                    _ = self.advance();
                    return Token{ .type = .DOUBLESTAR, .lexeme = "**", .literal = null };
                }
                return Token{ .type = .STAR, .lexeme = "*", .literal = null };
            },
            '/' => {
                if (self.peek() == '/') {
                    _ = self.advance();
                    return Token{ .type = .DOUBLESLASH, .lexeme = "//", .literal = null };
                }
                return Token{ .type = .SLASH, .lexeme = "/", .literal = null };
            },
            '!' => {
                if (self.peek() == '=') {
                    _ = self.advance();
                    return Token{ .type = .NOTEQUAL, .lexeme = "!=", .literal = null };
                }
                return Token{ .type = .NOT, .lexeme = "!", .literal = null };
            },
            '%' => Token{ .type = .PERCENT, .lexeme = "%", .literal = null },
            else => {
                std.debug.panic("Unexpected character.", .{});
            },
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
