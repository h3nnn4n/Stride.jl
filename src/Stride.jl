module Stride

export stride_run,
       stride_update_path,
       stride_parse


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
    | residue      | AbstractString | The 3 letter residue name          |
    | ss_type      | Char           | The one letter secondary structure |
    | ss_type_full | AbstractString | Full SS name                       |
    | phi          | Float64        | The phi                            |
    | psi          | Float64        | and psi dihedral angle             |
    | area         | Float64        | Solvent accessible area            |

    The following Secondary Structures are taken into account:
    | --- | ---         |
    | H   | Alpha Helix |
    | E   | Beta Strand |
    | C   | Coil        |
    | T   | Turn        |
"""
type SSDataResidue
    residue      :: AbstractString
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

stride_guts = Stride_guts("", true)

"""
    stride_run runs Stride for a given pdb file,
    the return is a SSData object
"""
function stride_run(in_path :: AbstractString)
    out_path = randstring(32)

    args = [in_path, "-f$(out_path)"]
    cmd_string = `$(stride_guts.stride_path) $args`
    run(cmd_string)

    ss = stride_parse(out_path)

    if stride_guts.delete_tmp_files
        rm(out_path)
    end

    return ss
end

"""
    stride_update_path can be used to change the path where the package will
    look for the Stride binary.
"""
function stride_update_path(path :: AbstractString)
    stride_guts.stride_path = path
end

"""
    stride_delete_tmp_files recieves a boolean value that determines if the tempfiles
    will be deleted after use. Default option is to delete it.
"""
function stride_delete_tmp_files(delete :: Bool)
    stride_guts.delete_tmp_files = delete
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

end
