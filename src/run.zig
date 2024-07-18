const std = @import("std");

const Config = @import("./config.zig").Config;

pub fn run(allocator: std.mem.Allocator, config: Config) !void {
    if (config.args.items.len > 0) {
        var exit_successfully = false;
        var count_of_restarts: usize = 0;

        try runChildProcess(allocator, config.args.items, &exit_successfully);

        while ((config.restart_on_exit_success or !exit_successfully) and (config.max_restarts == 0 or count_of_restarts < config.max_restarts)) : (count_of_restarts += 1) {
            if (!config.silent) {
                std.debug.print("Process `{s}` running failed, restarting for the {d} time(s)...\n", .{ config.args.items[0], count_of_restarts + 1 });
            }
            try runChildProcess(allocator, config.args.items, &exit_successfully);
        }
    } else {
        std.debug.print("Empty arguments.\n", .{});
        std.process.exit(1);
    }
}

fn runChildProcess(allocator: std.mem.Allocator, argv: []const []const u8, exit_successfully: *bool) !void {
    var child_process = std.process.Child.init(argv, allocator);
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
