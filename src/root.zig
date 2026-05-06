const std = @import("std");
const Io = std.Io;

pub const Entity = i32;

pub const System = struct {
    ///system struct type
    T: type,

    name: []const u8,

    pub fn init(
        comptime T: type,
        comptime name: []const u8
        ) System
    {

        return System {
            .T = T,
            .name = name
        };
    }
};

pub fn AdHoc(comptime systems: []const System) type {

    comptime var systemNames: [systems.len][]const u8 = undefined;
    comptime var systemTypes: [systems.len]type = undefined;
    comptime var attrs: [systems.len]std.builtin.Type.StructField.Attributes = undefined;

    inline for (systems, 0..) |sys, i|
    {
        systemNames[i] = sys.name;
        systemTypes[i] = sys.T;
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

        pub fn generateEntity(self: *Self) Entity
        {
            self.entityCounter += 1;
            return self.entityCounter;
        }

        pub fn removeEntity(self: Self, entity: Entity) void
        {
            inline for (std.meta.fields(@TypeOf(self.systems))) |sys| {
                @as(sys.type, @field(self.systems, sys.name)).removeEntity(entity);
            }
        }
        
    };
}
