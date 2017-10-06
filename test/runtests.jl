using Stride
using Base.Test

download("https://files.rcsb.org/download/1CRN.pdb", "1crn.pdb")

@testset "Secondary Strucure Assignment" begin
    data = stride_run("1crn.pdb")

    @test data.chain[2].name == "THR"
    @test data.chain[1].ss_type == 'C'
    @test data.chain[2].ss_type == 'E'
    @test data.chain[7].ss_type_full == "AlphaHelix"
end

@testset "File handling" begin
    data = stride_run("1crn.pdb", out_path="1crn_result")

    @test isfile("1crn_result")

    if isfile("1crn_result")
        rm("1crn_result")
    end
end

if isfile("1crn.pdb")
    rm("1crn.pdb")
end
