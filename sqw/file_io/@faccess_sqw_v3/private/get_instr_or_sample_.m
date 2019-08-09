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
    if numel(samp_block) == 1
        res = samp_block{1};
    else
        res = samp_block{n_inst};
    end
else
    if numel(samp_block) == 1
        res = samp_block;
    else
        res = samp_block(n_inst);
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

convert_old_classes = false;

if ischar(obj.num_contrib_files_)
    error('FACCESS_SQW_V3:runtime_error',...
        'get_instr_or_sample_ for %s called on non-initialized object',...
        field_name);
end

if strcmp(field_name,'instrument')
    ihead_pos = obj.instrument_head_pos_;
    pos = obj.instrument_pos_;
    sz = obj.sample_head_pos_-obj.instrument_pos_;
    % read instrument version:
    descriptor_sz = pos - ihead_pos;
    if  old_matlab % some MATLAB problems with moving to correct eof
        fseek(obj.file_id_,double(ihead_pos),'bof');
    else
        fseek(obj.file_id_,ihead_pos,'bof');
    end
    [mess,res] = ferror(obj.file_id_);
    if res ~=0; error('SQW_FILE_IO:io_error',...
            'Error moving to the instrument descriptor position. Reason: %s',mess); end
    bytes = fread(obj.file_id_,descriptor_sz,'*uint8');
    [mess,res] = ferror(obj.file_id_);
    if res ~=0; error('SQW_FILE_IO:io_error',...
            'Error readiong the data for instrument descriptor. Reason: %s',mess); end
    form = obj.get_si_head_form('instrument');
    
    instr_descriptor  = obj.sqw_serializer_.deserialize_bytes(bytes,form);
    if instr_descriptor.version == 1
        convert_old_classes = true;
    end
elseif strcmp(field_name,'sample')
    pos = obj.sample_pos_;
    sz  = obj.instr_sample_end_pos_ - obj.sample_pos_;
else
    error('FACCESS_SQW_V3:invalid_argument',...
        'unknown field %s when trying to retrieve instrument or sample from the file',...
        field_name);
end

if  old_matlab % some MATLAB problems with moving to correct eof
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

% only old instrument stored in the file needs conversion and this instrument can be MAPS only
if convert_old_classes 
    if isempty(fieldnames(res)) % actually, there are no instrument present.
        return;
    end
    warning('SQW_FILE:old_version',...
        ['Old instrument is stored within the file.',...
    ' The  instrument was updated automatically',...
    ' but you should consider replacing it to proper modern instrument using set_instrument_horace command']); 
    res = convert_legacy_instrument_structure(res);
%     chop = res.fermi_chopper;
%     en = chop.energy;
%     freq = chop.frequency;
%     ch_name = chop.name;
%     res = maps_instrument(en,freq,ch_name);

end