function mes = hb_compute(mes)

% Get coef table - use "which" here so matlab will still be able to find
% this file when we go to compile the code for a spider later
load(which('all_e_coef.mat'));
e_coef = all_e_coef;

% Initialize some outputs that we will update one column at a time
mes.od_tddr_d = [];
mes.hb_oxy_d = [];
mes.hb_deoxy_d = [];
mes.hb_total_d = [];

% Go through each channel and compute Hb
for c = 1:mes.nchannels
	ind700 = 2*c-1;
	ind830 = 2*c;
	
	if mes.channel(ind700) ~= mes.channel(ind830)
		error('Trouble with data/channel assignments')
	end
	if abs(700-mes.wavelength(ind700)) > 5
		error('Trouble with 700nm wavelength')
	end
	if abs(830-mes.wavelength(ind830)) > 5
		error('Trouble with 830nm wavelength')
	end
	
	% Downsample OD data
	factor = 10;
	mes.od_tddr_d(:,ind700) = decimate(mes.od_tddr(:,ind700), factor);
	mes.od_tddr_d(:,ind830) = decimate(mes.od_tddr(:,ind830), factor);
	
	% Consider a highpass filter here as well, instead of applying it later
	% to the Hb data
	%F = designfilt('highpassiir', ...
	%	'StopbandFrequency', .004, 'PassbandFrequency', .005, ...
	%	'StopbandAttenuation', 60, 'PassbandRipple', 2, ...
	%	'SampleRate', 1/mes.sampletime/factor, ...
	%	'DesignMethod', 'cheby1');
	%mes.od_tddr_d(:,ind700) = filter(F,mes.od_tddr_d(:,ind700));
	%mes.od_tddr_d(:,ind830) = filter(F,mes.od_tddr_d(:,ind830));
	
	% Get the exact wavelength values for this channel
	wlen_700 = mes.wavelength(ind700);
	wlen_830 = mes.wavelength(ind830);
	
	% Get coefs for this channel's wavelengths
	eoxy_700 = find_e(wlen_700, 'oxy', e_coef);
	eoxy_830 = find_e(wlen_830, 'oxy', e_coef);
	edeo_700 = find_e(wlen_700, 'deoxy', e_coef);
	edeo_830 = find_e(wlen_830, 'deoxy', e_coef);
	
	% Oxy Hb
	if ((eoxy_700*edeo_830 - eoxy_830*edeo_700)~=0)
		mes.hb_oxy_d(:,c) = ...
			(mes.od_tddr_d(:,ind700)*edeo_830 - mes.od_tddr_d(:,ind830)*edeo_700) ...
			/ (eoxy_700*edeo_830 - eoxy_830*edeo_700);
	end;
	
	% Deoxy Hb
	if ((edeo_700*eoxy_830 - edeo_830*eoxy_700)~=0)
		mes.hb_deoxy_d(:,c) = ...
			(mes.od_tddr_d(:,ind700)*eoxy_830 - mes.od_tddr_d(:,ind830)*eoxy_700) ...
			/ (edeo_700*eoxy_830 - edeo_830*eoxy_700);
	end
	
	% Total Hb
	mes.hb_total_d(:,c) = mes.hb_oxy_d(:,c) + mes.hb_deoxy_d(:,c);
	
	
end

% Now downsample the non-NIRS stuff (event markers etc)
prerow = (1:size(mes.od_tddr,1))';
postrow = downsample(prerow,factor);

% For the marks, identify the time of each mark and put it in the
% downsampled data at the closest available time.
m = find(mes.mark);
mes.mark_d = zeros(size(postrow));
for k = 1:length(m)
	tdiffs = abs(postrow - prerow(m(k)));
	possibles = find(tdiffs==min(tdiffs));
	mes.mark_d(possibles(1)) = mes.mark(m(k));
end

% For the body movement, identify the time of each body movement and put it
% in the downsampled data at the closest available time.
m = find(mes.bodymovement);
mes.bodymovement_d = zeros(size(postrow));
for k = 1:length(m)
	tdiffs = abs(postrow - prerow(m(k)));
	possibles = find(tdiffs==min(tdiffs));
	mes.bodymovement_d(possibles(1)) = mes.bodymovement(m(k));
end

% For the time, identify the time  and put it
% in the downsampled data at the closest available time.

mes.time_d = mes.time(postrow);


% For the removal mark, identify the time of each removal mark and put it
% in the downsampled data at the closest available time.
m = find(mes.removalmark);
mes.removalmark_d = zeros(size(postrow));
for k = 1:length(m)
	tdiffs = abs(postrow - prerow(m(k)));
	possibles = find(tdiffs==min(tdiffs));
	mes.removalmark_d(possibles(1)) = mes.removalmark(m(k));
end

% For the prescan, identify the time of each prescan and put it in the
% downsampled data at the closest available time.
m = find(mes.prescan);
mes.prescan_d = zeros(size(postrow));
for k = 1:length(m)
	tdiffs = abs(postrow - prerow(m(k)));
	possibles = find(tdiffs==min(tdiffs));
	mes.prescan_d(possibles(1)) = mes.prescan(m(k));
end


% Function to lookup coefficient from a table.  If not exist, do
% interpolation
function e = find_e(waveLength, oxydeoxy, table)

if(strcmp(oxydeoxy, 'oxy'))
	col = 3;
elseif(strcmp(oxydeoxy, 'deoxy'))
	col = 2;
else
	error('You need to specify deoxy or oxy');
end

l = floor(waveLength);
u = floor(waveLength) + 1;

lc = table(find(table(:,1)==l),col);
uc = table(find(table(:,1)==u),col);

e = (uc - lc) / (u - l) * (waveLength - l) + lc;
return;