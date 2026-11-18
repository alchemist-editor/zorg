const std = @import("std");

extern fn far_c(x: i32) i32;
extern fn c_calls_zig(x: i32) i32;

export fn zig_twice(x: i32) i32 {
    return x * 2;
}

noinline fn farZig(x: i32) i32 {
    return x + 3;
}

/// Many branches to the same targets from one function: one island slot each.
noinline fn again(x: i32) i32 {
    return far_c(x) + farZig(x) + far_c(x + 1) + farZig(x + 1);
}

noinline fn fib(n: u32) u32 {
    return if (n < 2) n else fib(n - 1) + fib(n - 2);
}

pub fn main() !void {
    if (far_c(41) != 42) return error.ZigToC;
    if (farZig(1) != 4) return error.ZigToZig;
    if (again(2) != 3 + 5 + 4 + 6) return error.SharedSlots;
    if (fib(15) != 610) return error.Recursion;
    if (c_calls_zig(20) != 41) return error.CToZig;
    // libc through its stub.
    if (std.c.getpid() <= 0) return error.Libc;
}
