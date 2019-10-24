function [mess, main_header, position] = get_sqw_main_header_(fid, opt)
% Read the main header block for the results of performing calculate projections on spe file(s).
%
%   >> [mess, main_header, position] = get_sqw_main_header(fid)
%
% The default behaviour is that the filename and filepath that are written to file are ignored; 
% we fill with the values corresponding to the file that is actually being read.
% The name written in the file is read if use the '-hverbatim' option (below). This is needed if
% want to alter header information by overwriting with a block of exactly the same length.
%
% Input:
% ------
%   fid             File pointer to (already open) binary file
%   opt             [Optional] read flag:
%                   '-verbatim'   The file name as stored in the main_header is returned as stored,
%                                and not constructed from the value of fopen(fid).
% Output:
% -------
%   mess            Error message; blank if no errors, non-blank otherwise
%   main_header     Structure containing fields read from file (details below)
%   position        Position of start of main header block
%
%
% Fields read from file are:
% --------------------------
%   main_header.filename   Name of sqw file that is being read, excluding path
%   main_header.filepath   Path to sqw file that is being read, including terminating file separator
%   main_header.title      Title of sqw data structure
%   main_header.nfiles     Number of spe files that contribute


% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)

mess='';
main_header=[];
position = ftell(fid);

% Check verbatim option
if exist('opt','var')
    if ischar(opt) && strcmpi(opt,'-verbatim')
        verbatim=true;
    else
        mess = 'invalid option';
        return
    end
else
    verbatim=false;
end

% Read data from file:
try
    n = fread_catch(fid,1,'int32');
    % Need to try to catch case of e.g. text file where n is read as a stupidly high number
    if n>=0 && n<1024   % allow up to 1024 characters; also allow for the possibility that there was no file name at all!
        dummy_filename = fread(fid,[1,n],'*char');
    else
        mess = 'Unrecognised format for application and version'; return
    end

    n = fread_catch(fid,1,'int32');
    dummy_filepath = fread(fid,[1,n],'*char');

    if verbatim
        % Read filename and path from file
        main_header.filename=dummy_filename;
        main_header.filepath=dummy_filepath;
    else
        % Get file name and path (incl. final separator)
        [path,name,ext]=fileparts(fopen(fid));
        main_header.filename=[name,ext];
        main_header.filepath=[path,filesep];
    end
    
    n = fread_catch(fid,1,'int32');
    main_header.title = fread(fid,[1,n],'*char');

    main_header.nfiles = fread(fid,1,'int32');

catch
    mess='Error reading main header block from file';
end
