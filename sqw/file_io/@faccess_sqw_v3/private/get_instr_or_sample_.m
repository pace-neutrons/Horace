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
    error('SQW_FILE_IO:invalid_argument',...
        'get_%s, error: %s',field_name,mess )
end
samp_block = get_all_instr_or_samples_(obj,field_name);
%obj.([field_name,'_holder_']) = samp_block;
if get_all
    res  = samp_block;
    return
end

if ~isempty(other)
    n_inst = other{1};
    if ~isnumeric(n_inst)
        error('SQW_FILE_IO:invalid_argument',...
            'get_%s, error: %s',field_name,mess )
    end
    if n_inst<1 || n_inst > obj.num_contrib_files
        error('FACCESS_SQW_V3:invalid_argument',...
            'get_%s, Requested the %s N%d when only %d %s-s are availible',...
            field_name,field_name,n_inst,obj.num_contrib_files,field_name)
    end
else
    n_inst = 1;
end
if iscell(samp_block)
    res = samp_block{n_inst};
else
    res = samp_block(n_inst);
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
if ischar(obj.num_contrib_files_)
    error('FACCESS_SQW_V3:runtime_error',...
        'get_instr_or_sample_ for %s called on non-initialized object',...
        field_name);
end

if strcmp(field_name,'instrument')
    pos = obj.instrument_pos_;
    sz = obj.sample_head_pos_-obj.instrument_pos_;
elseif strcmp(field_name,'sample')
    pos = obj.sample_pos_;
    sz  = obj.instr_sample_end_pos_ - obj.sample_pos_;
else
    error('FACCESS_SQW_V3:invalid_argument',...
        'unknown field %s when trying to retrieve instrument or sample from the file',...
        field_name);
end

if verLessThan('matlab','8.1') % some MATLAB problems with moving to correct eof
    fseek(obj.file_id_,double(pos),'bof');
else
    fseek(obj.file_id_,pos,'bof');    
end
[mess,res] = ferror(obj.file_id_);
if res ~=0; error('SQW_FILE_IO:io_error',...
        'Error moving to the %s position. Reason: %s',field_name,mess); end

bytes = fread(obj.file_id_,sz,'*uint8');
[mess,res] = ferror(obj.file_id_);
if res ~=0; error('SQW_FILE_IO:io_error',...
        'Error readiong the data for field %s. Reason: %s',field_name,mess); end

form = obj.get_si_form(field_name);
res  = form.field_from_bytes(bytes,1);

