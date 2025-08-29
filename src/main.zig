const clap = @import("clap");
const std = @import("std");
const gittk = @import("gittk");

const version = "0.0.1";

// These are our subcommands.
const SubCommands = enum { clone, help, ls, tree, version };

const main_parsers = .{
    .command = clap.parsers.enumeration(SubCommands),
    .str = clap.parsers.string,
};

// The parameters for `main`. Parameters for the subcommands are specified further down.
const main_params = clap.parseParamsComptime(
    \\-d, --debug Debug an issue by showing stack traces
    \\-h, --help  Display this help and exit.
    \\-p, --project <str> The project directory.  It will override the default of $HOME/projects.
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

    const debug: bool = res.args.debug == 1;

    var projectDir: []const u8 = undefined;
    var freeProjectDir: bool = false;
    if (res.args.project) |p| {
        // Override project directory from arg

        projectDir = p;
    } else if (std.posix.getenv("GITTK_PROJECT")) |p| {
        // Override project directory from env

        projectDir = p;
    } else {
        // Default project directory

        //TODO: Support more platforms
        const homeDir = std.posix.getenv("HOME") orelse {
            std.debug.print("Error: Unable to identify HOME directory", .{});
            std.process.exit(1);
        };
        projectDir = try std.fs.path.join(gpa, &[_][]const u8{ homeDir, "projects" });
        freeProjectDir = true;
    }
    defer if (freeProjectDir) gpa.free(projectDir);

    if (debug) {
        std.debug.print("DEBUG: Project Directory: {s}\n", .{projectDir});
    }

    const command = res.positionals[0] orelse .help;
    _ = switch (command) {
        .help => {
            try clap.helpToFile(.stderr(), clap.Help, &main_params, .{});
            std.debug.print(
                \\ Commands:
                \\
                \\  clone    Clone repositority into gittk tree structure under the project directory
                \\  help     Display this help message
                \\  ls       Display a list paths to each repository
                \\  tree     Display a tree summary of all repositories
                \\  version  Display the version of this executable
                \\
            , .{});
        },
        .clone => cloneMain(gpa, &iter, projectDir),
        .tree => treeMain(gpa, &iter, projectDir),
        .ls => listMain(gpa, &iter, projectDir),
        .version => std.debug.print("{s}\n", .{version}),
    } catch |err| {
        switch (err) {
            gittk.clone.CloneError.UnknownURL => std.debug.print("Error:\n{s}\n", .{gittk.clone.UnknownURLMessage}),
            else => {
                if (!debug) std.debug.print("Error: {any}\n", .{err});
            },
        }
        if (debug) {
            return err;
        } else {
            std.process.exit(1);
        }
    };
}

fn listMain(gpa: std.mem.Allocator, iter: *std.process.ArgIterator, projectDir: []const u8) !void {
    // The parameters for the list subcommand.
    const params = comptime clap.parseParamsComptime(
        \\-h, --help  Display this help and exit.
        \\-u, --url   Display url of the remote origin
    );

    // Here we pass the partially parsed argument iterator.
    var diag = clap.Diagnostic{};
    var res = clap.parseEx(clap.Help, &params, clap.parsers.default, iter, .{
        .diagnostic = &diag,
        .allocator = gpa,
    }) catch |err| {
        try diag.reportToFile(.stderr(), err);
        return err;
    };
    defer res.deinit();

    if (res.args.help != 0) {
        try clap.helpToFile(.stderr(), clap.Help, &params, .{});
        std.debug.print(
            \\
            \\  Print the list of repository paths under the project directory.
            \\  Use the --url option to instead list all the repository URLs used to clone each repository.
            \\
        , .{});
        return;
    }

    try gittk.list.execute(projectDir, res.args.url, gpa);
}

fn treeMain(gpa: std.mem.Allocator, iter: *std.process.ArgIterator, projectDir: []const u8) !void {
    // The parameters for the tree subcommand.
    const params = comptime clap.parseParamsComptime(
        \\-h, --help  Display this help and exit.
    );

    // Here we pass the partially parsed argument iterator.
    var diag = clap.Diagnostic{};
    var res = clap.parseEx(clap.Help, &params, clap.parsers.default, iter, .{
        .diagnostic = &diag,
        .allocator = gpa,
    }) catch |err| {
        try diag.reportToFile(.stderr(), err);
        std.process.exit(1);
    };
    defer res.deinit();

    if (res.args.help != 0) {
        try clap.helpToFile(.stderr(), clap.Help, &params, .{});
        std.debug.print(
            \\  
            \\  Print the directory tree under the project directory.
            \\
        , .{});
        return;
    }

    try gittk.tree.execute(projectDir, gpa);
}

fn cloneMain(gpa: std.mem.Allocator, iter: *std.process.ArgIterator, projectDir: []const u8) !void {

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
        std.process.exit(1);
    };
    defer res.deinit();

    if (res.args.help != 0) {
        try clap.helpToFile(.stderr(), clap.Help, &params, .{});
        std.debug.print(
            \\  
            \\  Clone the given repository URL into the directory tree under the project directory.
            \\
        , .{});
        return;
    }

    const url = res.positionals[0] orelse {
        std.debug.print("Error: The clone command requires a URL.\n", .{});
        std.process.exit(1);
    };

    try gittk.clone.execute(url, projectDir, gpa);
}
