const std = @import("std");

pub fn build(b: *std.Build) void {
    const test_step = b.step("test", "Test it");
    b.default_step = test_step;

    // An incremental MachO link takes compiler_rt in a way of its own (it is never a static
    // library there); a test binary needs its symbols as much as an executable does.
    const host = b.graph.host.result;
    if (host.os.tag != .macos) return;

    for ([_][]const u8{ "Debug", "ReleaseFast" }) |optimize| {
        const run = b.addSystemCommand(&.{ b.graph.zig_exe, "test", "-fno-llvm", "-fno-new-linker", "-fincremental", "-O", optimize });
        run.setName(b.fmt("test -fincremental {s}", .{optimize}));
        run.addFileArg(b.path("main.zig"));
        run.expectExitCode(0);
        test_step.dependOn(&run.step);
    }
}
