const std = @import("std");

pub const ListError = error{
    NotImplemented,
};

// Execute the list command
pub fn execute(projectDir: []const u8, allocator: std.mem.Allocator) ListError!void {
    _ = projectDir;
    _ = allocator;

    return ListError.NotImplemented;
}