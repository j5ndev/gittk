const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();
    if (std.os.argv.len < 3) {
        try stderr.print("A command and an argument are needed.\n", .{});
        std.process.exit(1);
    }
    const command = std.os.argv[1];
    if (!std.mem.eql(u8, std.mem.span(command), "clone")) {
        try stderr.print("The command '{s}' is unknown.\n", .{command});
        std.process.exit(1);
    }
    const argument = std.os.argv[2];
    try stdout.print("Argument: {s}\n", .{argument});
}
