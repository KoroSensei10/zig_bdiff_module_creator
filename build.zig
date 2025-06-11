const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "bdiff-module-creator",
        .root_source_file = b.path("src/main.zig"),
        .target = b.standardTargetOptions(.{}),
    });

    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run bdiff-module-creator");
    run_step.dependOn(&run_exe.step);
}
