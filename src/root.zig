const std = @import("std");
pub const clone = @import("commands/clone.zig");

pub const ArgsError = error{
    ArgsAlloc,
    CommandIsMissing,
};

pub fn getArgs(allocator: std.mem.Allocator) ArgsError![][:0]u8 {

    const args = std.process.argsAlloc(allocator) catch return ArgsError.ArgsAlloc;

    if (args.len < 2) {
        return ArgsError.CommandIsMissing;
    }

    return args;
}

test "Execute tests from submodules; includes tests of private members" {
   _ = @import("commands/clone.zig");
}