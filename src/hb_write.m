function hb_write(mes,params)

% Hb files use the same header, except the Probe line is different
chunk = [sprintf('CH%d,',1:mes.nchannels) ...
	'Mark,Time,BodyMovement,RemovalMark,PreScan' ];
oxyheader = mes.header;
oxyheader{end} = ['Probe1(Oxy),' chunk];
deoxyheader = mes.header;
deoxyheader{end} = ['Probe1(Deoxy),' chunk];
totalheader = mes.header;
totalheader{end} = ['Probe1(Total),' chunk];

% Headers for downsampled data
oxyheader_d = oxyheader;
oxyheader_d{18} = sprintf('Moving Average[s],%3.1f',mes.sampletime_d);
oxyheader_d{26} = sprintf('Sampling Period[s],%3.1f',mes.sampletime_d);
deoxyheader_d = deoxyheader;
deoxyheader_d{18} = sprintf('Moving Average[s],%3.1f',mes.sampletime_d);
deoxyheader_d{26} = sprintf('Sampling Period[s],%3.1f',mes.sampletime_d);
totalheader_d = totalheader;
totalheader_d{18} = sprintf('Moving Average[s],%3.1f',mes.sampletime_d);
totalheader_d{26} = sprintf('Sampling Period[s],%3.1f',mes.sampletime_d);

% Write original
bfname = fullfile(params.out_dir,'tddr_HBA_Probe1_');
write_hb_part([bfname 'Oxy.csv'],mes,oxyheader,mes.hb_oxy);
write_hb_part([bfname 'Deoxy.csv'],mes,deoxyheader,mes.hb_deoxy);
write_hb_part([bfname 'Total.csv'],mes,totalheader,mes.hb_total);

% Write downsampled
bfname = fullfile(params.out_dir,'tddr_d_HBA_Probe1_');
write_hb_part_d([bfname 'Oxy.csv'],mes,oxyheader_d,mes.hb_oxy_d);
write_hb_part_d([bfname 'Deoxy.csv'],mes,deoxyheader_d,mes.hb_deoxy_d);
write_hb_part_d([bfname 'Total.csv'],mes,totalheader_d,mes.hb_total_d);

