const wdb = @import("./../../brokers/displays/windows_display_broker.zig").WindowsDisplayBroker;
const std = @import("std");
const IDisplayService = @import("./../display_service_interface.zig").IDisplayService;

pub const WindosDisplayService = struct {
    const Self = @This();

    pub fn getWidth(self: *Self, displayID: u32) usize {
        _ = self;
        return wdb.getDisplayWidth(displayID);
    }

    pub fn getHeight(self: *Self, displayID: u32) usize {
        _ = self;
        return wdb.getDisplayHeight(displayID);
    }

    pub fn getMainDisplayID(self: *Self) u32 {
        _ = self;
        const displayIDs = wdb.getDisplayIDs();
        const mainDisplayID = displayIDs[0];
        return mainDisplayID;
    }

    pub fn setDisplay(self: *Self, displayID: u32) void {
        _ = self;
        var displayName: [32]u16 = [_]u16{0} ** 32;
        displayName[0] = @as(u16, @intCast(displayID & 0xFFF));
        displayName[1] = @as(u16, @intCast(displayID >> 16 & 0xFFFF));
        wdb.setDisplay(displayName);
    }

    pub fn display(self: *Self) IDisplayService {
        return IDisplayService.init(self);
    }
};
