function   obj = put_headers(obj,varargin)
% put or replace header information into the  properly initalized
% binary sqw file
%
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
header_num =[];  % by default, return all headers
if ~isempty(argi)
    numeric_pos = cellfun(@isnumeric,argi);
    if any(numeric_pos)
        if sum(numeric_pos)>1
            error('SQW_BINFILE_COMMON:invalid_argument',...
                'put_headers: you can only request all or one header number to put, but got %d numerical agruments',...
                sum(numeric_pos));
        end
        argi = argi(~numeric_pos);
        header_num = argi(numeric_pos);
    end
end


[headers,new_obj] = obj.extract_correct_subobj('header',argi{:});
if new_obj
    update = true;
end


if update
    head_form = obj.get_header_form('-const');
else
    head_form = obj.get_header_form();
end
if ~isempty(header_num)
    if header_num<=0 || header_num >obj.num_contrib_files
        error('SQW_BINFILE_COMMON:invalid_argument',...
            'put_header: number of header to save %d is out of range of existing headers %d',...
            header_num,obj.num_contrib_files);
    end
    data_2save = headers(header_num);
    n_files2_process = 1;
else
    n_files2_process = obj.num_contrib_files;
    data_2save = headers;
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

