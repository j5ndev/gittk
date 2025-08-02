const clap = @import("clap");
const std = @import("std");
const gittk = @import("gittk");

const version = "0.1";

// These are our subcommands.
const SubCommands = enum { clone, help, version };

const main_parsers = .{
    .command = clap.parsers.enumeration(SubCommands),
};

// The parameters for `main`. Parameters for the subcommands are specified further down.
const main_params = clap.parseParamsComptime(
    \\-h, --help  Display this help and exit.
    \\<command>
);

pub fn main() !void {
    var gpa_state = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpa_state.allocator();
    defer _ = gpa_state.deinit();

    var iter = try std.process.ArgIterator.initWithAllocator(gpa);
    defer iter.deinit();

    _ = iter.next();

    var diag = clap.Diagnostic{};
    var res = clap.parseEx(clap.Help, &main_params, main_parsers, &iter, .{
        .diagnostic = &diag,
        .allocator = gpa,
        .terminating_positional = 0,
    }) catch |err| {
        switch (err) {
            clap.parsers.EnumError.NameNotPartOfEnum => std.debug.print("Error: Unknown command\n", .{}),
            else => try diag.reportToFile(.stderr(), err),
        }
        std.process.exit(1);
    };
    defer res.deinit();

    const command = res.positionals[0] orelse .help;
    switch (command) {
        .help => try clap.helpToFile(.stderr(), clap.Help, &main_params, .{}),
        .clone => try cloneMain(gpa, &iter),
        .version => std.debug.print("{s}\n", .{version}),
    }
}

fn cloneMain(gpa: std.mem.Allocator, iter: *std.process.ArgIterator) !void {

    // The parameters for the clone subcommand.
    const params = comptime clap.parseParamsComptime(
        \\-h, --help  Display this help and exit.
        \\<str>
    );

    // Here we pass the partially parsed argument iterator.
    var diag = clap.Diagnostic{};
    var res = clap.parseEx(clap.Help, &params, clap.parsers.default, iter, .{
        .diagnostic = &diag,
        .allocator = gpa,
    }) catch |err| {
        try diag.reportToFile(.stderr(), err);
        return err; // propagate error
    };
    defer res.deinit();

    const uri = res.positionals[0] orelse {
        std.debug.print("Error: The clone command requires a URI.\n", .{});
        std.process.exit(1);
    };
    if (res.args.help != 0)
        std.debug.print("--help\n", .{});

    //TODO: support more platforms
    const homeDir = std.posix.getenv("HOME") orelse {
        std.debug.print("Error: Unable to identify HOME directory", .{});
        std.process.exit(1);
    };
    const projectDir = try std.fs.path.join(gpa, &[_][]const u8{ homeDir, "projects" });
    defer gpa.free(projectDir);
    gittk.clone.execute(uri, projectDir, gpa) catch |err| {
        switch (err) {
            gittk.clone.CloneError.TODOExecute => std.debug.print("TODO: Execute the git clone command using {s}\n", .{uri}),
            gittk.clone.CloneError.UnknownURI => std.debug.print("Error: The URI for the git clone command is in an unknown format.\n", .{}),
            gittk.clone.CloneError.ProcessSpawn => std.debug.print("Error: There was an issue executing the command.\n", .{}),
            gittk.clone.CloneError.ProcessWait => std.debug.print("Error: There was an issue waiting for the command to finish.\n", .{}),
            else => std.debug.print("Error: An unexpected issue occurred.", .{}),
        }
        std.process.exit(1);
    };
}
