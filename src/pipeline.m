% Load and process MES file
mes = read_mes(mes_file);
mes = mes2od(mes);
mes = filter_TDDR(mes);
mes = hb_compute(mes);

% Get HB file header and write out processed
hba = readHBA(hba_file);
mes = hb_header(mes);
