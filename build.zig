const std = @import("std");
const Build = std.Build;
const luajit_setup = @import("luajit_build/luajit.zig");
const lua_setup = @import("luajit_build/lua.zig");

const Options = struct {
    mod: *Build.Module,
    dep_raylib: *Build.Dependency,
    target: Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{ .name = "te", .use_lld = false, .root_module = b.createModule(.{
        .target = target,
        .optimize = optimize,
    }) });

    const te = b.createModule(.{ .target = target, .optimize = optimize });

    const raylib = b.dependency("raylib", .{ .target = target, .optimize = optimize });
    //exe.linkSystemLibrary("raylib");
    const shared = false;

    const lang = lua_setup.Language.lua54;

    switch (lang) {
        .luajit => {
            const upstream = b.dependency("luajit", .{});
            const lib = luajit_setup.configure(b, target, optimize, upstream, shared);
            const install_lib = b.addInstallArtifact(lib, .{});
            b.getInstallStep().dependOn(&install_lib.step);
            exe.linkLibrary(lib);
            exe.addIncludePath(upstream.path("src"));
        },
        .lua54 => {
            const upstream = b.dependency("lua54", .{});
            const lib = lua_setup.configure(b, target, optimize, upstream, .{
                .lang = .lua54,
                .shared = shared,
                .library_name = "lua",
                .lua_user_h = null,
            });
            const install_lib = b.addInstallArtifact(lib, .{});
            b.getInstallStep().dependOn(&install_lib.step);
            exe.linkLibrary(lib);
            exe.addIncludePath(upstream.path("src"));
        },
        else => {
            unreachable;
        },
    }

    const opts = Options{ .mod = te, .dep_raylib = raylib, .target = target, .optimize = optimize };

    exe.addIncludePath(b.path("src/"));
    exe.addIncludePath(b.path("src/input/"));
    exe.linkLibrary(raylib.artifact("raylib"));

    exe.addCSourceFiles(.{
        .files = &.{ "engine.c", "grid.c", "input/keystring.c", "lua_api.c", "main.c", "renderer.c" },
        // Optional: specify a root directory for relative paths
        .root = b.path("src"),
        .flags = &.{ "-std=c23", "-Wall", "-Wextra" },
    });
    if (target.result.cpu.arch.isWasm()) {
        try buildEmscripten(b, opts);
    } else {
        try buildNative(b, opts);
    }
}

pub fn buildNative(b: *Build, opts: Options) !void {
    const native_target = opts.target;
    const optimize = opts.optimize;
    const exe = b.addExecutable(.{ .name = "te", .use_lld = false, .root_module = b.createModule(.{
        .target = native_target,
        .optimize = optimize,
    }) });

    const shared = false;
    const upstream = b.dependency("luajit", .{});
    const lib = luajit_setup.configure(b, native_target, optimize, upstream, shared);
    const install_lib = b.addInstallArtifact(lib, .{});
    b.getInstallStep().dependOn(&install_lib.step);
    exe.linkLibrary(lib);

    // include from luajit
    exe.addIncludePath(upstream.path("src"));
    exe.addIncludePath(b.path("src/"));
    exe.addIncludePath(b.path("src/input/"));

    exe.linkLibrary(opts.dep_raylib.artifact("raylib"));
    exe.addCSourceFiles(.{
        .files = &.{ "engine.c", "grid.c", "input/keystring.c", "lua_api.c", "main.c", "renderer.c" },
        // Optional: specify a root directory for relative paths
        .root = b.path("src"),
        .flags = &.{ "-std=c23", "-Wall", "-Wextra" },
    });
    b.installArtifact(exe);
}

pub fn buildWeb(b: *Build, opts: Options) !void {
    const lib = b.addLibrary(.{ .name = "te", .root_module = opts.mod });

    const shared = false;
    const upstream = b.dependency("lua54", .{});
    const emsdk = upstream.builder.dependency("emsdk", .{});
    _ = emsdk;

    const lua_lib = lua_setup.configure(b, opts.target, opts.optimize, upstream, .{
        .lang = .lua54,
        .shared = shared,
        .library_name = "lua",
        .lua_user_h = null,
    });
    const install_lib = b.addInstallArtifact(lua_lib, .{});
    b.getInstallStep().dependOn(&install_lib.step);
    _ = lib;
}

pub fn buildEmscripten(b: *Build, opts: Options) !void {
    const target = opts.target;
    const optimize = opts.optimize;

    const exe = b.addLibrary(.{
        .name = "te",
        .use_lld = false, // REQUIRED for emscripten
        .root_module = opts.mod,
    });

    // ------------------------------------------------------------
    // Lua 5.4 (static)
    // ------------------------------------------------------------
    const lua_upstream = b.dependency("lua54", .{});
    const lua_lib = lua_setup.configure(
        b,
        target,
        optimize,
        lua_upstream,
        .{
            .lang = .lua54,
            .shared = false, // MUST be false for wasm
            .library_name = "lua",
            .lua_user_h = null,
        },
    );

    exe.linkLibrary(lua_lib);
    exe.addIncludePath(lua_upstream.path("src"));

    // build raylib with emscripten
    exe.linkLibrary(opts.dep_raylib.artifact("raylib"));

    // ------------------------------------------------------------
    // Your C sources
    // ------------------------------------------------------------
    exe.addCSourceFiles(.{
        .root = b.path("src"),
        .files = &.{
            "engine.c",
            "grid.c",
            "input/keystring.c",
            "lua_api.c",
            "main.c",
            "renderer.c",
        },
        .flags = &.{
            "-std=c23",
            "-Wall",
            "-Wextra",
        },
    });

    exe.addIncludePath(b.path("src"));
    exe.addIncludePath(b.path("src/input"));
}
