const zp = @import("./../../models/zag_position.zig");
const mcb = @import("./../../brokers/cursors/mac_cursor_broker.zig");
const std = @import("std");
const ICursorService = @import("./../cursor_service_interface.zig").ICursorService;

pub const MacCursorService = struct {
    const Self = @This();
    pub fn moveCursor(self: *Self, position: zp.ZagPosition(f64)) void {
        _ = self;
        _ = position;
    }
    pub fn getCurrentPosition(self: *Self) zp {
        _ = self;
        const cgPoint = mcb.getCurrentPoint();
        const positon = zp.ZagPosition(f64).init(cgPoint.x, cgPoint.y);
        return positon;
    }

    pub fn Cursor() ICursorService {
        return ICursorService.init(f64, &Self, Self.moveCursor, Self.getCurrentPosition);
    }
};
