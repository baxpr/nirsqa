function mes = read_mes(mes_file)

mes = struct('file',mes_file);

fid = fopen(mes.file);

% Read the header. Neither textscan nor fscanf can manage to handle this in
% a reasonable and consistent way, so we fall back on fgetl.
mes.header = [];
thisline = '';
while ~strncmp(thisline,'Probe1',6)
	thisline = fgetl(fid);
	if thisline == -1
		error('End of file reached before header read')
	end
	mes.header{end+1,1} = thisline;
end

for h = 1:length(mes.header)
	
	c = strsplit(mes.header{h},',');
	switch c{1}
		
		case 'File Version'
			fprintf('File Version: %s\n',c{2})
			
		case 'Wave[nm]'
			wave = c(2:end);
			fprintf('Wavelengths (nm): ')
			fprintf('%s ',wave{:})
			fprintf('\n')
			
		case 'Wave Length'
			wavelengthstr = c(2:end);
			mes.nchannels = length(wavelengthstr)/2;
			disp(['Found ' num2str(mes.nchannels) ' channels'])
			mes.wavelength = nan(size(wavelengthstr));
			mes.channel = nan(size(wavelengthstr));
			for c = 1:length(wavelengthstr)
				q = sscanf(wavelengthstr{c},'CH%d(%f)');
				mes.channel(c) = q(1);
				mes.wavelength(c) = q(2);
			end
			
		case 'Sampling Period[s]'
			mes.sampletime = str2double(c{2});
			
		case 'Mode'
			mes.mode = c{2};
			
	end
	
end


% Read the data. Super klunky! We're making up a format string with the
% correct number of channels.
format_str = ['%d' repmat('%f',1,mes.nchannels*2) '%d%s%d%d%d'];
data = textscan(fid,format_str,'Delimiter',',');

fclose(fid);

% Extract the useful bits
firstdatachan = 2;
lastdatachan = mes.nchannels*2+1;
mes.row = data{1};
mes.channeldata = cat(2,data{firstdatachan:lastdatachan});
mes.mark = data{lastdatachan+1};
mes.time = data{lastdatachan+2};
mes.bodymovement = data{lastdatachan+3};
mes.removalmark = data{lastdatachan+4};
mes.prescan = data{lastdatachan+5};
mes.baselinewindow = [find(mes.prescan,1) find(mes.prescan,1,'last')];

