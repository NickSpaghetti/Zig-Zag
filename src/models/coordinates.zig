const std = @import("std");
pub const CoordinatesTypes = union(enum) {
    int32: struct {
        x: i32,
        y: i32,
    },
    float64: struct {
        x: f64,
        y: f64,
    },
};

pub const CordiantedPosition = struct {
    const Self = @This();
    point: CoordinatesTypes,
    pub fn isFloat64(self: *Self) bool {
        return switch (self.point) {
            .int32 => false,
            .float64 => true,
        };
    }
    pub fn isInt32(self: *Self) bool {
        return !self.isFloat64();
    }
    pub fn set_i32(x: i32, y: i32) Self {
        return CordiantedPosition{ .point = CoordinatesTypes{ .int32 = .{ .x = x, .y = y } } };
    }
    pub fn set_f64(x: f64, y: f64) Self {
        return CordiantedPosition{ .point = CoordinatesTypes{ .float64 = .{ .x = x, .y = y } } };
    }
    // pub fn init(comptime T: anytype, x: T, y: T) Self {
    //     return switch (@typeInfo(T)) {
    //         .Int => CordiantedPosition.set_i32(x, y),
    //         .Float => CordiantedPosition.set_f64(x, y),
    //         else => std.debug.panic("T {} is not a supported type.  The supported types are f64 and i32", .{T}),
    //     };
    // }
};
