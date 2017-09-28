using Stride
using Base.Test

download("https://files.rcsb.org/download/1CRN.pdb", "1crn.pdb")

data = stride_run("1crn.pdb")

@test data.chain[2].name == "THR"
@test data.chain[1].ss_type == 'C'
@test data.chain[2].ss_type == 'E'
@test data.chain[7].ss_type_full == "AlphaHelix"
