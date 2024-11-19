const std = @import("std");
const assert = std.debug.assert;

pub const IDisplayService = struct {
    // define interface fields: ptr,vtab
    ptr: *anyopaque, //ptr to instance
    vtab: *const VTab, //ptr to vtab
    const VTab = struct { // inmemory tables
        getWidthPtrFn: *const fn (ptr: *anyopaque, displayID: u32) usize,
        getHeightPtrFn: *const fn (ptr: *anyopaque, displayID: u32) usize,
        getMainDisplayIDPtrFn: *const fn (ptr: *anyopaque) u32,
    };

    pub fn getWidth(self: IDisplayService, displayID: u32) usize {
        return self.vtab.getWidthPtrFn(self.ptr, displayID);
    }

    pub fn getHeight(self: IDisplayService, displayID: u32) usize {
        return self.vtab.getHeightPtrFn(self.ptr, displayID);
    }

    pub fn getMainDisplayID(self: IDisplayService) u32 {
        return self.vtab.getMainDisplayIDPtrFn(self.ptr);
    }

    pub fn init(obj: anytype) IDisplayService {
        const PtrType = @TypeOf(obj);
        const PtrInfo = @typeInfo(PtrType);
        assert(PtrInfo == .Pointer); // Must be a pointer
        assert(PtrInfo.Pointer.size == .One); // Must be a single-item pointer
        assert(@typeInfo(PtrInfo.Pointer.child) == .Struct); // Must point to a struct
        const impl = struct {
            fn getWidth(ptr: *anyopaque, displayID: u32) usize {
                const self: PtrType = @ptrCast(@alignCast(ptr));
                return self.getWidth(displayID);
            }
            fn getHeight(ptr: *anyopaque, displayID: u32) usize {
                const self: PtrType = @ptrCast(@alignCast(ptr));
                return self.getHeight(displayID);
            }
            fn getMainDisplayID(ptr: *anyopaque) u32 {
                const self: PtrType = @ptrCast(@alignCast(ptr));
                return self.getMainDisplayID();
            }
        };
        return .{
            .ptr = obj,
            .vtab = &.{ .getWidthPtrFn = impl.getWidth, .getHeightPtrFn = impl.getHeight, .getMainDisplayIDPtrFn = impl.getMainDisplayID },
        };
    }
};
