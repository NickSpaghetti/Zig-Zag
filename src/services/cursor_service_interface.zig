const std = @import("std");
const assert = std.debug.assert;
const Coordinates = @import("./../models/coordinates.zig");

pub const ICursorService = struct {
    // define interface fields: ptr,vtab
    ptr: *anyopaque, //ptr to instance
    vtab: *const VTab, //ptr to vtab
    const VTab = struct { // inmemory tables
        moveCursorFnPtr: *const fn (ptr: *anyopaque, *const Coordinates.CordiantedPosition) void,
        getCurrentPositionFnPtr: *const fn (ptr: *anyopaque) Coordinates.CordiantedPosition,
    };

    // define interface methods wrapping vtable calls
    pub fn moveCursor(self: ICursorService, position: *const Coordinates.CordiantedPosition) void {
        self.vtab.moveCursorFnPtr(self.ptr, position);
    }
    pub fn getCurrentPosition(self: ICursorService) Coordinates.CordiantedPosition {
        return self.vtab.getCurrentPositionFnPtr(self.ptr);
    }

    // cast concrete implementation types/objs to interface
    pub fn init(obj: anytype) ICursorService {
        const Ptr = @TypeOf(obj);
        const PtrInfo = @typeInfo(Ptr);
        assert(PtrInfo == .Pointer); // Must be a pointer
        assert(PtrInfo.Pointer.size == .One); // Must be a single-item pointer
        assert(@typeInfo(PtrInfo.Pointer.child) == .Struct); // Must point to a struct
        const impl = struct {
            fn moveCursor(ptr: *anyopaque, position: *const Coordinates.CordiantedPosition) void {
                const self: Ptr = @ptrCast(@alignCast(ptr));
                self.moveCursor(position);
            }
            fn getCurrentPosition(ptr: *anyopaque) Coordinates.CordiantedPosition {
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
