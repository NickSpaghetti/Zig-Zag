const ICursorService = @import("./../cursor_service_interface.zig").ICursorService;
const std = @import("std");
const builtin = @import("builtin");
const Coordinates = @import("./../../models/coordinates.zig");
const MacCursorService = @import("../foundation/mac_cursor_service_foundation.zig").MacCursorService;

pub fn GetCursor() CursorServiceUnion {
    switch (builtin.os.tag) {
        .macos => {
            var mcs = MacCursorService{};
            return CursorServiceUnion{ .macos = mcs.cursor() };
        },
        else => std.debug.panic("Unsuported OS {}", .{builtin.os.tag}),
    }
}

const CursorServiceUnion = union(enum) {
    const Self = @This();
    macos: ICursorService,
    windows: ICursorService,
    linux: ICursorService,

    pub fn moveCursor(self: *Self, position: *const Coordinates.CordiantedPosition) void {
        switch (builtin.os.tag) {
            .macos => {
                self.macos.moveCursor(position);
            },
            else => std.debug.panic("Unsuported OS {}", .{builtin.os.tag}),
        }
    }
    pub fn getCurrentPosition(self: *Self) Coordinates.CordiantedPosition {
        return switch (builtin.os.tag) {
            .macos => self.macos.getCurrentPosition(),
            else => std.debug.panic("Unsuported OS {}", .{builtin.os.tag}),
        };
    }

    pub fn moveCursorSmooth(self: *Self, position: *const Coordinates.CordiantedPosition) void {
        var currentPosition = self.getCurrentPosition();
        const steps = @as(usize, @intFromFloat(@round(@abs(currentPosition.magnitude()))));
        self.moveCursor(position);
        for (0..steps) |i| {
            const t = @as(f64, @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(steps - 1)));
            const interploatedPosition = currentPosition.lerp(position, t);
            self.moveCursor(&interploatedPosition);
        }
    }
};
