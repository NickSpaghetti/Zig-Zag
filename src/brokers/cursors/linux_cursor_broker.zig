const std = @import("std");
const c = @cImport({
    @cInclude("X11/Xlib.h");
});

pub const LinuxCursorBroker = struct {
    pub fn moveCursor(point: c.POINT) bool {
        return false;
    }

    pub fn createPoint(x: i32, y: i32) void {}

    pub fn flush() void {}

    pub fn getCurrentPoint() void {}
};
