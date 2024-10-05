
#######################################################################
# define variables
#######################################################################

set part xc7z020clg400-2
set origin_dir .
set output_dir $origin_dir/output
set src_dir $origin_dir/src
set const_file $origin_dir/const/Conv2D3x3.xdc
set repo_dir $origin_dir/ip_repo
set top_module $src_dir/Conv2D3x3.sv



#######################################################################
# create the project
#######################################################################
set project_dir $output_dir/vivado_conv2d3x3
create_project -force -part $part vivado_conv2d3x3 $project_dir
set_property simulator_language Verilog [current_project]


#######################################################################
# add all RTL source files in the src directory 
#######################################################################
add_files -fileset sources_1 $src_dir



#######################################################################
# add constraint file
#######################################################################
add_files -fileset constrs_1 $const_file

#######################################################################
# finalize
#######################################################################
puts "Created project at path: $project_dir"

quit