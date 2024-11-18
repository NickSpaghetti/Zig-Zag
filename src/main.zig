const std = @import("std");
const c = @cImport({
    @cInclude("CoreGraphics/CoreGraphics.h");
    @cInclude("CoreFoundation/CoreFoundation.h");
});
const RndGen = std.rand.DefaultPrng;
const CusorServiceUnion = @import("./services/aggregate/cursor_service_aggregater.zig");
const MacCursorService = @import("./services/foundation/mac_cursor_service_foundation.zig").MacCursorService;
const MacDisplayService = @import("./services/foundation/mac_display_service_foundation.zig").MacDisplayService;
const CoordinateGeneraterService = @import("./services/foundation/coordinate_generater_service_foundation.zig").CoordinateGeneraterService;

const kCGEventPointMoved = 5;
const kCGHIDEventTap = 0;

pub fn main() !void {
    var cs = CusorServiceUnion.GetCursor();
    var rnd = RndGen.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    var generatedPoint = &CoordinateGeneraterService.GenerateCoordinate();
    while (true) {
        cs.moveCursorSmooth(generatedPoint);
        generatedPoint = &CoordinateGeneraterService.GenerateCoordinate();
        const sleepTime = @as(u64, @intFromFloat(try GenerateRnd(&rnd, 5_000_000_000)));
        std.time.sleep(sleepTime);
    }
}

pub fn GenerateRnd(rnd: *std.rand.DefaultPrng, constaint: usize) !f64 {
    const rng = rnd.random();
    const generatedInt = rng.intRangeAtMost(usize, 0, constaint);
    return @as(f64, @floatFromInt(generatedInt));
}
