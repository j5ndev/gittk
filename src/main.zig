const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    if (args.len < 3) {
        try stderr.print("A command and an argument are needed.\n", .{});
        std.process.exit(1);
    }
    const command = args[1];
    if (!std.mem.eql(u8, command, "clone")) {
        try stderr.print("The command '{s}' is unknown.\n", .{command});
        std.process.exit(1);
    }
    const argument = args[2];
    try stdout.print("Argument: {s}\n", .{argument});
}
