const zp = @import("./../models/zag_position.zig");
const std = @import("std");
const assert = std.debug.assert;

pub const ICursorService = struct {
    ptr: *anyopaque,
    moveCursorFnPtr: *const fn (ptr: *anyopaque, positoin: zp.ZagPosition(type)) void,
    //moveCursorFnPtr2: *const fn (ptr: *anyopaque, positoin: zp.ZagPosition) void,
    getCurrentPositionFnPtr: *const fn (ptr: *anyopaque) zp,

    pub fn init(
        comptime ZPT: type,
        obj: anytype,
        comptime moveCursorFn: fn (ptr: @TypeOf(obj), position: zp.ZagPosition(ZPT)) void,
        //comptime moveCursorFn: fn (ptr: @TypeOf(obj), position: zp.ZagPosition) void,
        comptime getCurrentPositionFn: fn (ptr: @TypeOf(obj)) zp,
    ) ICursorService {
        const T = @TypeOf(obj);
        const ptrInfo = @typeInfo(T);
        assert(ptrInfo == .Pointer); // Must be a pointer
        assert(ptrInfo.Pointer.size == .One); // Must be a single-item pointer
        assert(@typeInfo(ptrInfo.Pointer.child) == .Struct); // Must point to a struct
        const impl = struct {
            fn moveCursor(ptr: *anyopaque, position: zp.ZagPosition(ZPT)) void {
                const self: T = @ptrCast(@alignCast(ptr));
                moveCursorFn(self, position);
            }
            fn getCurrentPosition(ptr: *anyopaque) zp {
                const self: T = @ptrCast(@alignCast(ptr));
                return getCurrentPositionFn(self);
            }
        };

        return .{
            .ptr = obj,
            .moveCursorFnPtr = impl.moveCursor,
            .getCurrentPositionFnPtr = impl.getCurrentPosition,
        };
    }

    pub fn moveCursor(comptime T: type, self: ICursorService, position: zp.ZagPosition(T)) void {
        self.moveCursorFnPtr(self.ptr, position);
    }

    pub fn getCurrentPosition(self: ICursorService) zp {
        return self.getCurrentPositionFnPtr(self.ptr);
    }

    fn interface(comptime T: type, comptime fooFn: fn (comptime T: type, ptr: *const zp.ZagPosition(T), p: zp.ZagPosition(T)) zp.ZagPosition(T), obj: zp.ZagPosition(T)) void {
        fooFn(T, &obj, obj);
    }
};

test "ICursor init" {
    const AnonCursor = struct {
        const Self = @This();
        hasMoved: bool = false,
        pub fn moveCursor(self: *Self, _: zp) void {
            self.hasMoved = true;
        }
        pub fn getCurrentPosition(_: *Self) zp {
            return zp.ZagPosition(f64).init(1.1, 2.2);
        }
    };
    var anonCursor = AnonCursor{};
    var cursor = ICursorService.init(f64, &anonCursor, anonCursor.moveCursor, anonCursor.getCurrentPosition);
    const pos = zp.ZagPosition(f64).init(1.1, 2.2);
    try std.testing.expect(!cursor.hasMoved);
    try std.testing.expect(cursor.getCurrentPosition().x == pos.x);
    cursor.moveCursor(pos);
    try std.testing.expect(cursor.hasMoved);
}
