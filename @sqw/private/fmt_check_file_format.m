function varargout=fmt_check_file_format(ver,opt)
% Check the file format specifier is valid
%
% Get default file format version
%   >> ver = fmt_check_file_format()
%
% Check if input is a valid current format for writing
%   >> [ok,mess] = fmt_check_file_format (ver)
%   >> [ok,mess] = fmt_check_file_format (ver, 'write')
%
% Check if input is a valid current format for reading
%   >> [ok,mess] = fmt_check_file_format (ver, 'read')
%
%
% -------------------------------------------------------------------------
% Version history of sqw file formats
% -------------------------------------------------------------------------
%
% File format '-v0'
% -----------------
% July 2007(?) - Autumn 2008
%
% Original sqw file format. It differs with respect to tne '-v1' format
% that follows in that the following were not saved:
%   - application name and version
%   - sqw-type and number of dimensions (these have to be determined from
%     the other contents of the file)
%   - filename, filepath, title, alatt, angdeg are not stored in the data
%     section (these will be filled from the main header when converting to
%     later formats)
% In addition,
%   - The signal and error for the bins was stored without normalisation
%     by the number of pixels.
%
% It appears that the dnd-type format did not hold npix - presumably the
% signal and error arrays were normalised. However, this means that the
% full dnd-type data cannot be regenerated, and so these files are will be
% rejected by the current version of Horace.
%
% Input from '-v0' sqw-type (but not dnd-type) is retained for backwards
% compatibility. Output in '-v0' format is not supported.
%
%
% File format '-v1'
% -----------------
% Autumn 2008 - present
%
% The version number stored in the application block of the file only
% refered to the Horace version. Horace version 1 and version 2 have the
% same sqw file format, which is deemed '-v1'. (The file format was refered
% to as '-v2' in the Horace source code from some point until August 2014).
%
% Output in file format '-v1' is retained for backwards compatibility
%
%
% File format '-v3'
% -----------------
% November 2013 - present
%
% Identical to '-v1', but with addition information at the end of the file:
% - instrument and sample header information (the contents are held in the
%   sqw object in the header field with fields 'instrument' and 'sample'
% - positions of data blocks and major fields in the file
% - type of data in the file
%
% Output in file format '-v3' is retained for backwards compatibility
%
%
% File format '-v3.1'
% -------------------
% August 2014 - present
%
% Format of sqw file has the same information as format 3, but the fields
% are stored as float64 rather than float32 or int32 in general, apart from
% s,e,pix. A redundant field of 4 bytes just after urange in the data 
% block has now been removed.
% In addition a new sparse format was introduced for the case of sqw type
% data from a single spe file.
%
% -------------------------------------------------------------------------

if nargin==0
    varargout{1}=appversion(3,1);       % '-v3.1'
elseif isa(ver,'appversion') && isscalar(ver)
    if nargin==1 || strcmpi(opt,'write')
        if ver==appversion(3,1) ||...       % '-v3.1'
                ver==appversion(3) ||...    % '-v3'
                ver==appversion(1)          % '-v1'
            varargout{1}=true;
            if nargout==2, varargout{2}=''; end
        else
            varargout{1}=false;
            if nargout==2, varargout{2}='File format version not supported for writing'; end
        end
    elseif strcmpi(opt,'read')
        if ver==appversion(3,1) ||...       % '-v3.1'
                ver==appversion(3) ||...    % '-v3'
                ver==appversion(1) ||...    % '-v1'
                ver==appversion(0)          % '-v0'
            varargout{1}=true;
            if nargout==2, varargout{2}=''; end
        else
            varargout{1}=false;
            if nargout==2, varargout{2}='File format version not supported for reading'; end
        end
    end
else
    varargout{1}=false;
    if nargout==2, varargout{2}='File format version has incorrect type'; end
end
