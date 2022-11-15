# Modify build script generated with:
# write_project_tcl -force -internal -validate fractal_platform.tcl

platform_file="$1"
build_platform_file="$2"

cp ${platform_file} ${build_platform_file}

echo "Creating the following script from \"${platform_file}\":"
echo "    ${build_platform_file}"

sed -i 's/"\$origin_dir\/..\/platform\/vivado\/fractal_platform\/fractal_platform.gen\/sources_1\/common\/nsln\/nocattrs.dat"/"\${origin_dir}\/src\/nsln\/nocattrs.dat"/' ${build_platform_file}
sed -i 's/"\${origin_dir}\/..\/platform\/vivado\/fractal_platform\/fractal_platform.gen\/sources_1\/common\/nsln\/nocattrs.dat"/"\${origin_dir}\/src\/nsln\/nocattrs.dat"/' ${build_platform_file}
sed -i 's/"\$origin_dir\/..\/platform\/vivado\/fractal_platform\/fractal_platform.srcs\/sources_1\/imports\/nsln\/nocattrs.dat"/"\${origin_dir}\/src\/nsln\/nocattrs.dat"/' ${build_platform_file}
sed -i 's/"\${origin_dir}\/..\/platform\/vivado\/fractal_platform\/fractal_platform.srcs\/sources_1\/imports\/nsln\/nocattrs.dat"/"\${origin_dir}\/src\/nsln\/nocattrs.dat"/' ${build_platform_file}
sed -i 's/"\$origin_dir\/vivado\/fractal_platform\/fractal_platform.gen\/sources_1\/common\/nsln\/nocattrs.dat"/"\${origin_dir}\/src\/nsln\/nocattrs.dat"/' ${build_platform_file}
sed -i 's/"\${origin_dir}\/vivado\/fractal_platform\/fractal_platform.gen\/sources_1\/common\/nsln\/nocattrs.dat"/"\${origin_dir}\/src\/nsln\/nocattrs.dat"/' ${build_platform_file}
sed -i 's/"\$origin_dir\/vivado\/fractal_platform\/fractal_platform.srcs\/sources_1\/imports\/nsln\/nocattrs.dat"/"\${origin_dir}\/src\/nsln\/nocattrs.dat"/' ${build_platform_file}
sed -i 's/"\${origin_dir}\/vivado\/fractal_platform\/fractal_platform.srcs\/sources_1\/imports\/nsln\/nocattrs.dat"/"\${origin_dir}\/src\/nsln\/nocattrs.dat"/' ${build_platform_file}
sed -i 's/"\/home\/sarea\/Fractal\/platform\/vivado\/fractal_platform\/fractal_platform.gen\/sources_1\/common\/nsln\/nocattrs.dat"/"\${origin_dir}\/src\/nsln\/nocattrs.dat"/' ${build_platform_file}
sed -i 's/"\/home\/sarea\/Fractal\/platform\/vivado\/fractal_platform\/fractal_platform.srcs\/sources_1\/imports\/nsln\/nocattrs.dat"/"\${origin_dir}\/src\/nsln\/nocattrs.dat"/' ${build_platform_file}

echo "Corrected sources!"

sed -i 's/set origin_dir "."/set origin_dir [file dirname [file normalize [info script]]]/' ${build_platform_file}

echo "Corrected \"origin_dir\"!"

sed -i 's/set orig_proj_dir/# set orig_proj_dir/' ${build_platform_file}

echo "Removed \"origin_proj_dir\"!"

sed -i 's/create_project \${_xil_proj_name_} .\/\${_xil_proj_name_} -part xcvc1902-vsva2197-2MP-e-S/create_project \${_xil_proj_name_} \${origin_dir}\/\${_xil_proj_name_} -force -part xcvc1902-vsva2197-2MP-e-S/' ${build_platform_file}

echo "Corrected \"create_project\" command!"

echo "DONE!"
