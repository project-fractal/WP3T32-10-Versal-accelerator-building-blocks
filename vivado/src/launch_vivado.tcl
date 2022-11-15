start_gui
set origin_dir [file dirname [file normalize [info script]]]
puts ${origin_dir}
open_project ${origin_dir}/../fractal_platform/fractal_platform.xpr
update_compile_order -fileset sources_1
open_bd_design ${origin_dir}/../fractal_platform/fractal_platform.srcs/sources_1/bd/fractal_platform/fractal_platform.bd
