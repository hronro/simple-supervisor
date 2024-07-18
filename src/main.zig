const std = @import("std");

const getConfigFromCli = @import("./config.zig").getConfigFromCli;
const run = @import("./run.zig").run;

const HELP_TEXT = @embedFile("./help.txt");
const VERSION = "0.0.1";

var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    const gpa = general_purpose_allocator.allocator();
    var arena_instance = std.heap.ArenaAllocator.init(gpa);
    defer arena_instance.deinit();
    const arena = arena_instance.allocator();

    const config = try getConfigFromCli(arena);
    try run(arena, config);
}
