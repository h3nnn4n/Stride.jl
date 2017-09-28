# Stride.jl

Stride is a software for the assignment of protein secondary structure. This packages wraps it inside a Julia package and requires
the Stride binary.

The use is very simple:

using Stride

``` Julia
download("https://files.rcsb.org/download/1CRN.pdb", "1crn.pdb")
data = stride_run("1crn.pdb")

for ss in data.chain
    println(ss)
end
```


The Stride binary can be found here: http://webclu.bio.wzw.tum.de/stride/install.html
