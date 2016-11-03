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


obj.check_obj_initated_properly();
external_input = false;

if ~isempty(varargin)
    sqw_pos = cellfun(@(x)(isa(x,'sqw')||isstruct(x)),varargin);
    numeric_pos = cellfun(@isnumeric,varargin);
    unknown  = ~(sqw_pos||numeric_pos);
    if any(unknown)
        disp('unknown input: ',varargin{unknown});
        error('SQW_BINFILE_COMMON:invalid_argument',...
            'put_pixel: the routine accepts only sqw object and/or low and high numbers for pixels to save');
    end
    input_obj = varargin{sqw_pos};
    input_num = varargin{numeric_pos};
    if ~isempty(input_obj)
        if isa(input_obj,'sqw')
            input_obj = input_obj.data;
        end
        external_input = true;
    else
        input_obj = obj.sqw_holder_.data;
    end
else
    input_obj = obj.sqw_holder_.data;
    input_num = [];
end


head_pix = obj.get_data_form('-pix_only');
if external_input
    %TODO: (not implemented) check its possible to write pixels from new sqw to old
    i=0;
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

start_pos = obj.urange_pos_;
fseek(obj.file_id_,start_pos ,'bof');
check_error_report_fail_(obj,'Error moving to the start of the pixels info');
fwrite(obj.file_id_,bytes,'uint8');
check_error_report_fail_(obj,'Error writing the pixels information');
%
if external_input
    npix = size(input_obj.pix,2);
else
    npix = obj.npixels;
end
fwrite(obj.file_id_,npix,'uint64');

shift = (npix_lo-1)*9*4;
fseek(obj.file_id_,obj.pix_pos_+shift ,'bof');
check_error_report_fail_(obj,'Error moving to the start of the pixels record');
if write_all
    fwrite(obj.file_id_,input_obj.pix,'float32');
else
    fwrite(obj.file_id_,input_obj.pix(:,npix_lo:npix_hi),'float32');
end
check_error_report_fail_(obj,'Error writing pixels array');

