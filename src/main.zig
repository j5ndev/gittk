const std = @import("std");
const gittk = @import("gittk");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const args = gittk.getArgs(allocator) catch |err| {
        switch (err) {
            gittk.ArgsError.ArgsAlloc => std.debug.print("Error: Could not parse arguments.\n", .{}),
            gittk.ArgsError.CommandIsMissing => std.debug.print("Error: Command is missing.\n", .{}),
        }
        std.process.exit(1);
    };
    defer std.process.argsFree(allocator, args);

    const command = args[1];
    if (std.mem.eql(u8, command, "clone")) {
        std.debug.print("TODO: Command {s}\n", .{command});
    } else {
        std.debug.print("Error: Command \"{s}\" is unknown.\n", .{command});
        std.process.exit(1);
    }
}
