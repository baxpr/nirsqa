function mes = filter_TDDR(mes)


%% Low pass filter 0.5 Hz to avoid high frequencies interfering with the TDDR
F = designfilt('lowpassfir', ...
    'PassbandFrequency', .45, ...
    'StopbandFrequency', .55, ...
    'PassbandRipple', 1, ...
    'StopbandAttenuation', 60, ...
    'SampleRate', 1/mes.sampletime);


%% Apply filter to the optical density data and get first differences
% Retain filter residual so we can add it back in later
f_od = filtfilt(F,mes.od);
resid = mes.od - f_od;
df_od = zeros(size(f_od));
df_od(2:end,:) = diff(f_od);


%% De-weight artifacty time points
% Use robustfit with a single predictor (constant term) to get weights for
% the estimated mean, which is what the paper is also doing
mes.od_tddr = zeros(size(f_od));
for c = 1:size(f_od,2)

	y = df_od(:,c);
	X = ones(size(y));
	[m,stats] = robustfit(X,y,[],[],'off');
	w = stats.w;

	yp = w .* (y - m);
	mes.od_tddr(:,c) = cumsum(yp) + resid(:,c);

end


