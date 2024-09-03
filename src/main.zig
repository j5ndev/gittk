const std = @import("std");

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    if (std.os.argv.len < 3) {
        try stdout.print("Error: A command and an argument are needed.\n", .{});
        try bw.flush();
        std.process.exit(1);
    }
    const command = std.os.argv[1];
    if (!std.mem.eql(u8, std.mem.span(command), "clone")) {
        try stdout.print("Error: command '{s}' unknown.\n", .{command});
        try bw.flush();
        std.process.exit(1);
    }

    const argument = std.os.argv[2];
    try stdout.print("Argument: {s}\n", .{argument});
    try bw.flush();
}
