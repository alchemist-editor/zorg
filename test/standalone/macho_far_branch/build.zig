const std = @import("std");

pub fn build(b: *std.Build) void {
    const test_step = b.step("test", "Test it");
    b.default_step = test_step;

    // A branch in the self-hosted backend's code (`__TEXT_ZIG`) that is too far for one `bl`
    // goes through the calling function's island. A real one needs over 128 MiB of code, so
    // the reach is lowered to nothing (`ZORG_DEBUG_BRANCH_REACH=0`): every branch of every
    // Zig function, to Zig, to C and to libc, takes its island.
    const host = b.graph.host.result;
    if (host.os.tag != .macos or host.cpu.arch != .aarch64) return;

    for ([_][]const u8{ "Debug", "ReleaseFast" }) |optimize| {
        for ([_]?[]const u8{ null, "0" }) |reach| add(b, test_step, optimize, reach);
    }
}

fn add(b: *std.Build, test_step: *std.Build.Step, optimize: []const u8, reach: ?[]const u8) void {
    const compile = b.addSystemCommand(&.{ b.graph.zig_exe, "build-exe", "-fno-llvm", "-lc", "-O", optimize });
    compile.setName(b.fmt("compile far_branch {s} reach {s}", .{ optimize, reach orelse "default" }));
    if (reach) |r| compile.setEnvironmentVariable("ZORG_DEBUG_BRANCH_REACH", r);
    compile.addFileArg(b.path("main.zig"));
    compile.addFileArg(b.path("far.c"));
    const exe = compile.addPrefixedOutputFileArg("-femit-bin=", "far_branch");

    const run = std.Build.Step.Run.create(b, b.fmt("run far_branch {s} reach {s}", .{ optimize, reach orelse "default" }));
    run.addFileArg(exe);
    run.expectExitCode(0);
    test_step.dependOn(&run.step);
}
