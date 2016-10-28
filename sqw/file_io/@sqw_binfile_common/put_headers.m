function   obj = put_headers(obj,varargin)
% put or replace header information into the  properly initalized
% binary sqw file
%Usage:
%>>obj.put_header();
%>>obj.put_headers(header_num);
%>>obj.put_headers('-update');

%>>obj.put_header(___,sqw_obj_new_source_for_update)
%
% If update options is selected, header have to exist. This option replaces
% only constatnt header's information
%

[ok,mess,update,argi] = parse_char_options(varargin,{'-update'});
if ~ok
    error('SQW_BINFILE_COMMON:invalid_argument',mess);
end
%
obj.check_obj_initated_properly();
%
if ~isempty(argi)
    sqw_pos = cellfun(@(x)(isa(x,'sqw')||isstruct(x)),argi);
    numeric_pos = cellfun(isnumeric,argi);
    unknown  = ~(sqw_pos||numeric_pos);
    if any(unknown)
        disp('unknown input: ',argi{unknown});
        error('SQW_BINFILE_COMMON:invalid_argument',...
            'put_header: the routine accepts only sqw object "-update" and/or header number, got something as above');
    end
    input_obj = argi{sqw_pos};
    input_num = argi{numeric_pos};
    if ~isempty(input_obj)
        if isa(input_obj,'sqw')
            input_obj = input_obj.header;
        end
        update = true;
    else
        input_obj = obj.sqw_holder_.header;
    end
else
    input_obj = obj.sqw_holder_.header;
    input_num = [];
end


if update
    head_form = obj.get_header_form('-const');
else
    head_form = obj.get_header_form();
end
if ~isempty(input_num)
    if input_num<=0 || input_num>obj.num_contrib_files
        error('SQW_BINFILE_COMMON:invalid_argument',...
            'put_header: number of header to save %d is out of range of existing headers %d',...
            input_num,obj.num_contrib_files);
    end
    data_2save = input_obj(input_num);
    n_files2_process = 1;
else
    n_files2_process = obj.num_contrib_files;
    data_2save = input_obj;
end

for i=1:n_files2_process
    bytes = obj.sqw_serializer_.serialize(data_2save(i),head_form);
    if update
        error('SQW_BINFILE_COMMON:invalid_argument','not yet implemented');
    end
    start_pos = obj.header_pos_(i);
    fseek(obj.file_id_,start_pos ,'bof');
    check_error_report_fail_(obj,sprintf('Error moving to the start of the header N%d',i));
    fwrite(obj.file_id_,bytes,'uint8');
    check_error_report_fail_(obj,sprintf('Error writing data for the header N%d',i));
end

