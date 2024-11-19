const Coordinates = @import("./../../models/coordinates.zig");
const wcb = @import("./../../brokers/cursors/./windows_cursor_broker.zig").WindowsCursorBroker;
const std = @import("std");
const ICursorService = @import("./../cursor_service_interface.zig").ICursorService;
var WindosDisplayService = @import("windows_display_service.zig").WindosDisplayService{};

pub const WindowsCursorService = struct {
    const Self = @This();
    const wds = WindosDisplayService.display();
    pub fn moveCursor(self: *Self, position: *const Coordinates.CordiantedPosition) void {
        _ = self;
        const temp = @constCast(position);
        if (temp.*.isFloat64()) {
            std.debug.panic("Windows only supports CoordianteTypes of int32", .{});
        }

        const displayID = wds.getMainDisplayID();
        const point = wcb.createPoint(position.*.point.int32.x, position.*.point.int32.y);
        WindosDisplayService.setDisplay(displayID);
        const err = wcb.moveCursor(displayID, point);
        if (err != 0) {
            std.debug.panic("Error with moving pointer {}.  See https://developer.apple.com/documentation/coregraphics/cgerror\n", .{err});
        }
    }
    pub fn getCurrentPosition(self: *Self) Coordinates.CordiantedPosition {
        _ = self;
        const point = wcb.getCurrentPoint();
        const cord = Coordinates.CordiantedPosition.set_i32(point.x, point.y);
        return cord;
    }

    pub fn cursor(self: *Self) ICursorService {
        return ICursorService.init(self);
    }
};
