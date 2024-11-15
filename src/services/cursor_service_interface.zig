const zp = @import("./../models/zag_position.zig");
const std = @import("std");
const assert = std.debug.assert;

pub fn ICursorService(comptime ZPT: type) type {
    return struct {
        // define interface fields: ptr,vtab
        ptr: *anyopaque, //ptr to instance
        vtab: *const VTab, //ptr to vtab
        const VTab = struct { // inmemory tables
            moveCursorFnPtr: *const fn (ptr: *anyopaque, zp.ZagPosition(ZPT)) void,
            getCurrentPositionFnPtr: *const fn (ptr: *anyopaque) zp.ZagPosition(ZPT),
        };

        // define interface methods wrapping vtable calls
        pub fn moveCursor(self: ICursorService(ZPT), position: zp.ZagPosition(ZPT)) void {
            self.vtab.moveCursorFnPtr(self.ptr, position);
        }
        pub fn getCurrentPosition(self: ICursorService(ZPT)) zp.ZagPosition(ZPT) {
            return self.vtab.getCurrentPositionFnPtr(self.ptr);
        }

        // cast concrete implementation types/objs to interface
        pub fn init(obj: anytype) ICursorService(ZPT) {
            const Ptr = @TypeOf(obj);
            const PtrInfo = @typeInfo(Ptr);
            assert(PtrInfo == .Pointer); // Must be a pointer
            assert(PtrInfo.Pointer.size == .One); // Must be a single-item pointer
            assert(@typeInfo(PtrInfo.Pointer.child) == .Struct); // Must point to a struct
            const impl = struct {
                fn moveCursor(ptr: *anyopaque, position: zp.ZagPosition(ZPT)) void {
                    const self: Ptr = @ptrCast(@alignCast(ptr));
                    self.moveCursor(position);
                }
                fn getCurrentPosition(ptr: *anyopaque) zp.ZagPosition(ZPT) {
                    const self: Ptr = @ptrCast(@alignCast(ptr));
                    return self.getCurrentPosition();
                }
            };
            return .{
                .ptr = obj,
                .vtab = &.{
                    .moveCursorFnPtr = impl.moveCursor,
                    .getCurrentPositionFnPtr = impl.getCurrentPosition,
                },
            };
        }
    };
}
