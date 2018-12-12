#!/bin/sh
#
# Compile the matlab code so we can run it without a matlab license. Required:
#     Matlab 2017a, including compiler, with license

export PATH=/usr/local/MATLAB/R2017a/bin:$PATH

mcc -m -v src/nirsqa.m \
	-a src/all_e_coef.mat \
	-a src/report_page1.fig \
	-a src/report_page2.fig \
	-a external/spm_hrf \
	-d bin
chmod go+rx bin/nirsqa
chmod go+rx bin/run_nirsqa.sh
