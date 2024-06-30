const Parser = @import("parser.zig").Parser;

pub const Interpreter = struct {
    parser: Parser,

    pub fn init(parser: Parser) Interpreter {
        return Interpreter{ .parser = parser };
    }

    pub fn interpret(self: *Interpreter) f64 {
        return self.parser.expression();
    }
};

