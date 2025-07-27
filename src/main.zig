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
        .clone => {
            //TODO: support more platforms
            const homeDir = std.posix.getenv("HOME") orelse {
                std.debug.print("Error: Unable to identify HOME directory", .{});
                std.process.exit(1);
            };
            const projectDir = try std.fs.path.join(allocator, &[_][]const u8{ homeDir, "projects" });
            gittk.clone.execute(args, projectDir, allocator) catch |err| {
                switch (err) {
                    gittk.clone.CloneError.MissingURI => std.debug.print("Error: The URI for git clone command must be provided.\n", .{}),
                    gittk.clone.CloneError.TODOExecute => std.debug.print("TODO: Execute the git clone command using {s}\n", .{args[2]}),
                    gittk.clone.CloneError.UnknownURI => std.debug.print("Error: The URI for the git clone command is in an unknown format.\n", .{}),
                    else => std.debug.print("Error: An unexpected issue occurred.", .{}),
                }
                std.process.exit(1);
            };
        },
        .@"An unknown command" => {
            std.debug.print("Error: Command \"{s}\" is unknown.\n", .{commandString});
            std.process.exit(1);
        },
    }
}
