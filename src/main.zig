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

    const Commands = enum {
        clone,
        @"An unknown command",
    };

    const commandString= args[1];
    const command = std.meta.stringToEnum(Commands, commandString) orelse .@"An unknown command";
    switch (command) {
        .clone => std.debug.print("TODO: Command {s}\n", .{commandString}),
        .@"An unknown command" => {
            std.debug.print("Error: Command \"{s}\" is unknown.\n", .{commandString});
            std.process.exit(1);
        },
    }
}
