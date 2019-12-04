function  obj = put_sqw(obj,varargin)
% Save sqw file using sqw v3 binary format
%
% if key -v2 is provided, force writing v2 file format
% (for testing purposes)
%
%
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)
%

[ok,mess,force_v2,argi]=parse_char_options(varargin,{'-v2'});
if ~ok
    error('SQW_FILE_IO:invalid_artgument',...
        ['DND_BINFILE_COMMON::put_sqw Error: ',mess]);
end

obj = put_sqw@sqw_binfile_common(obj,argi{:});

pix_end = obj.eof_pix_pos_;
fseek(obj.file_id_,0,'eof');
file_end = ftell(obj.file_id_);
if uint64(pix_end) - uint64(file_end)>0
    npix_expected = obj.npixels;
    npix_written = (pix_end - obj.pix_position)/(4*9);
    warning('FACCESS_SQW_V3:runtime_error',...
        'Expected %d but written %d pixels. File end position %d is smaller than pixel end position: %d\n%s',...
        npix_expected,npix_written,file_end,pix_end,...
        'Missing pixels: waiting 10 sec to flush filesystem in hope that pixels will be written.');
    for i=1:10
        fprintf('.')
        pause(1);
        fseek(obj.file_id_,0,'eof');
        file_end = ftell(obj.file_id_);
        if uint64(pix_end) - uint64(file_end) == 0
            break;
        end
    end
    fprintf('.\n')
    
    if uint64(pix_end) - uint64(file_end)~= 0
        % make object an sqw_v2 object and exit
        write_v2_obj_header(obj);
        error('FACCESS_SQW_V3:runtime_error',...
            ['can not move to pixel end to write auxiliary V3 information\n',...
            ' File written as v2 file, which may have corrupted pixels.']);
    end
end
if force_v2
    write_v2_obj_header(obj);
    error('FACCESS_SQW_V3:runtime_error',...
        'forced saving sqw v2 object. v3 writer destroyed')    
end

obj = put_sample_instr_records_(obj);
% should not be necessary, as init calculated it correctly, but to be on a
% safe side...
obj.position_info_pos_= obj.instr_sample_end_pos_;
obj = put_sqw_footer_(obj);

function obj=write_v2_obj_header(obj)
% write v3 file as v2 file
%
head = obj.build_app_header();
head.version = 2;
%
head_form = obj.app_header_form_;

% write sqw header
bytes = obj.sqw_serializer_.serialize(head,head_form);
fseek(obj.file_id_,0,'bof');
check_error_report_fail_(obj,'Error moving to the beginning of the file');
fwrite(obj.file_id_,bytes,'uint8');
check_error_report_fail_(obj,'Error writing the sqw file header');

obj=obj.delete();


