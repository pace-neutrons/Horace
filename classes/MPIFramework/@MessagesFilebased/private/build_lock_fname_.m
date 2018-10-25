function [rLock_name,wLock_name] = build_lock_fname_(filename)
% Builds lock file name to protect filebased message from beeing read
% before written

[fp,fn,fext] = fileparts(filename);
if nargout >1
    rw_lock = true;
else
    rw_lock = false;    
end
if strcmpi(fext,'.mat')
    if rw_lock
        rLock_name = fullfile(fp,[fn,'.lockr']);        
        wLock_name = fullfile(fp,[fn,'.lockw']);                
    else
        rLock_name = fullfile(fp,[fn,'.lock']);
    end
else
    fnum = sscanf(fext,'.%d');
    fn = [fn,'_',num2str(fnum),'.lock'];
    if rw_lock
        rLock_name = fullfile(fp,[fn,'.lockr']);        
        wLock_name = fullfile(fp,[fn,'.lockw']);                
    else
        rLock_name = fullfile(fp,[fn,'.lock']);
    end    
end


