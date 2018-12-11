function mes = filter_TDDR(mes)


%% Filter setups
% Low pass filter 0.5 Hz to avoid high frequencies interfering with the
% TDDR  - this only gets applied within the TDDR process and its result is
% not kept otherwise.
Flow = designfilt('lowpassfir', ...
	'PassbandFrequency', .45, ...
	'StopbandFrequency', .55, ...
	'PassbandRipple', 1, ...
	'StopbandAttenuation', 60, ...
	'SampleRate', 1/mes.sampletime);


%% Apply filter to the optical density data and get first differences
% Retain filter residual so we can add it back in later
f_od = filtfilt(Flow,mes.od);
resid = mes.od - f_od;
df_od = zeros(size(f_od));
df_od(2:end,:) = diff(f_od);


%% Reconstruct from first differences after deweighting
mes.od_tddr = zeros(size(f_od));
for c = 1:size(f_od,2)
	
	% Use robustfit with a single predictor (constant term) to get weights for
	% the estimated mean
	y = df_od(:,c);
	X = ones(size(y));
	[m,stats] = robustfit(X,y,[],[],'off');
	w = stats.w;
	yp = w .* (y - m);
	
	% Reconstruct the data
	mes.od_tddr(:,c) = cumsum(yp) + resid(:,c);
	
	% High pass filter
	mes.od_tddr(:,c) = high_pass_filter(mes.od_tddr(:,c),mes.sampletime_d,params);
	
end


