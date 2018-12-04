function mes = hb_header(mes)
% Hb files use the same header, except the Probe line is different
chunk = [sprintf('CH%d,',1:mes.nchannels) ...
	'Mark,Time,BodyMovement,RemovalMark,PreScan' ];
hb.oxyheader = mes.header;
hb.oxyheader{end} = ['Probe1(Oxy),' chunk];
hb.deoxyheader = mes.header;
hb.deoxyheader{end} = ['Probe1(Deoxy),' chunk];
hb.totalheader = mes.header;
hb.totalheader{end} = ['Probe1(Total),' chunk];


% Base filename
[p,n] = fileparts(mes.file);
tag = regexp(n,'(.*)_MES_Probe1','tokens');
fileprefix = 'tddr_d'
bfname = fullfile(p,[fileprefix tag{1}{1} '_HBA_Probe1_']);

% Update sample time

% Write
write_hb_part([bfname 'Oxy.csv'],mes,hb.oxyheader,mes.hb_oxy_d);
write_hb_part([bfname 'Deoxy.csv'],mes,hb.deoxyheader,mes.hb_deoxy_d);
write_hb_part([bfname 'Total.csv'],mes,hb.totalheader,mes.hb_total_d);
