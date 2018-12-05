function nirsqa(varargin)


%% Parse inputs
P = inputParser;
addOptional(P,'mes_file','/INPUTS/data_MES_Probe1.csv');
addOptional(P,'project','UNK_PROJ');
addOptional(P,'subject','UNK_SUBJ');
addOptional(P,'session','UNK_SESS');
addOptional(P,'scan','UNK_SCAN');
addOptional(P,'out_dir','/OUTPUTS');
parse(P,varargin{:});

mes_file = P.Results.mes_file;
project = P.Results.project;
subject = P.Results.subject;
session = P.Results.session;
scan = P.Results.scan;
out_dir = P.Results.out_dir;

fprintf('mes_file:  %s\n',mes_file);
fprintf('project:   %s\n',project);
fprintf('subject:   %s\n',subject);
fprintf('session:   %s\n',session);
fprintf('scan:      %s\n',scan);
fprintf('out_dir:   %s\n',out_dir);


%% Run the pipeline
nirsqa_pipeline(mes_file,out_dir);

if isdeployed
	exit(0)
end

