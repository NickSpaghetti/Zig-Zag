const std = @import("std");
const builtin = @import("builtin");
const ICursorService = @import("./../cursor_service_interface.zig").ICursorService;
const zp = @import("./../../models/zag_position.zig");

pub const CusorService = struct {
    const Self = @This();
    cursorService: ICursorService(type) = switch (builtin.os.tag) {
        .macos => cursorService: {
            var mcs = @import("../foundation/mac_cursor_service_foundation.zig").MacCursorService{};
            break :cursorService mcs.cursor();
        },
        else => std.debug.panic("unsupported OS {}", .{builtin.os.tag}),
    },

    pub fn moveCursor(self: *Self, position: zp.ZagPosition(type)) void {
        Self.cursorService.moveCursor(self, position);
    }
    pub fn getCurrentPosition(self: *Self) zp.ZagPosition(type) {
        return Self.cursorService.getCurrentPosition(self);
    }

    pub fn cursor(self: *Self) ICursorService(type) {
        return ICursorService(type).init(self, Self.moveCursor, self.getCurrentPosition);
    }
};
