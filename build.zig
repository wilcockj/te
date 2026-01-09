const std = @import("std");

const luajit_setup = @import("luajit_build/luajit.zig");
const lua_setup = @import("luajit_build/lua.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{ .name = "te", .use_lld = false, .root_module = b.createModule(.{
        .target = target,
        .optimize = optimize,
    }) });

    const raylib = b.dependency("raylib", .{ .target = target, .optimize = optimize });

    //exe.linkSystemLibrary("raylib");
    const shared = false;

    const upstream = b.dependency("luajit", .{});
    const lib = luajit_setup.configure(b, target, optimize, upstream, shared);
    //const upstream = b.dependency("lua54", .{});
    //const lib = lua_setup.configure(b, target, optimize, upstream, .{
    //.lang = .lua54,
    //.shared = shared,
    //.library_name = "lua",
    //.lua_user_h = null,
    //});
    const install_lib = b.addInstallArtifact(lib, .{});
    b.getInstallStep().dependOn(&install_lib.step);

    exe.addIncludePath(upstream.path("src"));
    exe.linkLibrary(lib);
    exe.addIncludePath(b.path("src/"));
    exe.addIncludePath(b.path("src/input/"));
    exe.linkLibrary(raylib.artifact("raylib"));

    exe.addCSourceFiles(.{
        .files = &.{ "engine.c", "grid.c", "input/keystring.c", "lua_api.c", "main.c", "renderer.c" },
        // Optional: specify a root directory for relative paths
        .root = b.path("src"),
        .flags = &.{ "-std=c23", "-Wall", "-Wextra" },
    });

    b.installArtifact(exe);
}
