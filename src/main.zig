const std = @import("std");
const Allocator = std.mem.Allocator;
const rand = std.crypto.random;

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

fn print_particles(particles: *Particles) !void {
    const asccis: [10]u8 = .{ ' ', '.', '-', '+', '*', 'x', 'X', '#', '%', '@' };
    var buffer: [10][10]u8 = undefined;
    for (0..10) |i| {
        for (0..10) |j| {
            buffer[i][j] = 0;
        }
    }
    for (0..particles.x.len) |i| {
        const x: usize = @intFromFloat(particles.x[i]);
        const y: usize = @intFromFloat(particles.y[i]);
        if (x < 0) continue;
        if (x > 10) continue;
        if (y < 0) continue;
        if (y > 10) continue;
        buffer[x][y] += 1;
    }
    for (0..10) |i| {
        for (0..10) |j| {
            const index = if (buffer[i][j] > 9) 9 else buffer[i][j];
            std.debug.print("{c}{c}", .{ asccis[index], asccis[index] });
        }
        std.debug.print("\n", .{});
    }
    var sum: u32 = 0;
    for (0..10) |i| {
        for (0..10) |j| {
            sum += buffer[i][j];
        }
    }
    std.debug.print("{d}\n", .{sum});
}

fn sim(particles: *Particles) void {
    for (0..particles.x.len) |i| {
        const x = &particles.x[i];
        const y = &particles.y[i];
        const v_x = &particles.v_x[i];
        const v_y = &particles.v_y[i];
        const nx = x.* + (v_x.* * 0.1);
        const ny = y.* + (v_y.* * 0.1);
        if (nx < 0) v_x.* *= -1;
        if (nx > 10) v_x.* *= -1;
        if (ny < 0) v_y.* *= -1;
        if (ny > 10) v_y.* *= -1;
        x.* = x.* + (v_x.* * 0.1);
        y.* = y.* + (v_y.* * 0.1);
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    var particles = try Particles.new(allocator, 50);

    for (0..particles.x.len) |i| {
        particles.x[i] = (rand.floatNorm(f64) + 5);
        particles.y[i] = (rand.floatNorm(f64) + 5);
        particles.radius[i] = 0.5;
        particles.v_x[i] = rand.floatNorm(f64);
        particles.v_y[i] = rand.floatNorm(f64);
    }

    for (0..200) |_| {
        std.debug.print("\x1B[2J\x1B[H", .{});
        print_particles(&particles) catch {
            std.debug.print("Err", .{});
            break;
        };
        sim(&particles);
        std.debug.print("\n", .{});
        std.Thread.sleep(200_000_000);
    }
}
