const std = @import("std");
const c = @cImport({
    @cInclude("CoreGraphics/CoreGraphics.h");
    @cInclude("CoreFoundation/CoreFoundation.h");
});

pub const MacCursorBroker = struct {
    pub fn moveCursor(displayID: u32, point: c.CGPoint) c.CGError {
        return c.CGDisplayMoveCursorToPoint(displayID, point);
    }

    pub fn createMouseEvent(point: c.CGPoint) c.CGEventRef {
        const sourceEvent = c.CGEventSourceCreate(c.kCGEventSourceStateCombinedSessionState);
        const event = c.CGEventCreateMouseEvent(sourceEvent, c.kCGEventMouseMoved, point, c.kCGHIDEventTap);
        return event;
    }

    pub fn createCGPoint(x: f64, y: f64) c.CGPoint {
        return c.CGPoint{ .x = x, .y = y };
    }

    pub fn invokeCGEventPost(event: c.CGEventRef) void {
        c.CGEventPost(c.kCGHIDEventTap, event);
    }

    pub fn releaseEvent(event: c.CGEventRef) void {
        c.CFRelease(event);
    }

    pub fn getCurrentPoint() c.CGPoint {
        const event = c.CGEventCreate(null);
        const cursor = c.CGEventGetLocation(event);
        c.CFRelease(event);
        return cursor;
    }
};
