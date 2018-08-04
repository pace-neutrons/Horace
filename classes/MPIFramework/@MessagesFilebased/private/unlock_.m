function unlock_(fh,filename)
fclose(fh);
ws=warning('off','MATLAB:DELETE:Permission');
permission_denied = false;
while exist(filename,'file')==2 || permission_denied
    delete(filename);
    [~,warn_id] = lastwarn;
    if strcmpi(warn_id,'MATLAB:DELETE:Permission')
        permission_denied=true;
        lastwarn('');
    else
        permission_denied=false;
    end
    
end
warning(ws);

