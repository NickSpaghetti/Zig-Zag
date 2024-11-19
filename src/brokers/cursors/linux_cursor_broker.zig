const std = @import("std");
const c = @cImport({
    @cInclude("X11/Xlib.h");
});

const LinuxPoint = std.meta.Tuple(&.{ c_int, c_int });

pub const LinuxCursorBroker = struct {
    pub fn moveCursor(display: *c.struct__XDisplay, windowID: c.Window, point: LinuxPoint) bool {
        c.XWarpPointer(display, 0, windowID, 0, 0, 0, 0, point[0], point[1]);
    }

    pub fn getCurrentPoint(display: *c.struct__XDisplay, windowID: c.Window) void {
        var root_return: c.Window = 0;
        var child_return: c.Window = 0;
        var root_x: c_int = 0;
        var root_y: c_int = 0;
        var win_x: c_int = 0;
        var win_y: c_int = 0;
        var mask_return: c_uint = 0;

        if (c.XQueryPointer(display, windowID, &root_return, &child_return, &root_x, &root_y, &win_x, &win_y, &mask_return) == 0) {
            std.debug.panic("Failed to query pointer", .{});
        }
        return CreateLinuxPoint(root_x, root_y);
    }

    pub fn CreateLinuxPoint(x: c_int, y: c_int) LinuxPoint {
        return .{ x, y };
    }
};
