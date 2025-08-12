const std = @import("std");

// Execute the tree command
// TODO: Don't require tree on PATH
//       See https://gist.github.com/j5ndev/048153ede373f68b9d4d7ff3951f0e03
pub fn execute(projectDir: []const u8, allocator: std.mem.Allocator) !void {
    const argv = [_][]const u8{ "tree", projectDir, "-L", "3"};
    var proc = std.process.Child.init(&argv, allocator);
    // cleanup is done by calling wait().
    try proc.spawn();
    _ = try proc.wait();
}
