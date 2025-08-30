const std = @import("std");

// Execute the tree command
// TODO: Don't require tree on PATH
//       See https://gist.github.com/j5ndev/048153ede373f68b9d4d7ff3951f0e03
pub fn execute(projectDir: []const u8, allocator: std.mem.Allocator) !void {
    std.debug.print("{s}\n", .{projectDir});
    const depth = 0;
    try printDirectory(projectDir, "", allocator, depth);
}

const indent_unicode = "│   ";
const indent_space = "    ";
const suffix_last = "└──";
const suffix_mid = "├──";

const Entry = struct {
    name: []const u8,
    kind: std.fs.Dir.Entry.Kind,
};

fn printDirectory(path: []const u8, indent: []const u8, allocator: std.mem.Allocator, depth: u8) !void {
    var dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    defer dir.close();

    var entries: std.ArrayList(Entry) = .empty;
    defer {
        for (entries.items) |entry| {
            allocator.free(entry.name);
        }
        entries.deinit(allocator);
    }

    var it = dir.iterate();
    while (try it.next()) |entry| {
        const name_copy = try allocator.dupe(u8, entry.name);
        try entries.append(allocator, Entry{
            .name = name_copy,
            .kind = entry.kind,
        });
    }
    const count = entries.items.len;
    for (entries.items, 0..) |entry, index| {
        const is_last = index + 1 == count;
        const middle = if (is_last) indent_space else indent_unicode;
        const suffix = if (is_last) suffix_last else suffix_mid;

        var buf: [512]u8 = undefined;
        const prefix = try std.fmt.bufPrint(&buf, "{s}{s}", .{ indent, suffix });

        std.debug.print("{s} {s}\n", .{ prefix, entry.name });

        if (entry.kind == .directory) {
            const full_len = path.len + 1 + entry.name.len;
            var path_buf = try allocator.alloc(u8, full_len);
            defer allocator.free(path_buf);

            std.mem.copyForwards(u8, path_buf[0..path.len], path);
            path_buf[path.len] = '/';
            std.mem.copyForwards(u8, path_buf[path.len + 1 ..], entry.name);
            const sub_path = path_buf[0..full_len];

            var sub_buf: [512]u8 = undefined;
            const sub_indent = try std.fmt.bufPrint(&sub_buf, "{s}{s}", .{ indent, middle });

            if (depth < 2)
                try printDirectory(sub_path, sub_indent, allocator, depth + 1);
        }
    }
}