function obj = validate_pixel_positions(obj)
%VALIDATE_PIXEL_POSITIONS validate pixel file positions against number of pixels
% If inconsistencies found between the number of pixels in the file and
% the number of pixels expected to be written, print a warning and wait 10
% seconds for the missing pixels to be written. If missing pixels are not
% written, then serialize and write the SQW object headers as a v2 object and
% throw an FACCESS error.
%
BYTES_IN_FLOAT = 4;
PIX_COLS = PixelDataBase.DEFAULT_NUM_PIX_FIELDS;

pix_end = obj.eof_pix_pos_;  % position in file we should be in
do_fseek(obj.file_id_,0,'eof');
file_end = ftell(obj.file_id_);  % actual position of end of file
if uint64(pix_end) > uint64(file_end)
    npix_expected = obj.npixels;
    npix_written = (pix_end - obj.pix_position)/(BYTES_IN_FLOAT*PIX_COLS);
    warning( ...
        'HORACE:FACCESS_SQW_V3:runtime_error', ...
        [ ...
            'Missing pixels: Expected %d but written %d. ' ...
            'File end position %d is smaller than expected pixel end position: %d\n%s' ...
        ], ...
        npix_expected, ...
        npix_written, ...
        file_end, ...
        pix_end, ...
        [ ...
            'Waiting 10 sec to flush filesystem in hope that pixels will ' ...
            'be written.' ...
        ] ...
    );
    for i=1:10
        fprintf('.')
        pause(1);
        do_fseek(obj.file_id_,0,'eof');
        file_end = ftell(obj.file_id_);
        if uint64(pix_end) == uint64(file_end)
            break;
        end
    end
    fprintf('.\n')

    if uint64(pix_end) ~= uint64(file_end)
        % make object an sqw_v2 object and exit
        put_v2_obj_header_(obj);
        error( ...
            'HORACE:FACCESS_SQW_V3:runtime_error',...
            ['can not move to pixel end to write auxiliary V3 information\n', ...
             ' File written as v2 file, which may have corrupted pixels.'] ...
        );
    end
end
