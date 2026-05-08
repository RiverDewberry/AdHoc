const AdHoc = @import("AdHoc");

const GridComponent = struct {
    x: i32,
    y: i32,
    width: i32,
    height: i32,

    pub fn init() GridComponent
    {
        return GridComponent {
            .x = 0, .y = 0, .width = 1, .height = 1
        };
    }

    pub fn deinit(self: GridComponent) void
    {
        _ = self;
    }
};

const GridData = struct {
    gridOriginPosition: struct {x: i32, y: i32},
    gridSquareSize: i32,

    pub fn init() GridData
    {
        return GridData {
            .gridOriginPosition = .{
                .x = 0,
                .y = 0
            },

            .gridSquareSize = 1
        };
    }

    pub fn deinit(self: GridData) void
    {
        _ = self;
    }
};

const GridFunctions = struct {
    pub fn getWorldPosition(
        _:GridFunctions,
        sys: AdHoc.SystemStructure(system),
        entity: AdHoc.Entity
        )
        struct{x: i32, y: i32}
    {
        var gridSystem = sys;
        const component = gridSystem.getComponent(entity);

        return .{
            .x = component.x * sys.data.gridSquareSize + sys.data.gridOriginPosition.x,
            .y = component.y * sys.data.gridSquareSize + sys.data.gridOriginPosition.y
        };
    }

    pub fn getWorldDimentions(
        _:GridFunctions,
        sys: AdHoc.SystemStructure(system),
        entity: AdHoc.Entity
        )
        struct{width: i32, height: i32}
    {
        var gridSystem = sys;
        const component = gridSystem.getComponent(entity);

        return .{
            .width = component.width * sys.data.gridSquareSize,
            .height = component.height * sys.data.gridSquareSize
        };
    }

    pub fn getGridPosition(
        _:GridFunctions,
        sys: AdHoc.SystemStructure(system),
        x: i32, y: i32
        )
        struct{x: i32, y: i32}
    {
        return .{
            .x = (x - sys.data.gridOriginPosition.x) / sys.data.gridSquareSize,
            .y = (y - sys.data.gridOriginPosition.y) / sys.data.gridSquareSize
        };
    }

    pub fn getGridDimentions(
        _:GridFunctions,
        sys: AdHoc.SystemStructure(system),
        width: i32, height: i32
        )
        struct{width: i32, height: i32}
    {
        return .{
            .width = width / sys.data.gridSquareSize,
            .height = height / sys.data.gridSquareSize
        };
    }
};

pub const system = AdHoc.System.init(
    GridComponent,
    GridData,
    GridFunctions,
    "grid"
);
