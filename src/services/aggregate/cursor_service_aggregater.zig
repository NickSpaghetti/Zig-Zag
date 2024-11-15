const ICursorService = @import("./../cursor_service_interface.zig").ICursorService;
const zp = @import("./../../models/zag_position.zig");
const std = @import("std");
const builtin = @import("builtin");

pub fn GetCursor() CursorServiceUnion {
    switch (builtin.os.tag) {
        .macos => {
            var mcs = @import("../foundation/mac_cursor_service_foundation.zig").MacCursorService{};
            return CursorServiceUnion{ .macos = mcs.cursor() };
        },
        else => std.debug.panic("Unsuported OS {}", .{builtin.os.tag}),
    }
}

pub const CursorServiceUnion = union(enum) {
    const Self = @This();
    macos: ICursorService(f64),
    windows: *ICursorService(i32),
    linux: *ICursorService(f64),

    pub fn moveCursor(self: *Self, position: zp.ZagPosition(*anyopaque)) void {
        switch (self) {
            inline else => |s| s.moveCursor(position),
        }
    }
    pub fn getCurrentPosition(self: *Self) zp.ZagPosition(*anyopaque) {
        switch (self) {
            else => |s| {
                return s.getCurrentPosition();
            },
        }
    }
};
