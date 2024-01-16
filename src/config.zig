const std = @import("std");

const ArrayList = std.ArrayList;

const HELP_TEXT = @embedFile("./help.txt");
const VERSION = "0.1.1";

pub const Config = struct {
    const self = @This();

    /// Maximum number of times to restart the process.
    /// `0` means no limit.
    max_restarts: usize = 0,

    /// If `true`, the process will be restarted even if it exited successfully.
    restart_on_exit_success: bool = false,

    /// If `true`, do not print messages when restarting the process.
    silent: bool = false,

    /// The command to run.
    args: ArrayList([]const u8),

    pub fn deinit() void {
        self.args.deinit();
    }
};

/// Get the configuration from the CLI arguments.
/// If the CLI arguments contains unknown options,
/// this function will print an error message and exit.
/// If the CLI arguments contains other commands (e.g. `--help`),
/// this function will execute the command and exit.
pub fn getConfigFromCli(allocator: std.mem.Allocator) !Config {
    var arg_it = try std.process.argsWithAllocator(allocator);
    defer arg_it.deinit();
    // skip my own exe name
    _ = arg_it.skip();

    var config = Config{
        .args = try std.ArrayList([]const u8).initCapacity(allocator, 8),
    };

    // parse options
    while (arg_it.next()) |arg| {
        const eql = std.mem.eql;

        if (eql(u8, arg, "--help")) {
            std.debug.print("{s}", .{HELP_TEXT});
            std.process.exit(0);
        }

        if (eql(u8, arg, "-h")) {
            std.debug.print("{s}", .{HELP_TEXT});
            std.process.exit(0);
        }

        if (eql(u8, arg, "--version")) {
            std.debug.print("Version: {s}\n", .{VERSION});
            std.process.exit(0);
        }

        if (eql(u8, arg, "-v")) {
            std.debug.print("Version: {s}\n", .{VERSION});
            std.process.exit(0);
        }

        if (eql(u8, arg, "--max")) {
            if (arg_it.next()) |max_string| {
                const max = std.fmt.parseInt(usize, max_string, 10) catch {
                    std.debug.print(" The argument of `--max` expects a number, but got `{s}`.\n", .{max_string});
                    std.process.exit(1);
                };
                config.max_restarts = max;
                continue;
            } else {
                std.debug.print("`--max` requires a number argument.\n", .{});
                std.process.exit(1);
            }
        }

        if (eql(u8, arg, "--on-success")) {
            config.restart_on_exit_success = true;
            continue;
        }

        if (eql(u8, arg, "-A")) {
            config.restart_on_exit_success = true;
            continue;
        }

        if (eql(u8, arg, "--silent")) {
            config.silent = true;
            continue;
        }

        if (eql(u8, arg, "-s")) {
            config.silent = true;
            continue;
        }

        if (std.mem.startsWith(u8, arg, "-")) {
            std.debug.print("Unknown option `{s}`.\n", .{arg});
            std.process.exit(1);
        }

        try config.args.append(arg);
        break;
    }

    // push the rest of the arguments (not include the command name)
    while (arg_it.next()) |arg| {
        try config.args.append(arg);
    }

    return config;
}
