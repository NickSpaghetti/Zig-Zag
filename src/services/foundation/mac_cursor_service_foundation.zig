const zp = @import("./../../models/zag_position.zig");
const mcb = @import("./../../brokers/cursors/mac_cursor_broker.zig").MacCursorBroker;
const std = @import("std");
const ICursorService = @import("./../cursor_service_interface.zig").ICursorService;

pub const MacCursorService = struct {
    const Self = @This();
    pub fn moveCursor(self: *Self, position: zp.ZagPosition(f64)) void {
        _ = self;
        _ = position;
    }
    pub fn getCurrentPosition(self: *Self) zp.ZagPosition(f64) {
        _ = self;
        const cgPoint = mcb.getCurrentPoint();
        const positon = zp.ZagPosition(f64).init(cgPoint.x, cgPoint.y);
        return positon;
    }

    pub fn cursor(self: *Self) ICursorService(f64) {
        return ICursorService(f64).init(self);
    }
};
