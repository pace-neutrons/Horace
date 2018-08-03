function unlock_(fh,filename)
fclose(fh);
while exist(filename,'file')==2
    delete(filename);
    % Allow save operation to complete. On Windows some messages remain
    % blocked for some time after save completed
    pause(0.1);
end
