const std = @import("std");

pub const TreeError = error{
    ProcessSpawn,
    ProcessWait
};

// Execute the tree command
// TODO: Don't require tree on PATH
//       See https://gist.github.com/j5ndev/048153ede373f68b9d4d7ff3951f0e03
pub fn execute(projectDir: []const u8, allocator: std.mem.Allocator) TreeError!void {
    const argv = [_][]const u8{ "tree", projectDir, "-L", "3"};
    var proc = std.process.Child.init(&argv, allocator);
    // cleanup is done by calling wait().
    proc.spawn() catch return TreeError.ProcessSpawn;
    _ = proc.wait() catch return TreeError.ProcessWait;
}