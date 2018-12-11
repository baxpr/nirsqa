function make_pdf(mes,params)


% Create regressors for the specified stimuli. Purpose is to show how they
% are affected by filtering.
des = make_design(mes,params);


% Create info string
info = sprintf('%s %s %s %s   ---   Processing timestamp: %s\n', ...
	params.project,params.subject,params.session,params.scan, ...
	char(datetime));
info = [ info ...
	sprintf('Sampletime %3.1f sec, High-pass cutoff %d sec, downsampling factor %d\n', ...
	mes.sampletime,params.hpf_cutoff_sec,params.downsample) ...
	];

% Load channel metrics and create channel string
%qa = readtable(fullfile(params.out_dir,'qa_stats.csv'));


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
print(gcf,'-dpng',fullfile(params.out_dir,'page1.png'))
close(gcf);


