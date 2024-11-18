const std = @import("std");
const builtin = @import("builtin");
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

    pub fn createEmptyPosition() CordiantedPosition {
        return switch (builtin.os.tag) {
            .macos => Self.set_f64(0.0, 0.0),
            .windows => Self.set_i32(0, 0),
            else => @compileError("Unsupported OS"),
        };
    }

    pub fn set_i32(x: i32, y: i32) Self {
        return CordiantedPosition{ .point = CoordinatesTypes{ .int32 = .{ .x = x, .y = y } } };
    }

    pub fn set_f64(x: f64, y: f64) Self {
        return CordiantedPosition{ .point = CoordinatesTypes{ .float64 = .{ .x = x, .y = y } } };
    }

    pub fn addCoordiantes(self: *Self, addend: *const CordiantedPosition) CordiantedPosition {
        if (self.isInt32()) {
            return Self.set_i32(self.point.int32.x + addend.point.int32.x, self.point.int32.y + addend.point.int32.y);
        }
        return Self.set_f64(self.point.float64.x + addend.point.float64.x, self.point.float64.y + addend.point.float64.y);
    }

    pub fn subtractCoordiantes(self: *Self, minuend: *const CordiantedPosition) CordiantedPosition {
        if (self.isInt32()) {
            return Self.set_i32(self.point.int32.x - minuend.point.int32.x, self.point.int32.y - minuend.point.int32.y);
        }
        return Self.set_f64(self.point.float64.x - minuend.point.float64.x, self.point.float64.y - minuend.point.float64.y);
    }

    pub fn mutiplyCoordiantes(self: *Self, mulitiplier: *const CordiantedPosition) CordiantedPosition {
        if (self.isInt32()) {
            return Self.set_i32(self.point.int32.x * mulitiplier.point.int32.x, self.point.int32.y * mulitiplier.point.int32.y);
        }
        return Self.set_f64(self.point.float64.x * mulitiplier.point.float64.x, self.point.float64.y * mulitiplier.point.float64.y);
    }

    pub fn divideCoordiantes(self: *Self, divisor: *const CordiantedPosition) CordiantedPosition {
        if (self.isInt32()) {
            return Self.set_i32(self.point.int32.x / divisor.point.int32.x, self.point.int32.y / divisor.point.int32.y);
        }
        return Self.set_f64(self.point.float64.x / divisor.point.float64.x, self.point.float64.y / divisor.point.float64.y);
    }

    pub fn equalTo(self: *Self, position: *const CordiantedPosition) bool {
        if (self.isInt32()) {
            return self.point.int32.x == position.point.int32.x and self.point.int32.y == position.point.int32.y;
        }

        return self.point.float64.x == position.point.float64.x and self.point.float64.y == position.point.float64.y;
    }

    pub fn lessThan(self: *Self, position: *const CordiantedPosition) bool {
        if (self.isInt32()) {
            return self.point.int32.x < position.point.int32.x and self.point.int32.y < self.point.int32.y;
        }
        return self.point.float64.x < position.point.float64.x and self.point.float64.y < self.point.float64.y;
    }

    pub fn lessThanOrEqualTo(self: *Self, position: *const CordiantedPosition) bool {
        return self.lessThan(position) or self.equalTo(position);
    }

    pub fn greaterThan(self: *Self, position: *const CordiantedPosition) bool {
        if (self.isInt32()) {
            return self.point.int32.x > position.point.int32.x and self.point.int32.y > self.point.int32.y;
        }
        return self.point.float64.x > position.point.float64.x and self.point.float64.y > self.point.float64.y;
    }

    pub fn greaterThanOrEqualTo(self: *Self, position: *const CordiantedPosition) bool {
        return self.greaterThan(position) or self.equalTo(position);
    }

    pub fn magnitude(self: *Self) f64 {
        if (self.isInt32()) {
            return std.math.sqrt((@as(f64, @floatFromInt(self.point.int32.x)) * @as(f64, @floatFromInt(self.point.int32.x))) + (@as(f64, @floatFromInt(self.point.int32.y)) * @as(f64, @floatFromInt(self.point.int32.y))));
        }
        return std.math.sqrt((self.point.float64.x * self.point.float64.x) + (self.point.float64.y * self.point.float64.y));
    }

    pub fn lerp(self: *Self, position: *const CordiantedPosition, t: f64) CordiantedPosition {
        if (self.isInt32()) {
            return CordiantedPosition.set_i32(@intCast(self.point.int32.x + (position.point.int32.x - self.point.int32.x) * @as(i32, @intFromFloat(t))), @intCast(self.point.int32.y + (position.point.int32.y - self.point.int32.y) * @as(i32, @intFromFloat(t))));
        }
        return CordiantedPosition.set_f64(self.point.float64.x + (position.point.float64.x - self.point.float64.x) * t, self.point.float64.y + (position.point.float64.y - self.point.float64.y) * t);
    }
};
