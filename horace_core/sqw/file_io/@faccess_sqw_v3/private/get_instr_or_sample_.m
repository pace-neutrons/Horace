function [res,obj] = get_instr_or_sample_(obj,field_name,varargin)
% get instrument or sample stored in sqw file
%
% Usage:
%>>inst = obj.get_instr_or_sample_('instrument')
% Returns first instrument, present in the file
%
%>>sample = obj.get_instrument('sample',number)
% Returns first instrument with number, specified
%
%>>inst = obj.get_instrument('instrument','-all')
% Returns cellarray of all instruments, stored in the file
%

[ok,mess,get_all,other]=parse_char_options(varargin,{'-all'});
if ~ok
    error('HORACE:faccess_sqw_v3:invalid_argument',...
        'get_%s, error: %s',field_name,mess )
end
res_block = get_all_instr_or_samples_(obj,field_name);
if strcmp(field_name,'instrument') && isstruct(res_block) && numel(fields(res_block))==0
    res_block  = IX_null_inst();
end
if strcmp(field_name,'sample') && isstruct(res_block) && numel(fields(res_block))==0
    res_block  = IX_null_sample();
end
if ~iscell(res_block)
    res_block = num2cell(res_block);
end


if get_all
    res  = res_block;
    return
end

if ~isempty(other)
    n_inst = other{1};
    if ~isnumeric(n_inst)
        error('HORACE:faccess_sqw_v3:invalid_argument',...
            'get_%s, error: %s',field_name,mess )
    end
    if n_inst<1 || n_inst > obj.num_contrib_files
        error('HORACE:faccess_sqw_v3:invalid_argument',...
            'get_%s, Requested the %s N%d when only %d %s-s are availible',...
            field_name,field_name,n_inst,obj.num_contrib_files,field_name)
    end
else
    n_inst = 1;
end
if iscell(res_block)
    if numel(res_block) == 1
        res = res_block{1};
    else
        res = res_block{n_inst};
    end
else
    if numel(res_block) == 1
        res = res_block;
    else
        res = res_block(n_inst);
    end
end
%
%
%
function res = get_all_instr_or_samples_(obj,field_name)
% Reads instrument or sample block and converts it into correspondent class
% or cellarray of classes (depending on how it has been written on hdd)
%
% field_name -- string which can be 'instrument' or 'sample'
%
persistent old_matlab;
if isempty(old_matlab)
    old_matlab = verLessThan('matlab','8.3');
end

if ischar(obj.num_contrib_files_)
    error('HORACE:faccess_sqw_v3:runtime_error',...
        'get_instr_or_sample_ for %s called on non-initialized object',...
        field_name);
end
[descr,version] = read_si_head_block(obj,field_name,old_matlab);

data_start_name = [field_name,'_pos_'];
if strcmp(field_name,'instrument')
    data_end_name = 'sample_head_pos_';
else % sample
    data_end_name = 'instr_sample_end_pos_';
end
data_size = obj.(data_end_name)-obj.(data_start_name);
%
if  old_matlab % some MATLAB problems with moving to correct eof
    fseek(obj.file_id_,double(obj.(data_start_name)),'bof');
else
    fseek(obj.file_id_,obj.(data_start_name),'bof');
end
[mess,res] = ferror(obj.file_id_);
if res ~=0; error('HORACE:faccess_sqw_v3:io_error',...
        'Error moving to the %s position. Reason: %s',field_name,mess);
end

bytes = fread(obj.file_id_,data_size,'*uint8');
[mess,res] = ferror(obj.file_id_);
if res ~=0; error('HORACE:faccess_sqw_v3:io_error',...
        'Error readiong the data for field %s. Reason: %s',field_name,mess); end

form = obj.get_si_form(field_name);
res  = form.field_from_bytes(bytes,1);
if strcmp(field_name,'instrument') && version <2
    % only old instrument stored in the file needs conversion and this instrument can be MAPS only
    warning('SQW_FILE:old_version',...
        ['Old instrument is stored within the file.',...
        ' The  instrument was updated automatically',...
        ' but you should consider replacing it to proper modern instrument using set_instrument_horace command']);
    res = convert_legacy_instrument_structure(res);
end
if version == 3
    if iscell(res)
        res = cellfun(@(x)serializable.from_struct(x),res,...
            'UniformOutput',false);
    else
        if isempty(res) || isempty(fieldnames(res))
            if strcmp(field_name,'instrument')
                res = IX_null_inst();
            else
                res = IX_null_sample();
            end
        else
            % NB This will produce a cell array of the deserialized objects
            % in res. For cellarrays of instruments or samples this is
            % fine. For a unique_objects_container this is also fine as the
            % subsequent code will extract the singleton
            % unique_objects_container later on.
            
            res = arrayfun(@(x)serializable.from_struct(x),res,...
                'UniformOutput',false);
        end
    end
end

function [descr,version] = read_si_head_block(obj,field_name,old_matlab)
% read the block, describing sample or instrument version, stored in the
% file
%
head_name = [field_name,'_head_pos_'];
body_name = [field_name,'_pos_'];
ihead_pos = obj.(head_name);
pos = obj.(body_name);
% read field version:
descriptor_sz = pos - ihead_pos;
if  old_matlab % some MATLAB problems with moving to correct eof
    fseek(obj.file_id_,double(ihead_pos),'bof');
else
    fseek(obj.file_id_,ihead_pos,'bof');
end
[mess,res] = ferror(obj.file_id_);
if res ~=0; error('HORACE:get_instr_or_sample:io_error',...
        'Error moving to the %s descriptor position. Reason: %s',fieldname,mess);
end
bytes = fread(obj.file_id_,descriptor_sz,'*uint8');
[mess,res] = ferror(obj.file_id_);
if res ~=0; error('HORACE:get_instr_or_sample:io_error',...
        'Error reading the data for %s descriptor. Reason: %s',fieldname,mess);
end
form = obj.get_si_head_form(field_name);

descr  = obj.sqw_serializer_.deserialize_bytes(bytes,form);
version = descr.version;

