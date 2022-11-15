set origin_dir [file dirname [file normalize [info script]]]
puts ${origin_dir}

proc get_device_family {} {
    return [common::get_property FAMILY [hsi::current_hw_design]]
}

proc get_processor {} {
    set processor [hsi::get_cells * -filter {IP_TYPE==PROCESSOR}]
    if {[llength $processor] != 0} {
        return $processor
    }
    return 0
}

hsi open_hw_design $origin_dir/import_from_vivado/fractal_platform_bd_wrapper.xsa

puts "get_device_family: [get_device_family]"
puts "get_processor: [get_processor]"

hsi set_repo_path $origin_dir/device-tree-xlnx
# hsi create_sw_design device-tree -os device_tree -proc [lindex [get_processor] 0]
hsi create_sw_design device-tree -os device_tree -proc versal_cips_0_pspmc_0_psv_cortexa72_0
hsi set_property CONFIG.dt_overlay true [hsi::get_os]
hsi generate_target -dir $origin_dir/../fractal_device_tree
hsi close_hw_design [hsi::current_hw_design]
