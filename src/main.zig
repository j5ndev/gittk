const clap = @import("clap");
const std = @import("std");
const gittk = @import("gittk");

// These are our subcommands.
const SubCommands = enum {
    help,
    clone,
};

const main_parsers = .{
    .command = clap.parsers.enumeration(SubCommands),
};

// The parameters for `main`. Parameters for the subcommands are specified further down.
const main_params = clap.parseParamsComptime(
    \\-h, --help  Display this help and exit.
    \\<command>
);

// To pass around arguments returned by clap, `clap.Result` and `clap.ResultEx` can be used to
// get the return type of `clap.parse` and `clap.parseEx`.
const MainArgs = clap.ResultEx(clap.Help, &main_params, main_parsers);

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

        // Terminate the parsing of arguments after parsing the first positional (0 is passed
        // here because parsed positionals are, like slices and arrays, indexed starting at 0).
        //
        // This will terminate the parsing after parsing the subcommand enum and leave `iter`
        // not fully consumed. It can then be reused to parse the arguments for subcommands.
        .terminating_positional = 0,
    }) catch |err| {
        try diag.reportToFile(.stderr(), err);
        return err;
    };
    defer res.deinit();

    if (res.args.help != 0)
        std.debug.print("--help\n", .{});

    const command = res.positionals[0] orelse return std.debug.print("Error: No command was given.\n", .{});
    switch (command) {
        .help => std.debug.print("--help\n", .{}),
        .clone => try cloneMain(gpa, &iter, res),
    }
}

fn cloneMain(gpa: std.mem.Allocator, iter: *std.process.ArgIterator, main_args: MainArgs) !void {
    // The parent arguments are not used here, but there are cases where it might be useful, so
    // this example shows how to pass the arguments around.
    _ = main_args;

    // The parameters for the subcommand.
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