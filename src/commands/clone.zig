const std = @import("std");

pub const CloneError = error{
    MissingURI,
    UnknownURI,
    TODOExecute,
    MemoryIssue,
    PathIssue,
};

pub fn execute(args: [][:0]u8, projectDir: []const u8, allocator: std.mem.Allocator) CloneError!void {
    if (args.len < 3) return CloneError.MissingURI;
    const uri = args[2];

    const subDir = try getSubDir(uri, allocator);
    const absPath = std.fs.path.join(allocator, &[_][]const u8{ projectDir, subDir }) catch return CloneError.PathIssue;

    std.debug.print("Target Directory: {s}\n", .{absPath});
    return CloneError.TODOExecute;
}

// Parse URI to create subfolders
// Example github URIs:
//   git@github.com:j5ndev/gittk.git
//   https://github.com/j5ndev/gittk.git
fn getSubDir(uri: []const u8, allocator: std.mem.Allocator) CloneError![]const u8 {
    var fragment = std.mem.trimRight(u8, uri, ".git");
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
