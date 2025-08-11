const std = @import("std");

pub const ListError = error{};

const Entry = struct {
    name: []const u8,
    kind: std.fs.Dir.Entry.Kind,
};

// Execute the list command
pub fn execute(projectDir: []const u8, allocator: std.mem.Allocator) !void {
    try printAtDepth(projectDir, 0, allocator);
}

// Print path of directories when depth == 2
fn printAtDepth(dirName: []const u8, depth: u8, allocator: std.mem.Allocator) !void {
    var dir = try std.fs.cwd().openDir(dirName, .{ .iterate = true });
    defer dir.close();
    var dirIterator = dir.iterate();
    while (try dirIterator.next()) |dirContent| if (dirContent.kind == .directory) {
        const subDir = try std.fs.path.join(allocator, &[_][]const u8{ dirName, dirContent.name });
        defer allocator.free(subDir);
        if (depth == 2) {
            std.debug.print("{s}\n", .{subDir});
        } else {
            try printAtDepth(subDir, depth + 1, allocator);
        }
    };
}

