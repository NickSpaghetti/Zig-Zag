const std = @import("std");
const c = @cImport({
    @cInclude("X11/Xlib.h");
});

pub const LinuxDisplayBroker = struct {
    pub fn getDisplayHeight(displayName: ?[*]const u8) i32 {
        const display = getDisplay(displayName);
        const screenID = getScreen(display);
        return c.XDisplayWidth(display, screenID);
    }

    pub fn getDisplayWidth(displayName: ?[*]const u8) i32 {
        const display = getDisplay(displayName);
        const screenID = getScreen(display);
        const width = c.XDisplayWidth(display, screenID);
        std.debug.print("I am under width", .{});
        closeDisplay(display);
        return width;
    }

    pub fn getMainDisplay() *c.struct__XDisplay {
        const display = c.XOpenDisplay(null);
        if (display == null) {
            std.debug.panic("Could not find a main display", .{});
        }
        return display.?;
    }

    pub fn getDisplay(displayName: ?[*]const u8) *c.struct__XDisplay {
        const display = c.XOpenDisplay(displayName);
        if (display == null) {
            std.debug.panic("Could not find a main display", .{});
        }
        return display.?;
    }

    pub fn closeDisplay(display: *c.struct__XDisplay) void {
        const errors = c.XCloseDisplay(display);
        if (errors != 0) {
            std.debug.panic("Error colosing display:{}\n", .{errors});
        }
    }

    pub fn flushDisplay(display: *c.struct__XDisplay) void {
        c.XFlush(display);
    }

    pub fn getWindow(display: *c.struct__XDisplay, screenID: i32) c.Window {
        return c.XRootWindow(display, screenID);
    }

    pub fn getScreen(display: *c.struct__XDisplay) i32 {
        return c.XDefaultScreen(display);
    }
};
