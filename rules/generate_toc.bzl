"""A macro to generate table of contents files of symbols from a shared library."""

def _shared_library_toc_impl(ctx):
    so_name = "lib" + ctx.attr.name + ".so"
    toc_name = so_name + ".toc"
    out_file = ctx.actions.declare_file(toc_name)
    d_file = ctx.actions.declare_file(toc_name + ".d")
    ctx.actions.run(
        env = {
            "CLANG_BIN": ctx.executable._readelf.dirname,
        },
        inputs = ctx.files.src,
        tools = [
            ctx.executable._readelf,
        ],
        outputs = [out_file, d_file],
        executable = ctx.executable._toc_script,
        arguments = [
            # Only Linux shared libraries for now.
            "--elf",
            "-i",
            ctx.file.src.path,
            "-o",
            out_file.path,
            "-d",
            d_file.path,
        ],
    )

    return [
        DefaultInfo(files = depset([out_file])),
    ]

shared_library_toc = rule(
    implementation = _shared_library_toc_impl,
    attrs = {
        "src": attr.label(allow_single_file = True, mandatory = True),
        "_toc_script": attr.label(
            cfg = "host",
            executable = True,
            allow_single_file = True,
            default = "//build/soong/scripts:toc.sh",
        ),
        "_readelf": attr.label(
            cfg = "host",
            executable = True,
            allow_single_file = True,
            default = "//prebuilts/clang/host/linux-x86:llvm-readelf",
        ),
    },
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
)