const std = @import("std");
const c = @cImport({
    @cInclude("windows.h");
});

pub const WindowsCursorBroker = struct {
    pub fn moveCursor(point: c.POINT) bool {
        return c.SetCursorPos(point.x, point.y);
    }

    pub fn createPoint(x: i32, y: i32) c.POINT {
        return c.POINT{ .x = x, .y = y };
    }

    pub fn getCurrentPoint() ?c.POINT {
        var pos: c.Point = undefined;
        if (!c.GetCursorPos(&pos)) {
            return null;
        }
        return pos;
    }
};
