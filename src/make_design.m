function des = make_design(mes,params)

% Note: Constant is NOT added to the design matrix

des = struct( ...
	'mes_file', mes.file, ...
	'hrf_p', [6 16 1 1 6 0 32], ...
	'sampletime', mes.sampletime, ...
	'nt', size(mes.hb_oxy,1), ...
	'sampletime_d', mes.sampletime_d, ...
	'nt_d', size(mes.hb_oxy_d,1) ...
	);


%% HRF based design

% For QA report, we will show both event and block.

des.conds = unique(mes.mark(mes.mark~=0));
nconds = length(des.conds);


% For block design, extend marks until next condition is reached.
prev = 0;
markB = zeros(size(mes.mark));
for t = 1:des.nt
    if mes.mark(t) ~= prev && mes.mark(t) ~= 0
        prev = mes.mark(t);
    end
    markB(t) = prev;
end

% Separate conditions and convolve with HRF - event
stim = zeros(des.nt,nconds);
for c = 1:nconds
	stim(:,c) = mes.mark==des.conds(c);
	q = conv(stim(:,c),spm_hrf(des.sampletime,des.hrf_p,16));
	des.X_event(:,c) = q(1:des.nt,:) / max(q);
	des.fX_event(:,c) = high_pass_filter(des.X_event(:,c),mes.sampletime,params);
	des.X_event_d(:,c) = decimate(des.X_event(:,c),params.downsample);
	des.fX_event_d(:,c) = decimate(des.fX_event(:,c),params.downsample);
end


% Separate conditions and convolve with HRF - block
stimB = zeros(des.nt,nconds);
for c = 1:nconds
	stimB(:,c) = markB==des.conds(c);
	q = conv(stimB(:,c),spm_hrf(des.sampletime,des.hrf_p,16));
	des.X_block(:,c) = q(1:des.nt,:) / max(q);
	des.fX_block(:,c) = high_pass_filter(des.X_block(:,c),mes.sampletime,params);
	des.X_block_d(:,c) = decimate(des.X_block(:,c),params.downsample);
	des.fX_block_d(:,c) = decimate(des.fX_block(:,c),params.downsample);
end

