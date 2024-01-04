function obj = get_map_ascii (filename)
% Read an ASCII .map file
%
%   >> obj = get_map_ascii (filename)
%
% Input:
% ------
%   filename        Name of map file from which to read data
%
% Output:
% -------
%   obj             IX_map object
%
%
% Format of an ascii map file:
% ----------------------------
%       <nwkno (the number of workspaces)>
%       <wkno(1) (the workspace number>
%       <ns(1) (number of spectra in 1st workspace>
%       <list of spectrum numbers across as many lines as required>
%           :
%       <wkno(2) (the workspace number>
%       <ns(2) (number of spectra in 1st workspace>
%       <list of spectrum numbers across as many lines as required>
%           :
%       <wkno(iw) (the workspace number>
%       <no. spectra in last workspace>
%       <list of spectrum numbers across as many lines as required>
%           :
%
% The list of spectrum numbers can take the form e.g. '12:15, 5:-2:1'
% to specify ranges (in this case [12,13,14,15,5,3,1])
%
% Blank lines and comment lines (lines beginning with ! or %) are ignored.
% Comments can also be put at the end of lines following ! or %.
%
% For examples, see:
%
%
% NOTE: The old VMS format is also supported. This assumes
% the workspaces have numbers 1,2,3...nwkno, and there was also
% information about the effective detector positions that is now
% redundant. This format can no longer be written as it is obsolete:
%
%   <nwkno (the number of workspaces)>
%   <no. spectra in 1st workspace>   <dummy value>   <dummy value>    <dummy value>
%   <list of spectrum numbers across as many lines as required>
%       :
%   <no. spectra in 2nd workspace>   <dummy value>   <dummy value>    <dummy value>
%   <list of spectrum numbers across as many lines as required>
%       :


nbuffer= 100;   % initial buffer size for holding spectrum numbers

% Read lines from file
% --------------------
% Remove blanks from beginning and end of filename
[filename_full, ok, mess] = translate_read(strtrim(filename));
if ~ok
    error ('HERBERT:IX_map:invalid_file_format', ...
        'Error resolving file name: %s.\nMessage: %s', strtrim(filename), mess)
end

% Read file (use Matlab, as files are generally small, so C++ code not really necessary)
str = strtrim(textcell(filename_full));
nline = numel(str);
if nline == 0
    obj = IX_map();     % file is empty; return empty map
    return
end

% Process data from file
% ----------------------
iline = 1;

% Get number of workspaces and initialise arrays to hold data
[nwkno, iline] = get_number_of_workspaces (str, iline, filename_full);

% Read data for workspaces
if nwkno > 0
    % Get .map file format
    [file_fmt, iline] = get_map_file_format (str, iline, filename_full);
    
    % Read the information for each workspace in turn
    wkno = NaN(1,nwkno);
    ns = zeros(1,nwkno);
    [spec, nstot] = accumulate_array_to_buffer([1,nbuffer]);  % create buffer array
    for iw = 1:nwkno
        [wkno(iw), ns(iw), iline] = read_wkno_and_ns (str, iline, filename_full, file_fmt, iw);
        [spec_in_iw, iline] = read_spectrum_numbers (str, iline, ns(iw), filename_full, wkno(iw));
        [spec, nstot] = accumulate_array_to_buffer (spec, nstot, spec_in_iw);
    end
    
    % Repackage for IX_map constructor
    % --------------------------------
    obj = IX_map(spec(1:nstot), 'wkno', wkno, 'ns', ns);
    
else
    % Trivial case of no workspaces
    obj = IX_map ();
end

% Check the rest of the text read from the file, if any, consists solely of
% comment lines
iline = skip_comment_lines (str, iline);
if iline <= numel(str)
    error ('HERBERT:IX_map:invalid_file_format', ...
        ['Unexpected data encountered after the full map file has been read\n',...
        'File: %s\nLine: %s'], filename_full, str{iline})
end


%===============================================================================
function [nwkno, iline] = get_number_of_workspaces (str, iline_in, file_name)
% Get the number of workspaces in the map file
%
%   >> nwkno = get_number_of_workspaces (str, iline_in, file_name)
%
% Input:
% ------
%   str         Cell array of strings
%   iline_in    Line number that is next to be read
%   file_name   Name of file from which the cell array of strings was read
%               (used for error messages)
%
% Output:
% -------
%   nwkno       Number of workspaces ( >= 0)
%   iline       Line number that is next to be read
%               If nwkno was read from the final line, then on exit
%               iline > numel(str).

[nwkno, n, iline] = read_numeric_vector (str, iline_in, file_name);
if (n ~= 1) || (round(nwkno)~=nwkno) || (nwkno < 0)
    error ('HERBERT:IX_map:invalid_file_format', ...
        ['First non-comment line must have just one integer (the number ',...
        'of workspaces, >= 0) and no other non-comment data.\n', ...
        'File: %s\nLine: %s'], file_name, str{iline - 1})
end


%===============================================================================
function [file_fmt, iline] = get_map_file_format (str, iline_in, file_name)
% Get the .map file format.
%
%   >> file_format = get_map_file_format (str, iline_in)
%
% Input:
% ------
%   str         Cell array of strings
%   iline_in    Line number that is next to be read
%   file_name   Name of file from which the cell array of strings was read
%               (used for error messages)
%
% Output:
% -------
%   file_fmt    File format
%                   'default'   ASCII text
%                   'vms'       old style VMS ASCII format
%   iline       Line number that is next to be read

[val, n, iline] = read_numeric_vector (str, iline_in, file_name);

% Determine file format
if (n == 1) && (round(val) == val) && (val >= 1)
    % Encountered a single integer value > 0 ==> workspace number in default
    % format
    file_fmt = 'default';
    
elseif (n == 4) && (round(val(1)) == val(1)) && (val(1) >= 1)
    % Encountered four numeric values, the first an integer value > 0
    % ==> number of spectra in old VMS format
    file_fmt = 'vms';
    
elseif n > 0
    error ('HERBERT:IX_map:invalid_file_format', ...
        ['Unrecognised numeric data encountered when attempting to ',...
        'determine .map file format\n',...
        'File: %s\nLine: %s'], file_name, str{iline - 1})
end

% Back up one line, as the last line read was used to determine the file format
% but is also part of the workspace-spectrum mapping description
iline = iline - 1;


%===============================================================================
function [wkno, ns, iline] = read_wkno_and_ns (str, iline_in, file_name, file_fmt, iw)
% Read workspace number and number of spectra in the workspace
%
%   >> [spec, iline] = read_spectrum_numbers (str, iline_in, ns, file_name, wkno)
%
% Input:
% ------
%   str         Cell array of strings
%   iline_in    Line number that is next to be read
%   file_name   Name of file from which the cell array of strings was read
%               (used for error messages)
%   file_fmt    File format
%                   'default'   ASCII text
%                   'vms'       old style VMS ASCII format
%   iw          Workspace index for which the spectrum numbers are being read
%               (used for error messages, and to fill wkno if determined to be
%               the old VMS .map file format).
%               This is distinct from the 'workspace number'
%
% Output:
% -------
%   wkno        Workspace number
%   ns          Number of spectra in the workspace
%   iline       Line number that is next to be read
%               If wkno and ns were read from the final line, then on exit
%               iline > numel(str).

[val, n, iline] = read_numeric_vector (str, iline_in, file_name);

% Determine if numeric data is consistent with the determined file format
if strcmp(file_fmt, 'default') && (n == 1) && (round(val) == val) && (val >= 1)
    % ------------------------------
    % Files format: default
    % ------------------------------
    % Correctly encountered a single integer, value > 0; val ==> workspace number
    wkno = val;
    
    % Now get the number of spectra in the workspace.
    [ns, n, iline] = read_numeric_vector (str, iline, file_name);
    if (n ~= 1) || (round(ns)~=ns) || (ns < 0)
        error ('HERBERT:IX_map:invalid_file_format', ...
            ['Unexpected data when expecting the number of spectra (>= 0) ',...
            'and no other non-comment data.\n', ...
            'File: %s\nLine: %s'], file_name, str{iline - 1})
    end
    
elseif strcmp(file_fmt, 'vms') && (n == 4) && (round(val(1)) == val(1)) && (val(1) >= 1)
    % ------------------------------
    % Files format: old VMS
    % ------------------------------
    % Correctly encountered four numeric values, the first an integer value > 0;
    % val(1) ==> number of spectra
    wkno = iw;
    ns = val(1);
    
elseif n > 0
    error ('HERBERT:IX_map:invalid_file_format', ...
        ['Data inconsistent with file format ''%s'' when reading workspace ',...
        'header information.\n',...
        'File: %s\nLine: %s'], file_fmt, file_name, str{iline - 1})
end


%===============================================================================
function [spec, iline] = read_spectrum_numbers (str, iline_in, ns, file_name, wkno)
% Read spectrum numbers
%
%   >> [spec, iline] = read_spectrum_numbers (str, iline_in, ns, file_name, wkno)
%
% Input:
% ------
%   str         Cell array of strings
%   iline_in    Line number that is next to be read
%   ns          Number of spectra that are to be read
%   file_name   Name of file from which the cell array of strings was read
%               (used for error messages)
%   wkno        Workspace number for which the spectrum numbers are being read
%               (used for error messages)
%
% Output:
% -------
%   spec        Row vector of spectrum numbers
%   iline       Line number that is next to be read
%               If spectrum numbers were read from the final line, then on exit
%               iline > numel(str).

iline = iline_in;   % next line to read
spec = NaN(1,ns);

% Trivial case of no spectrum numbers to be read
if ns == 0
    return
end

% Throw error if end of file has been reached
if iline > numel(str)
    error ('HERBERT:IX_map:invalid_file_format', ...
        ['End of file reached without reading a complete .map file\n',...
        'File: %s'], file_name)
end

% Read lines from cell array of strings
ns_rem = ns;    % number of spectrum numbers still to be read
is_hi = 0;         % number of spectrum numbers read so far
iline_max = numel(str); % maximum line number
while iline <= iline_max && ns_rem > 0
    [spec_tmp, no_excess] = str_to_iarray(str{iline}, ns_rem);
    if ~no_excess
        error ('HERBERT:IX_map:invalid_file_format', ...
            ['Too many spectrum numbers given for the workspace numbered %d.\n', ...
            'File: %s\nLine: %s'], wkno, file_name, str{iline})
    end
    if ~isempty(spec_tmp)
        is_lo = is_hi + 1;
        is_hi = is_hi + numel(spec_tmp);
        spec(is_lo:is_hi) = spec_tmp;
        ns_rem = ns_rem - numel(spec_tmp);
    end
    iline = iline + 1;
end

% Read all the lines in the file or read the required number of spectra
if ns_rem > 0
    error ('HERBERT:IX_map:invalid_file_format', ...
        ['Insufficient spectrum numbers given for the workspace numbered %d.\n', ...
        'File: %s'], wkno, file_name)
end


%===============================================================================
function [val, n, iline] = read_numeric_vector (str, iline_in, file_name)
% Read a series of numeric scalars from a cell array of strings
%
%   >> [val, n, iline] = read_numeric_vector (str, iline_in, file_name)
%
% Succesively skips over purely comment lines (those whose first non-whitespace
% character is '%' or '!'). Then checks it has one or more numeric values and no
% other non-comment data. otherwise it throws a format error.
% The start of an in-line comment is indicated by '%' or '!').
%
% Input:
% ------
%   str         Cell array of strings
%   iline_in    Line number that is next to be read
%   file_name   Name of file from which the cell array of strings was read
%               (used for error messages)
%
% Output:
% -------
%   val         Row vector of numeric values
%   n           Number of values (guaranteed to be > 0)
%   iline       Line number that is next to be read.
%               If the end of the file was reached without reading a numeric
%               vector then an error is thrown.
%               If numeric vector was read from the final line, then on exit
%               iline > numel(str).

iline = skip_comment_lines (str, iline_in);

% Throw error if end of file has been reached
if iline > numel(str)
    error ('HERBERT:IX_map:invalid_file_format', ...
        ['End of file reached without reading a complete .map file\n',...
        'File: %s'], file_name)
end

% Attempt to read a row of single numbers. Ignore format failure if it is due to
% trailing characters starting with '%' or '!' - these are deemed to be comments
[val, n, errmsg, pos] = sscanf(str{iline}, '%g');
if ~(isempty(errmsg) || any(strcmp(str{iline}(pos:pos), {'%','!'})))
    error ('HERBERT:IX_map:invalid_file_format', ...
        ['Unexpected characters when expecting numeric data\n',...
        'File: %s\nLine: %s'], file_name, str{iline})
end

iline = iline + 1;  % move to next line to be read


%===============================================================================
function iline = skip_comment_lines (str, iline_in)
% Find the next non-comment line in a cell array of strings
% Comment lines are those with first character '%' or'!'.
%
%   >> iline = skip_comment_lines (str, iline_in)
%
% Input:
% ------
%   str         Cell array of strings.
%               It is assumed that leading whitespace has already been removed.
%
%   iline_in    Line number that is next to be read.
%
% Output:
% -------
%   iline       Line number that is next to be read after skipping over
%               comment lines.
%               If the str contains only comment lines from iline_in onwards
%               then on exit iline = numel(str) + 1

iline = iline_in;
while iline <= numel(str)
    if ~(isempty(str{iline}) || any(strcmp(str{iline}(1:1), {'!','%'})))
        break
    end
    iline = iline + 1;
end
