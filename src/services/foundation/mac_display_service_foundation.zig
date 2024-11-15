const zp = @import("./../../models/zag_position.zig");
const mdb = @import("./../../brokers/displays/mac_display_broker.zig").MacDisplayBroker;
const std = @import("std");
const IDisplayService = @import("./../display_service_interface.zig").IDisplayService;

pub const MacDisplayService = struct {
    const Self = @This();

    pub fn getWidth(self: *Self, displayID: u32) usize {
        _ = self;
        return mdb.getDisplayWidth(displayID);
    }

    pub fn getHeight(self: *Self, displayID: u32) usize {
        _ = self;
        return mdb.getDisplayHeight(displayID);
    }

    pub fn getMainDisplayID(self: *Self) u32 {
        _ = self;
        return mdb.getDisplayID();
    }

    pub fn display(self: *Self) IDisplayService {
        return IDisplayService.init(self);
    }
};
