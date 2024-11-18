const Coordinates = @import("./../../models/coordinates.zig");
const mcb = @import("./../../brokers/cursors/mac_cursor_broker.zig").MacCursorBroker;
const std = @import("std");
const ICursorService = @import("./../cursor_service_interface.zig").ICursorService;
var MacDisplayService = @import("mac_display_service_foundation.zig").MacDisplayService{};

pub const MacCursorService = struct {
    const Self = @This();
    const mds = MacDisplayService.display();
    pub fn moveCursor(self: *Self, position: *const Coordinates.CordiantedPosition) void {
        _ = self;
        // if (position.*.isInt32()) {
        //     std.debug.panic("Macos only supports CoordianteTypes of float64", .{});
        // }
        const dislayID = mds.getMainDisplayID();
        const point = mcb.createCGPoint(position.*.point.float64.x, position.*.point.float64.y);
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
    pub fn getCurrentPosition(self: *Self) Coordinates.CordiantedPosition {
        _ = self;
        const cgPoint = mcb.getCurrentPoint();
        const cord = Coordinates.CordiantedPosition.set_f64(cgPoint.x, cgPoint.y);
        return cord;
    }

    pub fn cursor(self: *Self) ICursorService {
        return ICursorService.init(self);
    }
};
