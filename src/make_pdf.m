function make_pdf(mes,params)


%% PAGE 1, overview and channel stats

% Create regressors for the specified stimuli. Purpose is to show how they
% are affected by filtering.
des = make_design(mes,params);


% Create info string
info = sprintf('%s %s %s %s\n', ...
	params.project,params.subject,params.session,params.scan);
info = [ info ...
	sprintf(['Sampletime %3.1f sec, High-pass cutoff %d sec, ' ...
	'downsampling %dx, Proc %s'], ...
	mes.sampletime,params.hpf_cutoff_sec,params.downsample,char(datetime)) ...
	];

% Load channel metrics and create channel string
qa = readtable(fullfile(params.out_dir,'qa_stats.csv'));

qastr1 = sprintf('Ch    SCI  oxySD  deoxySD oxyCNRev oxyCNRbk\n');
for c = 1:min(24,height(qa))
	this = sprintf('%2d  %5.2f  %5.3f    %5.3f    %5.3f    %5.3f\n', ...
		qa.Ch(c),qa.SCI(c),qa.SD_Oxy(c),qa.SD_DeOxy(c), ...
		qa.CNR_Oxy_Ev(c),qa.CNR_Oxy_Bk(c) );
	qastr1 = [qastr1 this];
end

qastr2 = sprintf('Ch    SCI  oxySD  deoxySD oxyCNRev oxyCNRbk\n');
for c = 25:height(qa)
	this = sprintf('%2d  %5.2f  %5.3f    %5.3f     %4.2f     %4.2f\n', ...
		qa.Ch(c),qa.SCI(c),qa.SD_Oxy(c),qa.SD_DeOxy(c), ...
		qa.CNR_Oxy_Ev(c),qa.CNR_Oxy_Bk(c) );
	qastr2 = [qastr2 this];
end


% Figure out screen size so the figure will fit
ss = get(0,'screensize');
ssw = ss(3);
ssh = ss(4);
ratio = 8.5/11;
if ssw/ssh >= ratio
	dh = ssh;
	dw = ssh * ratio;
else
	dw = ssw;
	dh = ssw / ratio;
end


% Create figure
pdf_figure = openfig('report_page1.fig','new');
set(pdf_figure,'Units','pixels','Position',[0 0 dw dh]);
H = guihandles(pdf_figure);

% Place info string
set(H.summary_text, 'String',info);

% Place info string
set(H.data1, 'String',qastr1);
set(H.data2, 'String',qastr2);

% Plot design before and after filtering
t = 0:des.sampletime:des.sampletime*(des.nt-1);
t_d = 0:des.sampletime_d:des.sampletime_d*(des.nt_d-1);

axes(H.ax_E1)
plot(t,des.X_event)
ylabel('Event regr')
set(gca,'XLim',[0 max(t)],'XTickLabel',[],'Ylim',[-1 1],'YTickLabel',[]);

axes(H.ax_E2)
plot(t_d,des.fX_event_d)
ylabel('Ev post-filt')
set(gca,'XLim',[0 max(t)],'XTickLabel',[],'Ylim',[-1 1],'YTickLabel',[]);

axes(H.ax_B1)
plot(t,des.X_block)
ylabel('Block regr')
set(gca,'XLim',[0 max(t)],'XTickLabel',[],'Ylim',[-1 1],'YTickLabel',[]);

axes(H.ax_B2)
plot(t_d,des.fX_block_d)
ylabel('Bk post-filt')
xlabel('Time (s)')
set(gca,'XLim',[0 max(t)],'Ylim',[-1 1],'YTickLabel',[]);


% Print to PNG
print(gcf,'-dpng',fullfile(params.out_dir,'page_01.png'))
close(gcf);



%% Page 2+, channel data

% Loop through channels 3 at a time
pg = 1;
for c = 1:3:height(qa)
	
	% Create figure
	pdf_figure = openfig('report_page2.fig','new');
	set(pdf_figure,'Units','pixels','Position',[0 0 dw dh]);
	H = guihandles(pdf_figure);
	
	% Place info string
	set(H.summary_text, 'String',info);
	
	% Plot channel data
	axes(H.ax1)
	plot(t,mes.od(:,mes.channel==c))
	ylabel(sprintf('Ch %d OD',c))
	set(gca,'XLim',[0 max(t)],'XTickLabel',[],'YTickLabel',[]);
	
	axes(H.ax2); hold on
	plot(t_d,mes.hb_oxy_d(:,c),'r')
	plot(t_d,mes.hb_deoxy_d(:,c),'b')
	ylabel(sprintf('Ch %d Hb',c))
	set(gca,'XLim',[0 max(t)],'XTickLabel',[],'YTickLabel',[]);
	
	if c+1 <= mes.nchannels
		
		axes(H.ax3)
		plot(t,mes.od(:,mes.channel==c+1))
		ylabel(sprintf('Ch %d OD',c+1))
		set(gca,'XLim',[0 max(t)],'XTickLabel',[],'YTickLabel',[]);
		
		axes(H.ax4); hold on
		plot(t_d,mes.hb_oxy_d(:,c+1),'r')
		plot(t_d,mes.hb_deoxy_d(:,c+1),'b')
		ylabel(sprintf('Ch %d Hb',c+2))
		set(gca,'XLim',[0 max(t)],'XTickLabel',[],'YTickLabel',[]);
		
	end
	
	if c+1 <= mes.nchannels
		
		axes(H.ax5)
		plot(t,mes.od(:,mes.channel==c+2))
		ylabel(sprintf('Ch %d OD',c+2))
		set(gca,'XLim',[0 max(t)],'XTickLabel',[],'YTickLabel',[]);
		
		axes(H.ax6); hold on
		plot(t_d,mes.hb_oxy_d(:,c+2),'r')
		plot(t_d,mes.hb_deoxy_d(:,c+2),'b')
		ylabel(sprintf('Ch %d Hb',c+2))
		set(gca,'XLim',[0 max(t)],'XTickLabel',[],'YTickLabel',[]);
		
	end
	
	
	% Print to PNG
	pg = pg + 1;
	print(gcf,'-dpng',sprintf('%s/page_%02d.png',params.out_dir,pg));
	close(gcf);
	
	
end


%%  Convert to single PDF
if isdeployed()
	magick_path = '/usr/bin/';
else
	magick_path = '/usr/local/bin';
end
system( [ ...
	'cd ' params.out_dir ' && ' ...
	magick_path '/convert ' ...
	'page_*.png ' ...
	'nirsqa.pdf' ...
	] );
 

