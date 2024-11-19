const IDisplayService = @import("./../display_service_interface.zig").IDisplayService;
const std = @import("std");
const builtin = @import("builtin");
const MacDisplayService = @import("../foundation/mac_display_service_foundation.zig").MacDisplayService;
const WindowsDisplayService = @import("../foundation/windows_display_service.zig").WindosDisplayService;

pub fn GetDisplay() DisplayServiceUnion {
    switch (builtin.os.tag) {
        .macos => {
            var mds = MacDisplayService{};
            return DisplayServiceUnion{ .macos = mds.display() };
        },
        .windows => {
            var wds = WindowsDisplayService{};
            return DisplayServiceUnion{ .windows = wds.display() };
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
            .windows => self.windows.getWidth(id),
            else => std.debug.panic("Unsuported OS {}", .{builtin.os.tag}),
        };
    }

    pub fn getHeight(self: *Self, displayID: ?u32) usize {
        const id = displayID orelse self.getMainDisplayID();
        return switch (builtin.os.tag) {
            .macos => self.macos.getHeight(id),
            .windows => self.windows.getHeight(id),
            else => std.debug.panic("Unsuported OS {}", .{builtin.os.tag}),
        };
    }

    pub fn getMainDisplayID(self: *Self) u32 {
        return switch (builtin.os.tag) {
            .macos => self.macos.getMainDisplayID(),
            .windows => self.windows.getMainDisplayID(),
            else => std.debug.panic("Unsuported OS {}", .{builtin.os.tag}),
        };
    }
};
