const std = @import("std");
const c = @cImport({
    @cInclude("X11/Xlib.h");
});

pub const LinuxCursorBroker = struct {
    pub fn getDisplayHeight(deviceName: [32]u16) void {}

    pub fn getDisplayWidth(deviceName: [32]u16) void {}

    pub fn getMainDisplayID() void {}
};
