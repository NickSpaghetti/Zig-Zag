const std = @import("std");
const builtin = @import("builtin");
const ICursorService = @import("./../cursor_service_interface.zig").ICursorService;
const zp = @import("./../../models/zag_position.zig");

pub const CusorService = struct {
    const Self = @This();
    const cursorService: ICursorService = switch (builtin.os.tag) {
        .macos => cursorService: {
            var mcs = @import("../foundation/mac_cursor_service_foundation.zig").MacCursorService{};
            break :cursorService mcs.cursor();
        },
        else => std.debug.panic("unsupported OS {}", .{builtin.os.tag}),
    };

    pub fn moveCursor(self: *Self, position: zp.ZagPosition(*anyopaque)) void {
        cursorService.moveCursor(self, position);
    }
    pub fn getCurrentPosition(self: *Self) zp.ZagPosition(*anyopaque) {
        const pos = cursorService.getCurrentPosition(self);
        return zp.ZagPosition(*anyopaque).init(pos.x, pos.y);
    }

    pub fn cursor(self: *Self) ICursorService(*anyopaque) {
        return ICursorService([]u8).init(self);
    }

    fn toCursorZagPosition(T: anytype) ![]const u8 {
        return switch (T) {
            .f64 => f64ToString(T),
            .i32 => i32ToString(T),
            else => std.debug.panic("Unsupported Type", .{@TypeOf(T)}),
        };
    }

    fn f64ToString(value: f64) ![]const u8 {
        return std.fmt.allocPrint(std.heap.page_allocator, "{:.2f}", .{value}) catch |err| {
            return err;
        };
    }

    fn i32ToString(value: i32) ![]const u8 {
        return std.fmt.allocPrint(std.heap.page_allocator, "{}", .{value}) catch |err| {
            return err;
        };
    }
};
