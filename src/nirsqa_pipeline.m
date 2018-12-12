function mes = nirsqa_pipeline(mes_file,params)

% Load MES file
mes = read_mes(mes_file);

% Compute optical density
mes = mes2od(mes);

% Apply filters
mes = filter_TDDR(mes,params);

% Compute hemoglobin concentration estimates
mes = hb_compute(mes,params);

% Compute some QA metrics
qa_compute(mes,params);

% Create Hb file header and save Hb data
hb_write(mes,params);

% Create PDF report
make_pdf(mes,params);
