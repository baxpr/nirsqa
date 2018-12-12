#!/bin/bash

singularity run \
--cleanenv \
--home INPUTS \
--bind INPUTS:/INPUTS \
--bind OUTPUTS:/OUTPUTS \
baxpr-nirsqa.simg \
mes_file /INPUTS/data_MES_Probe1.csv \
downsample 10 \
hpf_cutoff_sec 200 \
project UNK_PROJ \
subject UNK_SUBJ \
session UNK_SESS \
project UNK_SCAN \
out_dir /OUTPUTS
