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
    var arena = arena_instance.allocator();

    const config = try getConfigFromCli(arena);
    try run(arena, config);
}

fn runChildProcess(argv: []const []const u8, allocator: std.mem.Allocator, exit_successfully: *bool) !void {
    var child_process = std.ChildProcess.init(argv, allocator);
    const term = try child_process.spawnAndWait();
    switch (term) {
        .Exited => |status_code| {
            if (status_code == 0) {
                exit_successfully.* = true;
            } else {
                exit_successfully.* = false;
            }
        },
        else => {
            exit_successfully.* = false;
        },
    }
}
