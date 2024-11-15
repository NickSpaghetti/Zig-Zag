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
};
