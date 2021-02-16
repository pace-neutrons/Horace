function  obj = put_sqw(obj,varargin)
% Save sqw file using sqw v3 binary format
%
% if key -v2 is provided, force writing v2 file format
% (for testing purposes)
%
%
[ok,mess,force_v2,nopix,reserve,argi]=parse_char_options(varargin,{'-v2','-nopix','-reserve'});
if ~ok
    error('SQW_FILE_IO:invalid_artgument',...
        ['DND_BINFILE_COMMON::put_sqw Error: ',mess]);
end

if nopix
    argi{end + 1} = '-nopix';
end
if reserve
    argi{end + 1} = '-reserve';
end
obj = put_sqw@sqw_binfile_common(obj,argi{:});

if nopix && ~reserve
    % Come this point, it is up to the user of the class to write pixels and
    % call the code that follows to write the footers of the file.
    return;
end

obj = obj.validate_pixel_positions();

if force_v2
    obj.write_v2_obj_header_();
    error('FACCESS_SQW_V3:runtime_error',...
        'forced saving sqw v2 object. v3 writer destroyed')
end

obj = obj.put_footers();
