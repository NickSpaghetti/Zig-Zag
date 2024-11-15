const zp = @import("./../../models/zag_position.zig");
const mcb = @import("./../../brokers/cursors/mac_cursor_broker.zig").MacCursorBroker;
const std = @import("std");
const ICursorService = @import("./../cursor_service_interface.zig").ICursorService;
var MacDisplayService = @import("mac_display_service_foundation.zig").MacDisplayService{};

pub const MacCursorService = struct {
    const Self = @This();
    const mds = MacDisplayService.display();
    pub fn moveCursor(self: *Self, position: zp.ZagPosition(f64)) void {
        _ = self;
        const dislayID = mds.getMainDisplayID();
        const point = mcb.createCGPoint(position.x, position.y);
        const event = mcb.createMouseEvent(point);
        if (event == null) {
            std.debug.panic("Failed to create event", .{});
        }
        defer mcb.releaseEvent(event);
        mcb.invokeCGEventPost(event);
        const err = mcb.moveCursor(dislayID, point);
        if (err != 0) {
            std.debug.panic("Error with moving pointer {}.  See https://developer.apple.com/documentation/coregraphics/cgerror\n", .{err});
        }
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
