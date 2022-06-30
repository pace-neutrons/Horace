function lock_(filename)
fh = fopen(filename,'wb');
fwrite(fh,'lk');
fclose(fh);

% either smart move or delay timer to wait until FS recognises file
present = is_file(filename);
n_attempts = 0;
n_tries = 100;
while ~present
    pause(0.1)
    present = is_file(filename);
    n_attempts = n_attempts+1;
    if n_attempts > n_tries
        warning('can not find write lock %s on the file system. Proceeding regardless',...
            filename);
        break
    end
end


