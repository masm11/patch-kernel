# Abstraction

Patch your linux kernel source tree to the latest.

# Notice

 - xz compression only supported.
 - kernel version 4.x support only.
 - No rc supports.

# Directory Hierarchy

You need to structure directories as the follows:

```
+- patch.rb
+- linux-4/
|  +- README
|  +- Documentation/
|  :
+- patch/
   +- patch-4.0.1.xz
   +- patch-4.1.xz
   +- patch-4.1.1.xz
   :
```

# Execution

```sh
cd `the place of the patch.rb`
./patch.rb
```

patch.rb update the kernel source tree to the latest
with the patch files supplied in patch/ directory.

If a new patch is released, download it, store it in patch/ and
re-run ./patch.rb.

# License

GPL3

# Author

Yuuki Harano <masm@masm11.ddo.jp>
