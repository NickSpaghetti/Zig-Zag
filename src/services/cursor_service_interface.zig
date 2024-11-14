const ZagPositon = @import("./../models/zag_position.zig");
const std = @import("std");
const assert = std.debug.assert;
const ICursorService = struct {
    ptr: *anyopaque,
    moveCursorFnPtr: *const fn (ptr: *anyopaque, ZagPositon) void,
    getCurrentPositionFnPtr: *const fn (ptr: *anyopaque) ZagPositon,

    pub fn init(
        obj: anytype,
        comptime moveCursorFn: fn (ptr: @TypeOf(obj), position: ZagPositon) void,
        comptime getCurrentPositionFn: fn (ptr: @TypeOf(obj)) ZagPositon,
    ) ICursorService {
        const T = @TypeOf(obj);
        const ptrInfo = @typeInfo(T);
        assert(ptrInfo == .Pointer); // Must be a pointer
        assert(ptrInfo.Pointer.size == .One); // Must be a single-item pointer
        assert(@typeInfo(ptrInfo.Pointer.child) == .Struct); // Must point to a struct
        const impl = struct {
            fn moveCursor(ptr: *anyopaque, position: ZagPositon) void {
                const self: T = @ptrCast(@alignCast(ptr));
                moveCursorFn(self, position);
            }
            fn getCurrentPosition(ptr: *anyopaque) ZagPositon {
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

    pub fn moveCursor(self: ICursorService, position: ZagPositon) void {
        self.moveCursorFnPtr(self.ptr, position);
    }

    pub fn getCurrentPosition(self: ICursorService) ZagPositon {
        return self.getCurrentPositionFnPtr(self.ptr);
    }
};

test "ICursor init" {
    const AnonCursor = struct {
        const Self = @This();
        hasMoved: bool = false,
        pub fn moveCursor(self: *Self, _: ZagPositon) void {
            self.hasMoved = true;
        }
        pub fn getCurrentPosition(_: *Self) ZagPositon {
            return ZagPositon(f64).init(1.1, 2.2);
        }
    };
    var anonCursor = AnonCursor{};
    var cursor = ICursorService.init(&anonCursor, anonCursor.moveCursor, anonCursor.getCurrentPosition);
    const pos = ZagPositon(f64).init(1.1, 2.2);
    try std.testing.expect(!cursor.hasMoved);
    try std.testing.expect(cursor.getCurrentPosition().x == pos.x);
    cursor.moveCursor(pos);
    try std.testing.expect(cursor.hasMoved);
}
