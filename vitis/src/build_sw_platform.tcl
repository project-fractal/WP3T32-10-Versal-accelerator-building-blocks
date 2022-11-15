set origin_dir [file dirname [file normalize [info script]]]
puts ${origin_dir}

# Create project directory

platform create -name fractal_platform -hw $origin_dir/src/import_from_vivado/fractal_platform_bd_wrapper.xsa -out $origin_dir/build -no-boot-bsp

# Create the Linux domain

set linux_name xrt
set linux_desc "Linux domain"
set linux_proc psv_cortexa72
set linux_os linux

set boot_dir $origin_dir/src/import_from_petalinux/boot
set bif_file $origin_dir/src/import_from_petalinux/boot/linux.bif
set rootfs_file $origin_dir/src/import_from_petalinux/sw_comp/rootfs.ext4
set bootmode sd
set sd_dir $origin_dir/src/import_from_petalinux/image
set sysroot_dir $origin_dir/src/import_from_petalinux/sw_comp/sysroots/cortexa72-cortexa53-xilinx-linux

domain create -name $linux_name -desc $linux_desc -proc $linux_proc -os $linux_os
domain config -boot $boot_dir
domain config -bif $bif_file
domain config -rootfs $rootfs_file
domain config -bootmode $bootmode
domain config -sd-dir $sd_dir
domain config -sysroot $sysroot_dir

# Create AI Engine domain

set aie_name aiengine
set aie_desc "AI Engine domain"
set aie_proc ai_engine
set aie_os aie_runtime

domain create -name $aie_name -desc $aie_desc -proc $aie_proc -os $aie_os

# Create Standalone domain

set standalone_name standalone_domain
set standalone_desc "Standalone domain"
set standalone_proc versal_cips_0_pspmc_0_psv_cortexa72_0
set standalone_os standalone

domain create -name $standalone_name -desc $standalone_desc -proc $standalone_proc -os $standalone_os

# Generate platform

platform generate -domains

bsp reload

platform generate
