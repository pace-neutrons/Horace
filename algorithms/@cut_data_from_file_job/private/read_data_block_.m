function v=read_data_block_(fid,noffset,range,block_ind_from,block_ind_to,ndatpix)
% function to read blocks of pixel data
%
if block_ind_from>block_ind_to
    v = zeros(9,0);
    return;
end
offsets_to_read = noffset(block_ind_from:block_ind_to);
ranges_to_read = range(block_ind_from:block_ind_to);
%
% group together the adjacent blocks of pixels to read
shift_pos = offsets_to_read>0;
if ~shift_pos(1)
    cum_index = cumsum(shift_pos)+1;
    if size(offsets_to_read,2)>1
        offsets_to_read  =[0,offsets_to_read(shift_pos)];
    else
        offsets_to_read  =[0;offsets_to_read(shift_pos)];
    end
else
    cum_index = cumsum(shift_pos);
    offsets_to_read  = offsets_to_read(shift_pos);
end
if size(cum_index,2) > 1
    cum_index = cum_index';
end
ranges_to_read  = accumarray(cum_index,ranges_to_read);
%
%
n_blocks = numel(offsets_to_read);

tmp_stor = cell(1,n_blocks);

for i=1:n_blocks
    ok = fseek (fid, (4*ndatpix)*offsets_to_read(i), 'cof'); % initial offset is from end of previous range; ndatpix x float32 per pixel in the file
    if ok~=0; fclose(fid); error('CUT_SQW:io_error','Unable to jump to required location in file'); end;
    try
        [tmp_stor{i},~,~,mess] = fread_catch(fid, [ndatpix,ranges_to_read(i)], '*float32');
        %v(:,vpos:vend)=tmp;
    catch  ME % fixup to account for not reading required number of items (should really go in fread_catch)
        if ~exist('mess','var')
            mess = ME.message;
        end
        fclose(fid);
        error('SQW:io_error','Unrecoverable read error %s',mess);
    end
    
end
% seems much faster then copying sub-blocks into preallocated storage.
% Certainly faster if blocks are big
v = [tmp_stor{:}];

end

