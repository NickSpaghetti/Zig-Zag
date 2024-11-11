const std = @import("std");
const c = @cImport({
    @cInclude("CoreGraphics/CoreGraphics.h");
    @cInclude("CoreFoundation/CoreFoundation.h");
});
const RndGen = std.rand.DefaultPrng;

const kCGEventPointMoved = 5;
const kCGHIDEventTap = 0;

pub fn main() !void {
    const displayID = c.CGMainDisplayID();
    const displayWidth = c.CGDisplayPixelsWide(displayID);
    const displayHeight = c.CGDisplayPixelsHigh(displayID);
    std.debug.print("DisplayID {} size: {}x{}\n", .{ displayID, displayWidth, displayHeight });
    var rnd = RndGen.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    var currentPosition = GetCurrentPoint();
    while (true) {
        const position = c.CGPoint{ .x = try GenerateRnd(&rnd, displayHeight), .y = try GenerateRnd(&rnd, displayWidth) };
        std.debug.print("Generated x: {} and y: {}\n", .{ position.x, position.y });
        const sourceEvent = c.CGEventSourceCreate(c.kCGEventSourceStateCombinedSessionState);
        const event = c.CGEventCreateMouseEvent(sourceEvent, kCGEventPointMoved, position, kCGHIDEventTap);
        if (event != null) {
            defer c.CFRelease(event);
            c.CGEventPost(kCGHIDEventTap, event);
            try MoveSmooth(displayID, currentPosition, position);
            const sleepTime = @as(u64, @intFromFloat(try GenerateRnd(&rnd, 5_000_000_000)));
            std.time.sleep(sleepTime);
        } else {
            std.debug.print("failed to create point event\n", .{});
        }
        std.debug.print("----------------------------------------------------\n", .{});
        currentPosition = position;
    }
}

pub fn GenerateRnd(rnd: *std.rand.DefaultPrng, constaint: usize) !f64 {
    const rng = rnd.random();
    const generatedInt = rng.intRangeAtMost(usize, 0, constaint);
    return @as(f64, @floatFromInt(generatedInt));
}

pub fn MoveSmooth(displayID: u32, previousPoint: c.CGPoint, nextPoint: c.CGPoint) !void {
    std.debug.print("current pos x: {} and y:{}\n", .{ previousPoint.x, previousPoint.y });
    var smoothX: f64 = nextPoint.x - previousPoint.x;
    var smoothY: f64 = nextPoint.y - previousPoint.y;
    try CreateMoveEvent(displayID, previousPoint);
    while (smoothX <= nextPoint.x or smoothY <= nextPoint.y) {
        const position = c.CGPoint{ .x = smoothX, .y = smoothY };
        try CreateMoveEvent(displayID, position);
        smoothX += 0.05;
        smoothY += 0.05;
    }
    try CreateMoveEvent(displayID, nextPoint);
}

pub fn CreateMoveEvent(displayID: u32, point: c.CGPoint) !void {
    const sourceEvent = c.CGEventSourceCreate(c.kCGEventSourceStateCombinedSessionState);
    const event = c.CGEventCreateMouseEvent(sourceEvent, kCGEventPointMoved, point, kCGHIDEventTap);
    if (event != null) {
        defer c.CFRelease(event);
        c.CGEventPost(kCGHIDEventTap, event);
        try MovePoint(displayID, point);
    }
}

pub fn MovePoint(displayID: u32, point: c.CGPoint) !void {
    const err = c.CGDisplayMoveCursorToPoint(displayID, point);
    if (err != 0) {
        std.log.err("Error with moving pointer {}.  See https://developer.apple.com/documentation/coregraphics/cgerror\n", .{err});
    }
}

pub fn GetCurrentPoint() c.CGPoint {
    const event = c.CGEventCreate(null);
    const cursor = c.CGEventGetLocation(event);
    c.CFRelease(event);
    return cursor;
}
