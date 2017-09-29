# Stride.jl

Stride is a software for the assignment of protein secondary structure. This packages wraps it inside a Julia package.

The usage is very simple:


``` Julia
using Stride

download("https://files.rcsb.org/download/1CRN.pdb", "1crn.pdb")
data = stride_run("1crn.pdb")

for ss in data.chain
    println(ss)
end
```

Stride.jl requires the binary Stride, which can be found here: http://webclu.bio.wzw.tum.de/stride/install.html
The binary should be accessible through PATH or one can use `stride_update_path("/path/to/stride/stride")`. Note that
it should point to the binary and not the folder with the binary.
