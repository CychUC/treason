// Author: Chase
// Purpose: Windows API cImports for obtaining process information for a
//          particular process by name.

const std = @import("std");
const win = @cImport({
    @cDefine("WIN32_LEAN_AND_MEAN", "1");
    @cInclude("windows.h");
    @cInclude("tlhelp32.h");
});

pub const Process = struct {
    name: []const u8,
    pid: u32 = 0,
    snapshot_handle: ?win.HANDLE = undefined,

    // A collection of errors that can be returned by the
    // various calls to the Windows API.
    const Win32Error = error{ InvalidHandleValue, FirstProcessNotFound };

    // Get the PID of the current process.
    pub fn GetPID(self: *Process) ?u32 {
        return self.pid;
    }

    // Get handle of the toolhelp snapshot.
    pub fn GetHandle(self: *Process) ?win.HANDLE {
        return self.snapshot_handle;
    }

    // Get the PID of a process by name.
    pub fn FindPID(self: *Process, process_name: []const u8) Win32Error!void {
        // Create a toolhelp snapshot of all running processes
        // using the Process32First and Process32Next functions from the Windows API.
        const snapshot_handle = win.CreateToolhelp32Snapshot(win.TH32CS_SNAPPROCESS, 0);
        defer _ = win.CloseHandle(snapshot_handle);

        // If the snapshot handle is invalid, return an error.
        if (snapshot_handle == win.INVALID_HANDLE_VALUE) {
            std.io.getStdOut().writer().print("Failed to create snapshot of process {s}.\n", .{process_name}) catch return Win32Error.InvalidHandleValue;
        }

        // Assign the snapshot handle to the `Process`.
        self.snapshot_handle = snapshot_handle;

        var process_entry: win.PROCESSENTRY32 = undefined;
        process_entry.dwSize = @sizeOf(win.PROCESSENTRY32);

        // Get the first process. If there are no processes in our snapshot, return an error.
        if (win.Process32First(snapshot_handle, &process_entry) == 0) {
            std.io.getStdOut().writer().print("Failed to get first process.\n", .{}) catch return Win32Error.FirstProcessNotFound;
        }

        while (win.Process32Next(snapshot_handle, &process_entry) != 0) {

            // Slice the process name to get the length of the name.
            // An "empty" element will have a character code of 170.
            var process_name_length: usize = 0;
            for (process_entry.szExeFile) |char| {
                if (char == 170) break;
                process_name_length += 1;
            }

            const system_name = process_entry.szExeFile[0..process_name_length];

            // Some debugging sugar to show the process name and system name. Was helpful
            // for finding out why the process name and system name were different. By default,
            // when strings are passed to functions the null-terminator is not included.
            std.log.debug("Process Name: {s} Process Name Bytes: {any} Process Name Type: {s}\n\tSystem Name: {s} System Name Bytes: {any} System Name Type: {s}\n", .{ process_name, process_name, @typeName(@TypeOf(process_name)), system_name, system_name, @typeName(@TypeOf(system_name)) });

            if (std.mem.eql(u8, process_name, system_name[0 .. process_name_length - 1])) {
                self.pid = process_entry.th32ProcessID;
                return;
            }

            // Reset the process name to undefined to avoid
            // undefined behavior when comparing it to the name we're looking for.
            // If we don't do this, the comparison will always fail due to the previous
            // iterations potentially having longer process names.
            process_entry.szExeFile = undefined;
        }
        // For now, the process was not found. Try again.
        return FindPID(self, process_name);
    }
};
