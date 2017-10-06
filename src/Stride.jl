module Stride

export stride_run,
       stride_update_path,
       stride_parse,
       exists_in_path


type Stride_guts
    stride_path :: AbstractString
    delete_tmp_files :: Bool
end

"""
SSDataResidue holds the information related to the secondary structure
associated to a residue.

The fields are as follows:
| Field Name   | Field Type     | Description                        |
| ---          | ---            | ---                                |
| name         | AbstractString | The 3 letter residue name          |
| ss_type      | Char           | The one letter secondary structure |
| ss_type_full | AbstractString | Full SS name                       |
| phi          | Float64        | The phi                            |
| psi          | Float64        | and psi dihedral angle             |
| area         | Float64        | Solvent accessible area            |

The following Secondary Structures are defined using the [DSSP8 standard](https://zhanglab.ccmb.med.umich.edu/literature/dssp.pdf) and defined as follows:
| --- | ---            |
| H   | Alpha Helix    |
| B   | Beta Bridge    |
| E   | Strand         |
| T   | H Bounded Turn |
| I   | Pi Helix       |
| G   | 3/10 Helix     |
| S   | Bend           |
| C   | Random Coil    |
"""
type SSDataResidue
    name         :: AbstractString
    ss_type      :: Char
    ss_type_full :: AbstractString
    phi          :: Float64
    psi          :: Float64
    area         :: Float64
end


"""
SSData holds the information related to a given protein
"""
type SSData
    chain :: Array{SSDataResidue, 1}
end

stride_state = Stride_guts("", true)

"""
    stride_run(in_path :: AbstractString; out_path::AbstractString="")

Runs Stride for a given pdb file. if out_path is set then the temporary
Stride file generated will be kept. The function returns a SSData object.
"""
function stride_run(in_path :: AbstractString; out_path::AbstractString="")
    if length(stride_state.stride_path) == 0
        if exists_in_path("stride")
            stride_path = "stride"
        else
            error("Stride not found in PATH!\nPlease add stride to PATH" *
                  " or run stride_update_path(\"pathtostride\")")
        end
    else
        stride_path = stride_state.stride_path
    end

    if out_path == ""
        out_path = tempname()
    else
        stride_state.delete_tmp_files = false
    end

    args = [in_path, "-f$(out_path)"]
    cmd_string = `$(stride_path) $args`
    run(cmd_string)

    ss = stride_parse(out_path)

    if stride_state.delete_tmp_files
        rm(out_path)
    end

    return ss
end

"""
    stride_update_path(path :: AbstractString)

stride_update_path can be used to change the path where the package will
look for the Stride binary.
"""
function stride_update_path(path :: AbstractString)
    stride_state.stride_path = path
end

"""
    stride_delete_tmp_files(delete :: Bool)

stride_delete_tmp_files recieves a boolean value that determines if the tempfiles
will be deleted after use. Default option is to delete it.
"""
function stride_delete_tmp_files(delete :: Bool)
    stride_state.delete_tmp_files = delete
end

"""
    stride_parse is reponsible for parsing the output of Stride into a SSData object
"""
function stride_parse(path :: AbstractString)
    data = readdlm(path)
    nlines, ncolumns = size(data)

    ss = SSData([])

    for i in 1:nlines
        if data[i] == "REM"
            continue
        elseif data[i] == "LOC"
            continue
        elseif data[i] == "ASG"
            push!(ss.chain, SSDataResidue(data[i, 2], data[i, 6][1],
                                            data[i, 7], data[i, 8],
                                            data[i, 9], data[i, 10]
                                            ))
        end
    end

    return ss
end

"""
    exists_in_path(prog::String)

Determine whether the given program name or path is executable using the current user's
permissions. This is roughly equivalent to querying `which program` at the command line
and checking that a result is found, but no shelling out occurs.
"""
function exists_in_path(prog::String) # Code taken from Alex Arslan with permision
    X_OK = 1 << 0 # Taken from unistd.h
    # If prog has a slash, we know the user wants to determine whether the given
    # file exists and is executable
    if '/' in prog
        isfile(prog) || return false
        return ccall(:access, Cint, (Ptr{UInt8}, Cint), prog, X_OK) == 0
    end
    path = get(ENV, "PATH", "")
    # Something is definitely wrong if the user's path is empty...
    @assert !isempty(path)
    sep = ':'
    for dir in split(path, sep), file in readdir(dir)
        if file == prog
            p = joinpath(dir, file)
            @assert isfile(p)
            return ccall(:access, Cint, (Ptr{UInt8}, Cint), p, X_OK) == 0
        end
    end
    false
end
isexecutable(prog::String) = isexecutable(Sys.KERNEL, prog)

end
