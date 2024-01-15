const std = @import("std");

const ArrayList = std.ArrayList;

const HELP_TEXT = @embedFile("./help.txt");
const VERSION = "0.0.0";

pub const Config = struct {
    const self = @This();

    /// Maximum number of times to rerun the process.
    /// `0` means no limit.
    max_reruns: usize = 0,

    /// If `true`, rerun the process if it exits with a zero exit code.
    rerun_on_exit_success: bool = false,

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
    var arg_it = std.process.args();
    // skip my own exe name
    _ = arg_it.skip();

    var config = Config{
        .args = undefined,
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
                config.max_reruns = max;
                continue;
            } else {
                std.debug.print("`--max` requires a number argument.\n", .{});
                std.process.exit(1);
            }
        }

        if (eql(u8, arg, "--on-success")) {
            config.rerun_on_exit_success = true;
            continue;
        }

        if (std.mem.startsWith(u8, arg, "-")) {
            std.debug.print("Unknown option `{s}`.\n", .{arg});
            std.process.exit(1);
        }

        config.args = try std.ArrayList([]const u8).initCapacity(allocator, 8);
        try config.args.append(arg);
        break;
    }

    // push the rest of the arguments (not include the command name)
    while (arg_it.next()) |arg| {
        try config.args.append(arg);
    }

    return config;
}
