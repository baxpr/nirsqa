#!/bin/bash

# First fix the imagemagick policy
sed -i 's/rights="none" pattern="PDF"/rights="read | write" pattern="PDF"/' \
	/etc/ImageMagick-6/policy.xml

# Run the test
bash run_nirsqa.sh /usr/local/MATLAB/MATLAB_Runtime/v92 \
mes_file ../INPUTS/data_MES_Probe1.csv \
downsample 10 \
hpf_cutoff_sec 200 \
project TESTPROJ \
subject TESTSUBJ \
session TESTSESS \
scan TESTSCAN \
out_dir ../OUTPUTS
