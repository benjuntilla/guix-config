- prefer pnpm over npm
- prefer poetry over pip
- do not edit .env files without explicitly asking me
- prefer rg over grep
- prefer fd over find
- when you're commenting code, don't be redundant and explain what's
  already there. comments should be for explaining or clarifying intent
- when adding new code, always ask: is there a simpler way i could do this?
- this machine is Guix; prebuilt ELFs from npm/pnpm packages (workerd, biome,
    esbuild, etc.) ship with interpreter `/lib64/ld-linux-x86-64.so.2` which
    doesn't exist. Symptom: `spawn ... ENOENT` despite the binary existing, or
    "no such file or directory" running it directly. Fix:
      INTERP=$(patchelf --print-interpreter "$(realpath "$(which sh)")")
      patchelf --set-interpreter "$INTERP" <binary>
    If it then fails with `libgcc_s.so.1: cannot open shared object file`, also
    set rpath to a glibc-compatible gcc-lib (find via
    `fd -uu '^libgcc_s\.so\.1$' /gnu/store`):
      patchelf --set-rpath <gcc-lib>/lib <binary>
    Re-patch after any `pnpm install` / lockfile change — fresh binaries replace
    the patched ones.
 
