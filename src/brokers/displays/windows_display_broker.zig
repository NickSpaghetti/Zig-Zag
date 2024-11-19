const std = @import("std");
const c = @cImport({
    @cInclude("windows.h");
    @cInclude("winuser.h");
});

pub const WindowsDisplayBroker = struct {
    pub fn getDisplayHeight(deviceName: [32]u16) usize {
        const devMode = getDisplaySettings(deviceName);
        return devMode.dmPelsHeight;
    }

    pub fn getDisplayWidth(deviceName: [32]u16) usize {
        const devMode = getDisplaySettings(deviceName);
        return devMode.dmPelsWidth;
    }

    pub fn getDisplayIDs() ![]const [32]u16 {
        const allocator = std.heap.page_allocator;
        var displayIDs = try allocator.alloc([32]u16, 0);
        var device: c.DISPLAY_DEVICEW = undefined;
        device.cb = @sizeOf(c.DISPLAY_DEVICEW);
        var displayIndex: u32 = 0;
        while (c.EnumDisplayDevicesW(null, displayIndex, &device, 0)) {
            if (device.StateFlags and c.DISPLAY_DEVICE_ACTIVE != 0) {
                _ = std.mem.copy(u16, &displayIDs[displayIndex][0..], &device.DeviceName[0..]);
            }
            displayIndex += 1;
        }
        return displayIDs;
    }

    pub fn setDisplay(deviceName: [32]u16) !void {
        var devMode: c.DEVMODEW = undefined;
        devMode.dmSize = @sizeOf(c.DEVMODEW);
        if (!c.EnumDisplayDevicesExW(&deviceName, c.ENUM_CURRENT_SETTINGS, &devMode, 0)) {
            std.debug.panic("Failed to get  display settings {}\n", .{deviceName});
            return error.EnumDisplaySettingsFailed;
        }
        const result = c.ChangeDisplaySetingsExW(&deviceName, &devMode, null, c.CDS_UPDATEREGISTRY, null);
        if (result != c.DISP_CHANGE_SUCCESSFUL) {
            std.debug.panic("Failed to change display settings {}\n", .{result});
            return error.DisplayChangeFailed;
        }
    }

    fn getDisplaySettings(deviceName: [32]u16) !c.DEVMODEW {
        var devMode: c.DEVMODEW = undefined;
        devMode.dmSize = @sizeOf(c.DEVMODEW);
        if (!c.EnumDisplaySettingsExW(&deviceName, c.ENUM_CURRENT_SETTINGS, &devMode, 0)) {
            return error.EnumDisplaySettingsFailed;
        }
        return devMode;
    }
};
