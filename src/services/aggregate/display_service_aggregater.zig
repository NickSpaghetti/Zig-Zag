const IDisplayService = @import("./../display_service_interface.zig").IDisplayService;
const std = @import("std");
const builtin = @import("builtin");
const MacDisplayService = @import("../foundation/mac_display_service_foundation.zig").MacDisplayService;

pub fn GetDisplay() DisplayServiceUnion {
    switch (builtin.os.tag) {
        .macos => {
            var mds = MacDisplayService{};
            return DisplayServiceUnion{ .macos = mds.display() };
        },
        else => std.debug.panic("Unsuported OS {}", .{builtin.os.tag}),
    }
}

const DisplayServiceUnion = union(enum) {
    const Self = @This();
    macos: IDisplayService,
    windows: IDisplayService,
    linux: IDisplayService,

    pub fn getWidth(self: *Self, displayID: ?u32) usize {
        const id = displayID orelse self.getMainDisplayID();
        return switch (builtin.os.tag) {
            .macos => self.macos.getWidth(id),
            else => std.debug.panic("Unsuported OS {}", .{builtin.os.tag}),
        };
    }

    pub fn getHeight(self: *Self, displayID: ?u32) usize {
        const id = displayID orelse self.getMainDisplayID();
        return switch (builtin.os.tag) {
            .macos => self.macos.getHeight(id),
            else => std.debug.panic("Unsuported OS {}", .{builtin.os.tag}),
        };
    }

    pub fn getMainDisplayID(self: *Self) u32 {
        return switch (builtin.os.tag) {
            .macos => self.macos.getMainDisplayID(),
            else => std.debug.panic("Unsuported OS {}", .{builtin.os.tag}),
        };
    }
};
