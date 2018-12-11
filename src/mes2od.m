function mes = mes2od(mes)

% Compute optical density
mes.od = zeros(size(mes.channeldata));

for c = 1:size(mes.channeldata,2)
	
	baseline_mean = mean(mes.channeldata( ...
		mes.baselinewindow(1):mes.baselinewindow(2), ...
		c));
	
	pos = find( sign(mes.channeldata(:,c)) * baseline_mean > 0);
	
	mes.od(pos,c) = log( baseline_mean ./ mes.channeldata(pos,c) );
	
end

