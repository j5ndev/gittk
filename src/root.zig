const std = @import("std");
pub const clone = @import("commands/clone.zig");
pub const tree = @import("commands/tree.zig");

test "Execute tests from submodules; includes tests of private members" {
    _ = @import("commands/clone.zig");
    _ = @import("commands/tree.zig");
}
