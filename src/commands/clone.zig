const std = @import("std");

pub const CloneError = error{
    URIMissing,
    TODOExecute,
};

pub fn execute(args: [][:0]u8) CloneError!void {
    if (args.len < 3) return CloneError.URIMissing;
    return CloneError.TODOExecute;
}
