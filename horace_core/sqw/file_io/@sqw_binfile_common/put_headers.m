function   obj = put_headers(obj,varargin)
% put or replace header information into the  properly initialized
% binary sqw file
%
%Usage:
%>>obj.put_header();
%>>obj.put_headers(header_num);
%>>obj.put_headers('-update');

%>>obj.put_header(___,sqw_obj_new_source_for_update)
%
% If update options is selected, header have to exist. This option replaces
% only constant header's information
%
%

[ok,mess,update,argi] = parse_char_options(varargin,{'-update'});
if ~ok
    error('HORACE:put_headers:invalid_argument',mess);
end
%
obj.check_obj_initated_properly();
%
header_num =[];  % by default, return all headers
if ~isempty(argi)
    numeric_pos = cellfun(@(x)(isnumeric(x)&&~isempty(x)),argi); % if numeric argument provided,
    % return that header
    if any(numeric_pos)
        if sum(numeric_pos)>1
            error('HORACE:put_headers:invalid_argument',...
                'put_headers: you can only request all or one header number to save, but got %d numerical arguments',...
                sum(numeric_pos));
        end
        argi = argi(~numeric_pos);
        header_num = argi(numeric_pos);
    end
end


[exp_info,new_obj] = obj.extract_correct_subobj('header',argi{:});
if new_obj
    update = true;
end


if update
    if ~obj.upgrade_mode
        error('HORACE:put_headers:runtime_error',...
            'SQW_BINFILE_COMMON::put_headers : input object has not been initiated for update mode');
    end

    head_form = obj.get_header_form('-const');
else
    head_form = obj.get_header_form();
end
% Check if original file had mangled headers (or it is new file)
% and mangle final headers accordingly
if obj.contains_runid_in_header_
    opt = {};
else
    opt = {'-nomangle'};
end
if ~isempty(header_num)
    if header_num<=0 || header_num >obj.num_contrib_files
        error('HORACE:put_headers:invalid_argument',...
            'put_header: number of header to save %d is out of range of existing headers %d',...
            header_num,obj.num_contrib_files);
    end
    data_2save = exp_info.convert_to_old_headers(header_num,opt{:});
    n_files2_process = 1;
else
    n_files2_process = obj.num_contrib_files;
    data_2save = exp_info;
    if isa(data_2save,'Experiment')
        data_2save = data_2save.convert_to_old_headers(opt{:});
    end
end
% % Store scrambled run_id map not to guess it in a future. In new file
% % formats, runid map will be stored separately
% if ~isempty(obj.sqw_holder_)
%     data_2save = obj.modify_header_with_runid( ...
%         data_2save,obj.sqw_holder_.runid_map);
% end
if update
    pos_list = obj.upgrade_map_.cblocks_map('header');
    size_list = pos_list(2,:);
    pos_list  = pos_list(1,:);
else
    pos_list = obj.header_pos_;
end

for i=1:n_files2_process
    if iscell(data_2save)
        bytes = obj.sqw_serializer_.serialize(data_2save{i},head_form);
    else
        bytes = obj.sqw_serializer_.serialize(data_2save(i),head_form);
    end
    if update
        if numel(bytes) ~= size_list(i)
            error('HORACE:put_headers:runtime_error',...
                'SQW_BINFILE_COMMON::put_headers : size of upgraded header N%d (%d)  different from one on hdd (%d)',...
                i,numel(bytes),size_list(i));

        end
    end
    start_pos  = pos_list(i);
    fseek(obj.file_id_,start_pos ,'bof');
    check_error_report_fail_(obj,sprintf('Error moving to the start of the header N%d',i));
    fwrite(obj.file_id_,bytes,'uint8');
    check_error_report_fail_(obj,sprintf('Error writing data for the header N%d',i));
end
