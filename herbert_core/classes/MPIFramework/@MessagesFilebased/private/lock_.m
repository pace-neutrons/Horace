function lock_(filename)
fh = fopen(filename,'wb');
fwrite(fh,'lk');
fclose(fh);

% either smart move or delay timer to wait until FS recognises file
present = exist(filename,'file')==2;
while ~present
    pause(0.1)
    present = exist(filename,'file')==2;
end
% HACK? wait until lock file appears on file system. 
pause(0.1)
