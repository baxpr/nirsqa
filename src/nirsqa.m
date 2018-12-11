function nirsqa(varargin)


%% Parse inputs
P = inputParser;
addOptional(P,'mes_file','/INPUTS/data_MES_Probe1.csv');
addOptional(P,'downsample','10');
addOptional(P,'hpf_cutoff_sec','200');
addOptional(P,'project','UNK_PROJ');
addOptional(P,'subject','UNK_SUBJ');
addOptional(P,'session','UNK_SESS');
addOptional(P,'scan','UNK_SCAN');
addOptional(P,'out_dir','/OUTPUTS');
parse(P,varargin{:});

mes_file = P.Results.mes_file;
params = struct( ...
	'project', P.Results.project, ...
	'subject', P.Results.subject, ...
	'session', P.Results.session, ...
	'scan', P.Results.scan, ...
	'out_dir', P.Results.out_dir, ...
	'downsample', str2double(P.Results.downsample), ...
	'hpf_cutoff_sec', str2double(P.Results.hpf_cutoff_sec) ...
	);

fprintf('mes_file:       %s\n',mes_file);
fprintf('project:        %s\n',params.project);
fprintf('subject:        %s\n',params.subject);
fprintf('session:        %s\n',params.session);
fprintf('scan:           %s\n',params.scan);
fprintf('out_dir:        %s\n',params.out_dir);
fprintf('downsample:     %d\n',params.downsample);
fprintf('hpf_cutoff_sec: %d\n',params.hpf_cutoff_sec);


%% Run the pipeline
nirsqa_pipeline(mes_file,params);

% Exit if we're compiled
if isdeployed
	exit(0)
end

