function obj=put_sqw_footer_(obj)
% serialized structure, which contains all positions for different data
% fields, to be found in an sqw file of appropriate version and store these
% positions on hdd for subsequent recovery and use in read/write operations
%
persistent old_matlab;
if isempty(old_matlab)
    old_matlab = verLessThan('matlab','8.3');
end

fields2save = obj.fields_to_save();
pos_info  = struct();
for i=1:numel(fields2save)
    fld = fields2save{i};
    pos_info.(fld) = obj.(fld);
end



form = obj.get_si_form();
bytes = obj.sqw_serializer_.serialize(pos_info,form);
sz = uint32(numel(bytes));
byte_sz = typecast(sz,'uint8');
bytes = [bytes,byte_sz];


pos = obj.position_info_pos_;
try
    if old_matlab % some MATLAB problems with moving to correct eof
        do_fseek(obj.file_id_,double(pos),'bof');
    else
        do_fseek(obj.file_id_,pos,'bof');
    end
catch ME
    exc = MException('COMBINE_SQW_PIX_JOB:io_error',...
                     'Can not move to the positions block start');
    throw(exc.addCause(ME))
end

fwrite(obj.file_id_,bytes,'uint8');
check_error_report_fail_(obj,'Can not write the positions block');

obj.real_eof_pos_ = ftell(obj.file_id_);
%-------------------------------------------------------------------------
% now, its impossible to truncate binary file in system independent way and
% Matlab does not provide such functionality too. If the file was longer than
% it is now, we need to store the location of the information record at the
% end of the existing file too.
%
try
    do_fseek(obj.file_id_,0,'eof');
catch ME
    exc = MException('COMBINE_SQW_PIX_JOB:io_error',...
                     'Can not seek to the end of the file');
    throw(exc.addCause(ME))
end
eof_ = ftell(obj.file_id_);

if eof_ > obj.real_eof_pos_
    add_block = eof_ - obj.real_eof_pos_;
    if add_block>0
        if add_block<4; add_block=4; end %its not striclty necessary, as real footer
                                         % size not used any more but done in case if real_eof_pos_ is
                                         % used in a future.

        pos = obj.real_eof_pos_+add_block-4;
        try
            do_fseek(obj.file_id_,pos,'bof');
        catch ME
            exc = MException('COMBINE_SQW_PIX_JOB:io_error',...
                             'Can not seek to the extended file end');
            throw(exc.addCause(ME))
        end

        ext_size = uint32(sz+add_block);
        fwrite(obj.file_id_,ext_size ,'uint32');
    end
end
