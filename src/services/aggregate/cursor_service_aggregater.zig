const std = @import("std");
const builtin = @import("builtin");
const ICursorService = @import("./../cursor_service_interface.zig").ICursorService;
const zp = @import("./../../models/zag_position.zig");

pub const CusorService = struct {
    const Self = @This();
    const osTag = builtin.os.tag;
    cursorService: ICursorService(type) = switch (builtin.os.tag) {
        .macos => @import("../foundation/mac_cursor_service_foundation.zig").MacCursorService.Cursor(),
        else => @panic("unsupported OS"),
    },

    pub fn moveCursor(self: Self, position: zp.ZagPosition) void {
        Self.cursorService.moveCursor(self, position);
    }
    pub fn getCurrentPosition(self: Self) zp.ZagPosition {
        return Self.cursorService.getCurrentPosition(self);
    }

    pub fn Cursor(self: Self) ICursorService {
        return ICursorService().init(&self, self.moveCursor, self.getCurrentPosition);
    }
};

// fn createCursorService() ICursorService(type) {
//     return switch (builtin.os.tag) {
//         .macos => {
//             @import()
//         }
//     }
// }
