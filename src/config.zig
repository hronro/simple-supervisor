const std = @import("std");

const ArrayList = std.ArrayList;

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
