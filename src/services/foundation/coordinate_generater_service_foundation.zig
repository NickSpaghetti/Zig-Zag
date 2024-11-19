const dsa = @import("./../aggregate/display_service_aggregater.zig");
const cp = @import("./../../models/coordinates.zig");
const std = @import("std");
const RndGen = std.rand.DefaultPrng;

pub const CoordinateGeneraterService = struct {
    pub fn GenerateCoordinate() cp.CordiantedPosition {
        var rnd = RndGen.init(blk: {
            var seed: u64 = undefined;
            std.posix.getrandom(std.mem.asBytes(&seed)) catch |err| {
                std.debug.panic("failed to generate seed err:{}", .{err});
            };
            break :blk seed;
        });
        var displayService = dsa.GetDisplay();
        const rng = &rnd.random();
        const generatedHeight = rng.intRangeAtMost(usize, 0, displayService.getHeight(null));
        const generatedWidth = rng.intRangeAtMost(usize, 0, displayService.getWidth(null));
        var empty = cp.CordiantedPosition.createEmptyPosition();
        if (empty.isInt32()) {
            return cp.CordiantedPosition.set_i32(@intCast(generatedHeight), @intCast(generatedWidth));
        }
        return cp.CordiantedPosition.set_f64(@floatFromInt(generatedHeight), @floatFromInt(generatedWidth));
    }

    pub fn GenerateCoordinateByPosition(comptime T: type) !cp.CordiantedPosition {
        if (!@typeInfo(T) == .Union) {
            @compileError("T must be a union type");
        }
        const unionInfo = @typeInfo(T).Union;
        const varriants = blk: {
            for (unionInfo.fields) |field| {
                if (std.mem.eql(u8, field.name, "int32")) {
                    break :blk cp.CoordinatesTypes.int32;
                }
                if (std.mem.eql(u8, field.name, "float64")) {
                    break :blk cp.CoordinatesTypes.float64;
                }
                break :blk false;
            }
        };

        var rnd = RndGen.init(blk: {
            var seed: u64 = undefined;
            std.posix.getrandom(std.mem.asBytes(&seed)) catch |err| {
                std.debug.panic("failed to generate seed err:{}", .{err});
            };
            break :blk seed;
        });

        const displayService = dsa.GetDisplay();
        const rng = &rnd.random();
        const generatedHeight = rng.intRangeAtMost(usize, 0, displayService.getHeight());
        const generatedWidth = rng.intRangeAtMost(usize, 0, displayService.getWidth());

        return switch (varriants) {
            .cp.CoordinatesTypes.int32 => cp.CordiantedPosition.set_i32(@intCast(generatedHeight), @intCast(generatedWidth)),
            .cp.CoordinatesTypes.float64 => cp.CordiantedPosition.set_f64(@floatFromInt(generatedHeight), @floatFromInt(generatedWidth)),
            .false => @compileError("T must be a CoordinateTypes enum"),
        };
    }
};
