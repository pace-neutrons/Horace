function move_to_position_(fid,pos)
% Do seek operation and check if it was successfull. 
% Throw error 'HORACE:data_block:io_error'if it has not been succesful.
%
fseek(fid,pos,'bof');
[mess,res] = ferror(fid);
if res ~= 0 
    file = fopen(fid);
    error('HORACE:data_block:io_error',...
        'file: "%s". Error "%s"', ...
        file,mess);

end
