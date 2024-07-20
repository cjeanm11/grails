const std = @import("std");
const Token = @import("grails/token.zig").Token;
const Scanner = @import("grails/scanner.zig").Scanner;
const Parser = @import("grails/parser.zig").Parser;
const Interpreter = @import("grails/interpreter.zig").Interpreter;

fn printTokenList(tokens: *std.ArrayList(Token)) void {
    std.debug.print("\n Tokens:\n", .{});
    for (tokens.items) |token| { 
        std.debug.print("  {any}\n", .{token});
    }
    std.debug.print("\n", .{});
}


pub fn main() !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = general_purpose_allocator.deinit();
    const allocator = general_purpose_allocator.allocator();

    const source = try std.fs.cwd().readFileAlloc(allocator, "calc.txt", std.math.maxInt(usize));
    defer allocator.free(source);

    var scanner = Scanner.init(source);
    var tokens = std.ArrayList(Token).init(allocator);
    defer tokens.deinit();

    while (true) {
        const token = scanner.scanToken();
        try tokens.append(token);
        if (token.type == .EOF) break;
    }

    printTokenList(&tokens);

    const parser = Parser.init(tokens.items);
    var interpreter = try Interpreter.init(parser);
    const result = try interpreter.interpret();
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
    const parser: Parser = Parser.init(tokens.items);
    var interpreter = try Interpreter.init(parser);
    const result = interpreter.interpret();

    try std.testing.expectEqual(result, 3.0);
}

test "calc.txt test" {
    const filename = "./calc.txt";
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    const source = try file.reader().readAllAlloc(std.heap.page_allocator, std.math.maxInt(usize)); // Read the entire file
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
    var interpreter = try Interpreter.init(parser);
    const result = try interpreter.interpret();

    const expectedResult = 1 + 1;
    try std.testing.expectEqual(result, expectedResult);
}
