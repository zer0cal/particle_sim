const std = @import("std");
const Allocator = std.mem.Allocator;

const Particles = struct {
    x: []f64,
    y: []f64,
    radius: []f64,
    v_x: []f64,
    v_y: []f64,

    fn new(allocator: Allocator, length: usize) !Particles {
        return Particles{
            .x = try allocator.alloc(f64, length),
            .y = try allocator.alloc(f64, length),
            .radius = try allocator.alloc(f64, length),
            .v_x = try allocator.alloc(f64, length),
            .v_y = try allocator.alloc(f64, length),
        };
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    var particles = try Particles.new(allocator, 10);

    for (0..particles.x.len) |i| {
        particles.x[i] = @floatFromInt(i);
        particles.y[i] = @floatFromInt(i);
        particles.radius[i] = 0.5;
        particles.v_x[i] = 0.0;
        particles.v_y[i] = 0.0;
        std.debug.print("{d}. x: {d} y: {d}\n ", .{ i, particles.x[i], particles.y[i] });
    }
}
