const std = @import("std");
const Io = std.Io;

const AdHoc = @import("AdHoc");

const SystemTest = struct {
    data: i32,

    pub fn init(_:SystemTest) SystemTest
    {
        std.log.debug("SystemTest: init", .{});
        return SystemTest{.data = 0};
    }

    pub fn deinit(self: SystemTest) void
    {
        std.log.debug("SystemTest: deinit", .{});
        _ = self;
    }

    pub fn addEntity(self: SystemTest, entity: AdHoc.Entity) void
    {
        std.log.debug("SystemTest: add entity {}", .{entity});
        _ = self;
        return;
    }

    pub fn removeEntity(self: SystemTest, entity: AdHoc.Entity) void
    {
        std.log.debug("SystemTest: remove entity {}", .{entity});
        _ = self;
        return;
    }

    pub fn hasEntity(self: SystemTest, entity: AdHoc.Entity) bool
    {
        std.log.debug("SystemTest: check for entity {}", .{entity});
        _ = self;
        return true;
    }
};

pub fn main(init: std.process.Init) !void
{
    const testSystem = AdHoc.System.init(SystemTest, "testSys");

    const systems = [_]AdHoc.System {testSystem};

    var game = AdHoc.init(init.gpa, &systems);
    defer game.deinit();

    const e = game.createEntity();
    game.systems.testSys.addEntity(e);
    game.removeEntity(e);
}
