const std = @import("std");
const RndGen = std.rand.DefaultPrng;
const CusorServiceUnion = @import("./services/aggregate/cursor_service_aggregater.zig");
const CoordinateGeneraterService = @import("./services/foundation/coordinate_generater_service_foundation.zig").CoordinateGeneraterService;

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
