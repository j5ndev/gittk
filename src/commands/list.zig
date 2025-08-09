const std = @import("std");

pub const ListError = error{};

const Entry = struct {
    name: []const u8,
    kind: std.fs.Dir.Entry.Kind,
};

// Execute the list command
pub fn execute(projectDir: []const u8, allocator: std.mem.Allocator) ListError!void {
    var dir = try std.fs.cwd().openDir(projectDir, .{ .iterate = true });
    defer dir.close(); 

    var entries = std.ArrayList(Entry).init(allocator);
    defer {
        for (entries.items) |entry| {
            allocator.free(entry.name);
        }
        entries.deinit();
    }
    for (entries.items) |entry| {
        const full_len = projectDir.len + 1 + entry.name.len;
        var path_buf = try allocator.alloc(u8, full_len);
        defer allocator.free(path_buf);

        std.mem.copyForwards(u8, path_buf[0..projectDir.len], projectDir);
        path_buf[projectDir.len] = '/';
        std.mem.copyForwards(u8, path_buf[projectDir.len + 1 ..], entry.name);
        const sub_path = path_buf[0..full_len];
        if (entry.kind == .directory) {
            try execute (sub_path, allocator);
        } else {
            std.debug.print("{s}\n", sub_path);
        }
    }
}
