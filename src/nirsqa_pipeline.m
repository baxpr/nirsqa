function mes = nirsqa_pipeline(mes_file,out_dir)

% Load MES file
mes = read_mes(mes_file);

% Compute optical density
mes = mes2od(mes);

% Apply TDDR filter
mes = filter_TDDR(mes);

% Compute hemoglobin concentration estimates
mes = hb_compute(mes);

% Create Hb file header and save Hb data
mes = hb_header(mes,out_dir);

% Create PDF report


