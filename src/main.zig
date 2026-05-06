const std = @import("std");
const Io = std.Io;

const AdHoc = @import("AdHoc");

const SystemTest = struct {
    data: i32,

    pub fn init(a: void) SystemTest
    {
        _ = a;
        return SystemTest{.data = 0};
    }

    pub fn addEntity(self: SystemTest, entity: AdHoc.Entity, args: void) void
    {
        _ = self;
        _ = entity;
        _ = args;
        return;
    }

    pub fn removeEntity(self: SystemTest, entity: AdHoc.Entity) void
    {
        _ = self;
        _ = entity;
        return;
    }

    pub fn hasEntity(self: SystemTest, entity: AdHoc.Entity) bool
    {
        _ = self;
        _ = entity;
        return true;
    }
};

pub fn main() !void
{
    const testSystem = AdHoc.System.init(SystemTest, "test");

    const systems = [_]AdHoc.System {testSystem};
    const testType = AdHoc.AdHoc(&systems);
}
