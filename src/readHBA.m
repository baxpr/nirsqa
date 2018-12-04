function hba = readHBA(hba_file)

fid = fopen(hba_file,'rt');
for k = 1:41
    fgetl(fid);
end

% We're assuming 22 channels
data = fscanf(fid, ...
    ['%d,' repmat('%f,',1,22) '%d,%d:%d:%f,%d,%d,%d'], ...
    [30 inf]);

hba = data(2:23,:)';

fclose(fid);
