function obj = put_sample_instr_records_(obj,varargin)
% Calculate positions of sample and instrument records to place to binary
% sqw file.
%
% Usage:
%>> obj = put_sample_instr_records_(obj) --  saves sample&instrument records
%         taked from internal sqw object
%>> obj = put_sample_instr_records_(obj,an_sqw_object) -- saves
%         sample&instrument records taken from sqw object provided
%>> obj = put_sample_instr_records_(obj,is_holder_object) -- saves sample||
%         instrument || both hold by auxiliary is_holder object
%>> obj = put_sample_instr_records_(obj,[])  -- clears all instrument and
%         sample information
%
%
% $Revision$ ($Date$)
%
%
%
obj.check_obj_initated_properly();
setting_sample = true;
setting_instr  = true;
% extract sqw header from various sources, including sqw provided as input,
% sqw_holder or just instrument and sample provided as inputs
header = obj.extract_correct_subobj('header',varargin{:});
if isa(header,'is_holder')
    header.n_files = obj.num_contrib_files;
    instr = header.instrument;
    sampl  = header.sample;
    setting_sample = header.setting_sampl;
    setting_instr  = header.setting_instr;
    if setting_instr && ~setting_sample % existing instrument should be retrieved for not to be overwritten
        sampl  = obj.get_sample('-all');
        setting_sample = true;
    end
elseif isempty(header)
    instr = struct();
    sampl = struct();
else % should be header of an sqw file provided
    % extract instrument and sample from the headers block
    instr = extract_subfield_(header,'instrument');
    sampl = extract_subfield_(header,'sample');
end
%
if setting_instr
    %
    % serialize instrument(s)
    [bytes,instr_size] = serialize_si_block_(obj,instr,'instrument');
    %
    % recaclualate instrument positions (just in case)
    instr_head_size = numel(bytes)-instr_size;
    obj.instrument_pos_  = obj.instrument_head_pos_ + instr_head_size;
    obj.sample_head_pos_ = obj.instrument_pos_+ instr_size;
    %
    if ~isempty(obj.upgrade_map_) % for consistency and diagnostics.  Never been used
        um = obj.upgrade_map_;
        um = um.set_cblock_param('instr_head',obj.instrument_head_pos_,instr_head_size);
        um = um.set_cblock_param('instrument',obj.instrument_pos_,instr_size);
        obj.upgrade_map_ = um;
    end
    %
    start = obj.instrument_head_pos_;
    if verLessThan('matlab','8.3') % some MATLAB problems with moving to correct eof
        fseek(obj.file_id_,double(start),'bof');
    else
        fseek(obj.file_id_,start,'bof');
    end
    
    check_error_report_fail_(obj,'can not move to the instrument(s) start position');
    fwrite(obj.file_id_,bytes,'uint8');
    check_error_report_fail_(obj,'error writing serialized instrument(s)');
end

if setting_sample
    % serialize sample(s)
    [bytes,sample_size] = serialize_si_block_(obj,sampl,'sample');
    %clc_size = obj.instr_sample_end_pos_ - obj.sample_pos_;
    % recaclualate sample positions (just in case)
    sample_head_size = numel(bytes)-sample_size;
    obj.sample_pos_  = obj.sample_head_pos_ + sample_head_size;
    obj.instr_sample_end_pos_ = obj.sample_pos_ + sample_size;
    if ~isempty(obj.upgrade_map_) % for consistency and diagnostics.  Never been used
        um = obj.upgrade_map_;
        um = um.set_cblock_param('sample_head',obj.sample_head_pos_,sample_head_size);
        um = um.set_cblock_param('sample',obj.sample_pos_,sample_size);
        obj.upgrade_map_ = um;
    end
    
    %
    if verLessThan('matlab','8.3') % some MATLAB problems with moving to correct eof
        fseek(obj.file_id_,double(obj.sample_head_pos_),'bof');
    else
        fseek(obj.file_id_,obj.sample_head_pos_,'bof');
    end
    check_error_report_fail_(obj,'can not move to the sample(s) start position');
    fwrite(obj.file_id_,bytes,'uint8');
    check_error_report_fail_(obj,'error writing  serialized sample(s)');
    %
    obj.real_eof_pos_ = ftell(obj.file_id_);
end
