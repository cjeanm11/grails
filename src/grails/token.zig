const std = @import("std");

pub const TokenType = enum {
    // Operators
    PLUS,
    MINUS,
    STAR,
    SLASH,
    DOUBLESLASH,  
    PERCENT,      
    DOUBLESTAR,   

    // AMPERSAND,  // & (bitwise AND)
    // PIPE,       // | (bitwise OR)
    // CARET,      // ^ (bitwise XOR)
    // TILDE,      // ~ (bitwise NOT)
    // LEFTSHIFT,  // <<
    // RIGHTSHIFT, // >>

    // Comparison Operators
    EQUAL,
    NOTEQUAL,
    GREATER,
    GREATEREQUAL,
    LESS,
    LESSEQUAL,

    // Assignment Operators
    ASSIGN,       
    PLUSEQUAL,    
    MINUSEQUAL,   
    STAREQUAL,    
    SLASHEQUAL,   
    DOUBLESLASHEQUAL, 
    PERCENTEQUAL, 
    DOUBLESTAREQUAL,

    // Logical Operators
    AND,     
    OR,      
    NOT,     

    // Delimiters
    LEFTPAREN,    
    RIGHTPAREN,   
    LEFTBRACKET,  
    RIGHTBRACKET, 
    LEFTBRACE,    
    RIGHTBRACE,   
    COMMA,
    COLON,
    DOT,
    SEMICOLON,

    // Keywords
    IF,
    ELSE,
    ELIF,   
    FOR,
    WHILE,
    DEF,    
    RETURN,
    CLASS,
    PASS,   
    TRUE,
    FALSE,
    NONE,   

    // Literals
    IDENTIFIER,
    STRINGLITERAL,
    NUMBERLITERAL, 

    // Other
    NEWLINE,
    INDENT, 
    DEDENT,

    EOF, 
};

pub const Token = struct { 
    type: TokenType, 
    lexeme: []const u8,
    literal: ?union(enum) { 
        number: f64,
        str: []const u8, 
    }, 
};

pub fn printTokenList(tokens: *std.ArrayList(Token)) void {
    std.debug.print("\n Tokens:\n", .{});
    for (tokens.items) |token| { 
        std.debug.print("  {any}\n", .{token});
    }
    std.debug.print("\n", .{});
}