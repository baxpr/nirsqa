function write_hb(mes,out_dir)

% Hb files use the same header, except the Probe line is different
chunk = [sprintf('CH%d,',1:mes.nchannels) ...
	'Mark,Time,BodyMovement,RemovalMark,PreScan' ];
oxyheader = mes.header;
oxyheader{end} = ['Probe1(Oxy),' chunk];
deoxyheader = mes.header;
deoxyheader{end} = ['Probe1(Deoxy),' chunk];
totalheader = mes.header;
totalheader{end} = ['Probe1(Total),' chunk];

% Write original
bfname = fullfile(out_dir,'tddr_HBA_Probe1_');
write_hb_part([bfname 'Oxy.csv'],mes,oxyheader,mes.hb_oxy);
write_hb_part([bfname 'Deoxy.csv'],mes,deoxyheader,mes.hb_deoxy);
write_hb_part([bfname 'Total.csv'],mes,totalheader,mes.hb_total);


% Update sample time, filter settings

FIXME


% Write downsampled
bfname = fullfile(out_dir,'tddr_d_HBA_Probe1_');
write_hb_part([bfname 'Oxy.csv'],mes,oxyheader,mes.hb_oxy_d);
write_hb_part([bfname 'Deoxy.csv'],mes,deoxyheader,mes.hb_deoxy_d);
write_hb_part([bfname 'Total.csv'],mes,totalheader,mes.hb_total_d);

