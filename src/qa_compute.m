function qa = qa_compute(mes,params)

% Some QA metrics:
%   Scalp coupling index from OD
%   Standard deviation of the filtered data
%   Event CNR in filtered data (ratio of explained to residual variance)
%   Block CNR
qa = table((1:mes.nchannels)','VariableNames',{'Ch'});


%% Scalp coupling index
% correlation between raw signals in the 0.5-2.5 Hz frequency band.
F = designfilt('bandpassfir', ...
	'StopbandFrequency1', 0.4, 'PassbandFrequency1', .5, ...
	'PassbandFrequency2', 2.5, 'StopbandFrequency2', 3, ...
	'StopbandAttenuation1', 60, 'PassbandRipple', 1, ...
	'StopbandAttenuation2', 60, 'SampleRate', 1/mes.sampletime);

for c = 1:height(qa)
	
	ind700 = 2*c-1;
	ind830 = 2*c;
	
	f1 = filtfilt(F,mes.channeldata(:,ind700));
	f2 = filtfilt(F,mes.channeldata(:,ind830));
	
	qa.SCI(c,1) = corr(f1,f2);
	
	%figure(1); clf; plot([f1(1:200) f2(1:200)])
	%title(sprintf('%f',qa.SCI(c,1)))
	%pause
	
end

%% Standard deviation
% Of the final filtered data
qa.SD_Oxy = std(mes.hb_oxy_d)';
qa.SD_DeOxy = std(mes.hb_deoxy_d)';


%% Contrast-to-noise
des = make_design(mes,params);
Xev = [des.fX_event_d ones(des.nt_d,1)];
Xbk = [des.fX_block_d ones(des.nt_d,1)];

for c = 1:height(qa)
	
	Y = mes.hb_oxy_d(:,c);

	[~,~,residE] = regress(Y,Xev);
	explE = Y - residE;
	qa.CNR_Oxy_Ev(c,1) = var(explE) / var(residE);
	
	[~,~,residB] = regress(Y,Xbk);
	explB = Y - residB;
	qa.CNR_Oxy_Bk(c,1) = var(explB) / var(residB);
	
end

	
%% Write
writetable(qa,fullfile(params.out_dir,'qa_stats.csv'))


