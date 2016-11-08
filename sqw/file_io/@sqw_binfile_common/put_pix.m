function   obj = put_pix(obj,varargin)
% Save or replace pixels information within binary sqw file
%
%Usage:
%>>obj = obj.put_pix();
%>>obj = obj.put_pix(npix_lo,npix_hi);

% If update options is selected, header have to exist. This option keeps
% exisitng file information untouched;
%
% $Revision$ ($Date$)
%
[ok,mess,update,nopix,argi] = parse_char_options(varargin,{'-update','-nopix'});
if ~ok
    error('SQW_FILE_IO:invalid_argument',...
        'SQW_BINFILE_COMMON::put_pix: %s',mess);
end


obj.check_obj_initated_properly();


if ~isempty(argi)
    sqw_pos = cellfun(@(x)(isa(x,'sqw')||isstruct(x)),argi);
    numeric_pos = cellfun(@isnumeric,argi);
    unknown  = ~(sqw_pos||numeric_pos);
    if any(unknown)
        disp('unknown input: ',argi{unknown});
        error('SQW_BINFILE_COMMON:invalid_argument',...
            'put_pixel: the routine accepts only sqw object and/or low and high numbers for pixels to save');
    end
    input_obj = argi{sqw_pos};
    input_num = argi{numeric_pos};
    if ~isempty(input_obj)
        if isa(input_obj,'sqw')
            input_obj = input_obj.data;
        end
        update = true;
    else
        input_obj = obj.sqw_holder_.data;
    end
else
    input_obj = obj.sqw_holder_.data;
    input_num = [];
end


head_pix = obj.get_data_form('-pix_only');
if update
    if ~obj.upgrade_mode
        error('SQW_FILE_IO:runtime_error',...
            'SQW_BINFILE_COMMON::put_pix: input object has not been initiated for update mode');
    end
    if ~nopix && (obj.npixels ~= size(input_obj.pix,2))
        error('SQW_FILE_IO:runtime_error',...
            'SQW_BINFILE_COMMON::put_pix: unable to update pixels and pix number in file and update are different');
    end
    val   = obj.upgrade_map_.cblocks_map('pix');
    start_pos = val(1);
else
    start_pos = obj.urange_pos_;
end
if ~isempty(input_num)
    if input_num<=0 || input_num>obj.num_contrib_files
        error('SQW_BINFILE_COMMON:invalid_argument',...
            'put_header: number of header to save %d is out of range of existing headers %d',...
            input_num,obj.num_contrib_files);
    end
    npix_lo = input_num{1};
    npix_hi = input_num{2};
    write_all =false;
else
    write_all =true;
    npix_lo = 1;
    npix_hi = obj.npixels;
end

head_pix = rmfield(head_pix,'pix');
bytes = obj.sqw_serializer_.serialize(input_obj,head_pix);


fseek(obj.file_id_,start_pos ,'bof');
check_error_report_fail_(obj,'Error moving to the start of the pixels info');
fwrite(obj.file_id_,bytes,'uint8');
check_error_report_fail_(obj,'Error writing the pixels information');
%
npix = size(input_obj.pix,2);
fwrite(obj.file_id_,npix,'uint64');

if nopix
    shift = npix * 9*4;
    fseek(obj.file_id_,obj.pix_pos_+shift ,'bof');
    ferror(obj.file_id_, 'clear'); % clear error in case if pixels have never been written
    return;
end

shift = (npix_lo-1)*9*4;
fseek(obj.file_id_,obj.pix_pos_+shift ,'bof');
check_error_report_fail_(obj,'Error moving to the start of the pixels record');
if write_all
    fwrite(obj.file_id_,input_obj.pix,'float32');
else
    fwrite(obj.file_id_,input_obj.pix(:,npix_lo:npix_hi),'float32');
end
check_error_report_fail_(obj,'Error writing pixels array');

