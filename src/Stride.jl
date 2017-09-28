module Stride

export stride_run,
       stride_update_path,
       stride_parse

type Stride_guts
    stride_path :: AbstractString
end

type SSDataResidue                 # Object to hold information about one residue
    residue      :: AbstractString # The 3 letter residue name
    ss_type      :: Char           # The one letter secondary structure
    ss_type_full :: AbstractString # Full SS name
    phi          :: Float64        # The phi
    psi          :: Float64        # and psi dihedral angle
    area         :: Float64        # Solvent accessible area
end

type SSData # Holds the data for a chain
    chain :: Array{SSDataResidue, 1}
end

stride_guts = Stride_guts("")

function stride_run(in_path :: AbstractString)
    out_path = randstring(32)

    args = [in_path, "-f$(out_path)"]
    cmd_string = `$(stride_guts.stride_path) $args`
    run(cmd_string)

    return stride_parse(out_path)
end

function stride_update_path(path :: AbstractString)
    stride_guts.stride_path = path
end

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
