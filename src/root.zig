const std = @import("std");
const rl = @import("raylib");
const Io = std.Io;

pub const Entity = i32;

pub const System = struct {
    ///components for entities in the system
    C: type,

    ///system functions
    F: type,

    ///system global data, should have init and deinit functions
    D: type,

    name: []const u8,

    pub fn init(
        comptime Component: type,
        comptime Data: type,
        comptime Functions: type,
        comptime name: []const u8
        ) System
    {

        inline for (std.meta.fields(Functions)) |fns| {
            if (!std.meta.hasFn(Functions, fns.name)) {
                @compileError(name ++ " Function." ++ fns.name ++ " is not a function");
            }
        }

        inline for (std.meta.declarations(Data)) |dat| {
            if (
                !((comptime std.mem.eql(u8, "init", dat.name)) or
                (comptime std.mem.eql(u8, "deinit", dat.name)))
            )
            {
                if (std.meta.hasFn(Data, dat.name) ) {
                    @compileError(name ++ " Data." ++ dat.name ++ " is a function");
                }
            }
        }

        inline for (std.meta.declarations(Component)) |com| {
            if (
                !((comptime std.mem.eql(u8, "init", com.name)) or
                (comptime std.mem.eql(u8, "deinit", com.name)))
            )
            {
                if (std.meta.hasFn(Component, com.name)) {
                    @compileError(name ++ " Component." ++ com.name ++ " is a function");
                }
            }
        }

        if (!std.meta.hasFn(Data, "init"))
        {
            @compileError(name ++ " Data does not have init function");
        }

        if (!std.meta.hasFn(Data, "deinit"))
        {
            @compileError(name ++ " Data does not have deinit function");
        }
        
        if (!std.meta.hasFn(Component, "init"))
        {
            @compileError(name ++ " Component does not have init function");
        }

        if (!std.meta.hasFn(Component, "deinit"))
        {
            @compileError(name ++ " Component does not have deinit function");
        }

        return System {
            .C = Component,
            .D = Data,
            .F = Functions,
            .name = name
        };
    }
};

pub fn SystemStructure(comptime system: System) type
{
    return struct {
        const Self = @This();

        data: system.D,
        functions: system.F,
        components: std.AutoHashMap(Entity, system.C),

        pub fn init(_: Self, allocator: std.mem.Allocator) Self
        {
            return Self {
                .data = system.D.init(),
                .functions = .{},
                .components = .init(allocator)
            };
        }

        pub fn deinit(self: *Self) void
        {
            var componentList = self.components.iterator();

            while (componentList.next()) |entry|
            {
                entry.value_ptr.deinit();
            }

            self.components.deinit();
            self.data.deinit();
        }

        pub fn addEntity(self: *Self, entity: Entity) void
        {
            self.components.put(entity, system.C.init()) catch @panic("out of mem :(");
        }

        pub fn hasEntity(self: Self, entity: Entity) bool
        {
            return self.components.contains(entity);
        }

        pub fn removeEntity(self: *Self, entity: Entity) void
        {
            _ = self.components.remove(entity);
        }
    };
}

fn AdHocType(comptime systems: []const System, comptime gameLoop: fn (anytype) void) type {

    comptime var systemNames: [systems.len][]const u8 = undefined;
    comptime var systemTypes: [systems.len]type = undefined;
    comptime var attrs: [systems.len]std.builtin.Type.StructField.Attributes = undefined;

    inline for (systems, 0..) |sys, i|
    {
        systemNames[i] = sys.name;
        systemTypes[i] = SystemStructure(sys);
        attrs[i] = std.builtin.Type.StructField.Attributes{
            .@"align" = null, .@"comptime" = false, .default_value_ptr = null
        };
    }

    const SystemsContainer = @Struct(
        std.builtin.Type.ContainerLayout.auto,
        null,
        &systemNames,
        &systemTypes,
        &attrs
    );

    return struct {
        const Self = @This();
        systems: SystemsContainer,
        entityCounter: Entity = 0,
        entities: std.ArrayList(Entity),
        allocator: std.mem.Allocator,

        pub fn createEntity(self: *Self) Entity
        {
            self.entityCounter += 1;
            self.entities.append(self.allocator, self.entityCounter) catch unreachable;
            return self.entityCounter;
        }

        pub fn removeEntity(self: *Self, entity: Entity) void
        {
            inline for (std.meta.fields(@TypeOf(self.systems))) |sys| {
                if (@as(sys.type, @field(self.systems, sys.name)).hasEntity(entity))
                {
                    var system = @as(sys.type, @field(self.systems, sys.name));
                    system.removeEntity(entity);
                }
            }

            for (self.entities.items, 0..) |e, i|
            {
                if (e == entity) {
                    _ = self.entities.swapRemove(i);
                }
                return;
            }
        }

        pub fn deinit(self: *Self) void
        {
            self.entities.deinit(self.allocator);

            inline for (std.meta.fields(@TypeOf(self.systems))) |sys| {
                var system = @as(sys.type, @field(self.systems, sys.name));
                system.deinit();
            }

            rl.closeWindow();
        }

        pub fn runGameLoop(self: Self) void
        {
            while (!rl.windowShouldClose())
            {
                rl.beginDrawing();
                gameLoop(self);
                rl.endDrawing();
            }
        }
    };
}

pub fn init(
    allocator: std.mem.Allocator,
    comptime systems: []const System,
    comptime gameLoop: fn (anytype) void,
    windowName: [:0]const u8,
    windowWidth: i32,
    windowHeight: i32)
    AdHocType(systems, gameLoop)
{
    var retVal: AdHocType(systems, gameLoop) = .{
        .entities = std.ArrayList(Entity).empty,
        .allocator = allocator,
        .systems = undefined
    };

    inline for (std.meta.fields(@TypeOf(retVal.systems))) |sys| {
        @field(retVal.systems, sys.name) = @as(
            sys.type, @field(retVal.systems, sys.name)
        ).init(allocator);
    }

    rl.initWindow(windowWidth, windowHeight, windowName);
    return retVal;
}
