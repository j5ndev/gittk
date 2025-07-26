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
    //defer std.process.argsFree(allocator, args);
    //Would slow program close

    const Commands = enum {
        clone,
        @"An unknown command",
    };

    const commandString = args[1];
    const command = std.meta.stringToEnum(Commands, commandString) orelse .@"An unknown command";
    switch (command) {
        .clone => gittk.clone.execute(args) catch |err| {
            switch (err) {
                gittk.clone.CloneError.URIMissing => std.debug.print("Error: The URI for git clone command mustbe provided.\n", .{}),
                gittk.clone.CloneError.TODOExecute => std.debug.print("TODO: Execute the git clone command using {s}\n", .{args[2]}),
            }
            std.process.exit(1);
        },
        .@"An unknown command" => {
            std.debug.print("Error: Command \"{s}\" is unknown.\n", .{commandString});
            std.process.exit(1);
        },
    }
}
