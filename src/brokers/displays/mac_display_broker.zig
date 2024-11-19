const std = @import("std");
const c = @cImport({
    @cInclude("CoreGraphics/CoreGraphics.h");
    @cInclude("CoreFoundation/CoreFoundation.h");
});

pub const MacDisplayBroker = struct {
    pub fn getDisplayHeight(displayID: u32) usize {
        return c.CGDisplayPixelsHigh(displayID);
    }

    pub fn getDisplayWidth(displayID: u32) usize {
        return c.CGDisplayPixelsWide(displayID);
    }

    pub fn getDisplayID() u32 {
        return c.CGMainDisplayID();
    }

    pub fn getDisplayIds() []u32 {
        const maxDisplays: c.unit32_t = 100;
        var displays: [maxDisplays]c.CGDirectDisplayID = undefined;
        var displayCount: c.unit32_t = 0;
        const result = c.CGGetActiveDisplayList(maxDisplays, &displays, &displayCount);
        if (result != c.kCGErrorSuccess) {
            std.debug.panic("failed to get list of active displays.", .{});
        }
        return displays[0..displayCount];
    }
};
