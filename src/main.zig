const std = @import("std");
const windows = @import("windows.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const process_name = "Among Us.exe";

    try stdout.print("Searching for process: {s}\n", .{process_name});

    var process = windows.Process{
        .name = process_name,
    };

    try process.FindPID(process_name);

    try stdout.print("Found process ID: {any}\n", .{process.GetPID()});
}
