function lock_name = build_lock_fname_(filename)
% Builds lock file name to protect filebased message from beeing read
% before written

[fp,fn,fext] = fileparts(filename);

if strcmpi(fext,'.mat')
    lock_name  = fullfile(fp,[fn,'.lock']);
else
    fnum = sscanf(fext,'.%d');
    fn = [fn,'_',num2str(fnum),'.lock'];
    lock_name  = fullfile(fp,fn);
end


