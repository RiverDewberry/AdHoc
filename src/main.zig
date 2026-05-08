const std = @import("std");
const rl = @import("raylib");

const gridSystem = @import("./systems/gridPositionSystem.zig");
const systems = [_]AdHoc.System {gridSystem.system};

const Io = std.Io;

const AdHoc = @import("AdHoc");

var e: AdHoc.Entity = undefined;

pub fn loop(game: *AdHoc.AdHocType(&systems)) void
{
    var grid = &game.systems.grid;
    _ = &grid;
    var gridFunctions = grid.*.functions;

    grid.*.data.gridOriginPosition.x += 1;
    if (@rem(grid.*.data.gridOriginPosition.x, 60) == 59)
    {
        grid.*.getComponentPtr(e).*.y += 1;
    }

    const position = gridFunctions.getWorldPosition(grid.*, e);
    const dimentions = gridFunctions.getWorldDimentions(grid.*, e);

    rl.clearBackground(rl.Color.red);

    rl.drawRectangle(
        position.x,
        position.y,
        dimentions.width,
        dimentions.height,
        rl.Color.black
    );
}

pub fn main(init: std.process.Init) !void
{
    var game = AdHoc.init(init.gpa, &systems, "test", 500, 500);
    defer game.deinit();

    game.systems.grid.data.gridSquareSize = 10;

    rl.setTargetFPS(60);

    e = game.createEntity();
    game.systems.grid.addEntity(e);

    game.runGameLoop(loop);
    game.removeEntity(e);
}
