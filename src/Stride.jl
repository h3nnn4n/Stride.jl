module Stride

stride_path = "/home/h3nnn4n/Stride.jl/src/tmp/stride"
input_file = ""
output_file = ""
args = [input_file, "-f", output_file]

cmd_string = `$stride_path $args`

run(cmd_string)

end
