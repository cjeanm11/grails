pub const TokenType = enum {
    PLUS,
    MINUS,
    STAR,
    NUMBER,
    EOF 
};

pub const Token = struct { 
    type: TokenType, 
    lexeme: []const u8,
    literal: ?f64 
};
