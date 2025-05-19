const std = @import("std");
const utils = @import("./utils.zig");
const strings = @import("./strings.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    { // welcome
        const welcome = try utils.color_text(allocator, "Bienvenue dans l'utilitaire de création de module !\n", utils.Color.red);
        defer allocator.free(welcome);
        try stdout.print("{s}", .{welcome});

        const prompt = try utils.color_text(allocator, "Quel sera le nom de votre module et namespace ?\n", utils.Color.green);
        defer allocator.free(prompt);
        try stdout.print("{s}", .{prompt});
    }

    const namespace_name = try utils.print_message_and_get_response(allocator, stdout, stdin, "Nom du namespace: ");
    defer allocator.free(namespace_name);

    const module_name = try utils.print_message_and_get_response(allocator, stdout, stdin, "Nom du module: ");
    defer allocator.free(module_name);

    const server_need = srv: {
        const server_need_string = try utils.print_message_and_get_response(allocator, stdout, stdin, "Côté server ? (yes/no) [no]");
        defer allocator.free(server_need_string);
        const trimmed = std.mem.trim(u8, server_need_string, " \n\r");
        break :srv std.ascii.eqlIgnoreCase(trimmed, "y") or std.ascii.eqlIgnoreCase(trimmed, "yes");
    };

    { // messages d'info
        try stdout.print("Création du namespace {s}\n", .{namespace_name});
        try stdout.print("Création du module {s}\n", .{module_name});
        const wording = if (server_need) "Avec" else "Sans";
        try stdout.print("{s} côté serveur.\n", .{wording});
    }

    {
        // making directories
        const dirPath = try std.fmt.allocPrint(allocator, "./{s}/{s}/", .{ namespace_name, module_name });
        defer allocator.free(dirPath);
        try std.fs.cwd().makePath(dirPath);

        // creating php file with mod_name
        const phpFile = try utils.create_and_get_file(dirPath, module_name, ".php");
        defer phpFile.close();

        // creating js client file
        const jsFile = try utils.create_and_get_file(dirPath, module_name, ".js");
        defer jsFile.close();

        // writing twig and less files
        // ..
        // updating services.yml file
        // ..

        // writing files
        const php_file_string = try strings.get_php_file_string(allocator, namespace_name, module_name, server_need);
        defer allocator.free(php_file_string);
        _ = try phpFile.write(php_file_string);
    }
}
