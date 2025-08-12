const std = @import("std");

pub const ListError = error{};

const Entry = struct {
    name: []const u8,
    kind: std.fs.Dir.Entry.Kind,
};

// Execute the list command
pub fn execute(projectDir: []const u8, url: u8, allocator: std.mem.Allocator) !void {
    try printAtDepth(projectDir, 0, url, allocator);
}

// Print path of directories when depth == 2
fn printAtDepth(dirName: []const u8, depth: u8, url: u8, allocator: std.mem.Allocator) !void {
    var dir = try std.fs.cwd().openDir(dirName, .{ .iterate = true });
    defer dir.close();
    var dirIterator = dir.iterate();
    while (try dirIterator.next()) |dirContent| if (dirContent.kind == .directory) {
        const subDir = try std.fs.path.join(allocator, &[_][]const u8{ dirName, dirContent.name });
        defer allocator.free(subDir);
        if (depth == 2) {
            var std_out = std.fs.File.stdout().writerStreaming(&.{});
            if (url == 1) {
                //TODO: support other platforms
                try std.posix.chdir(subDir);
                const argv = [_][]const u8{ "git", "remote", "get-url", "origin"};
                var child = std.process.Child.init(&argv, allocator);
                // Cleanup done by child.wait()

                child.stdout_behavior = .Pipe;
                child.stderr_behavior = .Pipe;

                var stdout: std.ArrayListUnmanaged(u8) = .empty;
                defer stdout.deinit(allocator);
                var stderr: std.ArrayListUnmanaged(u8) = .empty;
                defer stderr.deinit(allocator);

                try child.spawn();
                try child.collectOutput(allocator, &stdout, &stderr, 1024);
                const term = try child.wait();

                if (term.Exited != 0){
                    std.debug.print("There was an issue at {s}: {s}", .{subDir, stderr.items});
                } else {
                    try std_out.interface.print("{s}", .{stdout.items});
                }
            } else {
                try std_out.interface.print("{s}\n", .{subDir});
            }
        } else {
            try printAtDepth(subDir, depth + 1, url, allocator);
        }
    };
}

