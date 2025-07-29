const std = @import("std");

pub const CloneError = error{
    MissingURI,
    UnknownURI,
    TODOExecute,
    MemoryIssue,
    PathIssue,
    ProcessSpawn,
    ProcessWait,
    TargetDirectory,
};

pub fn execute(args: [][:0]u8, projectDir: []const u8, allocator: std.mem.Allocator) CloneError!void {
    if (args.len < 3) return CloneError.MissingURI;
    const uri = args[2];

    const subDir = try getSubDir(uri, allocator);
    const targetDir = std.fs.path.join(allocator, &[_][]const u8{ projectDir, subDir }) catch return CloneError.PathIssue;

    // Execute clone command
    // If the repo already exists, a message like the following will be output:
    //   fatal: destination path '/home/mj/projects/github.com/j5ndev/gittk' already exists and is not an empty directory.
    const argv = [_][]const u8{ "git", "clone", uri, targetDir };
    var proc = std.process.Child.init(&argv, allocator);
    proc.spawn() catch return CloneError.ProcessSpawn;
    _ = proc.wait() catch return CloneError.ProcessWait;

    // Output the target directory that was created or already existed
    // This output allows an easy way to cd into the target folder when the gittk clone command is used from a shell script
    var stdout = std.fs.File.stdout().writerStreaming(&.{});
    stdout.interface.print("\n{s}\n", .{targetDir}) catch return CloneError.TargetDirectory;
}

// Parse URI to create subfolders
// Example github URIs:
//   git@github.com:j5ndev/gittk.git
//   https://github.com/j5ndev/gittk.git
fn getSubDir(uri: []const u8, allocator: std.mem.Allocator) CloneError![]const u8 {
    var fragment = std.mem.trimRight(u8, uri, "git");
    fragment = std.mem.trimRight(u8, fragment, ".");
    if (std.mem.startsWith(u8, uri, "git@")) {
        //One call using "git@" caused an issue and these separate calls were the work around
        fragment = std.mem.trimStart(u8, fragment, "git");
        fragment = std.mem.trimStart(u8, fragment, "@");
    } else if (std.mem.startsWith(u8, uri, "https://")) {
        fragment = std.mem.trimStart(u8, fragment, "https://");
    } else {
        return CloneError.UnknownURI;
    }
    var buffer = std.ArrayList(u8).init(allocator);
    buffer.appendSlice(fragment) catch return CloneError.MemoryIssue;
    const result = buffer.toOwnedSlice() catch return CloneError.MemoryIssue;
    _ = std.mem.replace(u8, fragment, ":", "/", result);
    return result;
}

test "getSubDir correctly parses SSH URI " {
    const uri = "git@github.com:j5ndev/gittk.git";
    const allocator = std.testing.allocator;
    const actual = try getSubDir(uri, allocator);
    defer allocator.free(actual);
    const expected = "github.com/j5ndev/gittk";
    try std.testing.expectEqualStrings(expected, actual);
}

test "getSubDir correctly parses HTTPS URI " {
    const uri = "https://github.com/j5ndev/gittk.git";
    const allocator = std.testing.allocator;
    const actual = try getSubDir(uri, allocator);
    defer allocator.free(actual);
    const expected = "github.com/j5ndev/gittk";
    try std.testing.expectEqualStrings(expected, actual);
}

test "getSubDir correctly zig repository " {
    // Tests an issue work around that prevents the return of git@github.com:ziglang/z
    const uri = "git@github.com:ziglang/zig.git";
    const allocator = std.testing.allocator;
    const actual = try getSubDir(uri, allocator);
    defer allocator.free(actual);
    const expected = "github.com/ziglang/zig";
    try std.testing.expectEqualStrings(expected, actual);
}
