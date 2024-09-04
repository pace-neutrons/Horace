function varargout = read_spe(filename,varargin)
% Get signal, error and energy bin boundaries from an input spe file
%
%>> [S,ERR,en] = read_spe(filename);
%>> [S,ERR,en] = read_spe(filename,['-legacy_reader'],[field_width]);
%
%>> [ne,ndet,en] = read_spe(filename,'-info_only')
%
%Input:
% filename       -- name ascii spe file to read infornation from
%
%Optional:
% '-legacy_reader'-- if provided, reads spe file using legacy reader, which
%                    scans spe file line by line assuming that signal/error
%                    arrays are written in old FORTRAN fixed format.
%                    This operation is slower but uses less memory which is
%                    not important for modern computers.
%                    If this option is absent, reader scans whole file in
%                    memory and identifies field width (below) automatically
%   field_width   -- width of single fixed format field, used by legacy reader.
%                    By default, this value equal to 10, but 11 or 12 may
%                    sometimes occur in some facilities.
%                    makes sence only if '-legacy_reader' field is provided
% '-info_only'    -- if present, function reads and
%                   returns ne,ndet,en parameters only i.e.
%>> [ne,ndet,en] = read_spe(filename,'-info_only')
%Where:
%   ne     - number of energy bins in spe file
%   ndet   - number of detectors stored in spe file.
%
%
% Returns:
%   S          [ne x ndet] array of signal values
%   ERR        [ne x ndet] array of error values (st. dev.)
%   en         ne+1 Column vector of energy bin boundaries
%


% Original author: T.G.Perring
%
%
% Based on Radu coldea routine load_spe in mslice
[ok,mess,info_ony,legacy_reader,argi] = parse_char_options(varargin,{'-info_only','-legacy_reader'});
if ~ok
    error('HERBERT:read_spe:invalid_argument',mess);
end

se_field_width = 10;
if legacy_reader
    if ~isempty(argi)
        se_field_width = argi{1};
        if se_field_width<8 || se_field_width > 13
            error('HERBERT:read_spe:invalid_argument', ...
                'spe field width, if provided may be a value in range from 8 to 13. Provided: %d', ...
                se_field_width);
        end
    end
end

filename=strtrim(filename); % Remove blanks from beginning and end of filename
if isempty(filename)
    error('HERBERT:read_spe:invalid_argument','Input filename is empty');
end
fid=fopen(filename,'rt');
if fid==-1
    error('HERBERT:read_spe:invalid_argument', ...
        ' Can not open file: %s',filename);
end
clob = onCleanup(@()fclose(fid));

% Read number of detectors and energy bins
ndetne=fscanf(fid,'%d',2);
if isempty(ndetne) || ~isnumeric(ndetne) || numel(ndetne) ~=2
    error('HERBERT:read_spe:invalid_argument', ...
        ' file %s is not proper spe file as can not interpret ndet and ne parameters in first row',...
        filename);
end
ndet = ndetne(1);
ne   = ndetne(2);

if (ndet<0) || (ndet > 1e+32) || (ne<0) || (ne> 100000)
    error('HERBERT:read_spe:runtime_error',...
        'found ndet=%d and ne=%d when interpreting file %s',ndet,ne,filename);
end
if legacy_reader
    en = read_en_legacy(fid,ne,ndet);
elseif info_ony
    en = read_and_parse_blocks(filename,true,ne,ndet);
end
%
if info_ony
    varargout{1}   = ne;
    if nargout>1
        varargout{2} = ndet;
    end
    if nargout>2
        varargout{3} = en;
    end
    return;
end
%
if legacy_reader
    [S,ERR] = read_SE_legacy(fid,se_field_width,ne,ndet);
else % smart modern reader
    try
        [en,S,ERR] = read_and_parse_blocks(filename,false,ne,ndet);
    catch
        en = read_en_legacy(fid,ne,ndet);
        [S,ERR] = read_SE_legacy(fid,se_field_width,ne,ndet);
    end
end
if nargout>0
    varargout{1}=S;
end
if nargout>1
    varargout{2}=ERR;
end
if nargout>2
    varargout{3}=en;
end

function [S,ERR] = read_SE_legacy(fid,field_width,ne,ndet)
% Read spe using default
fmt = ['%',num2str(field_width),'f'];

% Read data
S=zeros(ne,ndet);
ERR=zeros(ne,ndet);
try
    for i=1:ndet
        temp  =fgetl(fid);        % read eol character
        s_text=fgetl(fid);        % get rid of line ### S(Phi,w)
        S(:,i)=fscanf(fid,fmt,ne);
        temp  =fgetl(fid);        % read eol character
        temp  =fgetl(fid);        % get rid of line ### Errors
        ERR(:,i)=fscanf(fid,fmt,ne);
    end
catch ME
    error('HERBERT:loader_ascii:io_error', ...
        'Error reading file %s, issue: %s',filename,ME.message);
end

function en = read_en_legacy(fid,ne,ndet)
% read energy bins. Discard angular boundaries
%
temp=fgetl(fid);    % read eol
temp=fgetl(fid);    % read string '### Phi Grid'
temp=fscanf(fid,'%10f',ndet+1); % read phi grid, last value superfluous
temp=fgetl(fid);    % read eol character of the Phi grid table
temp=fgetl(fid);    % read string '### Energy Grid'
en=fscanf(fid,'%10f',ne+1); % read energy grid

function data = parse_data_block(strings_list,row_start,row_end,format)
% read data from array of strings given format of these data
%
% Inputs:
% string_list    -- cellarray of strings, containing input data
% n_first_row    -- number of string, which contain first row of data
% n_last_row     -- number of string containing last row of data to process
% field_width    -- number of positions, a data field occupies in a string
%
% Returns:
% data           -- array of data read from cellarray of strings
data = cell(row_end-row_start+1,1);
ic = 1;
for i=row_start:row_end
    data{ic} = sscanf(strings_list{i},format)';
    ic = ic+1;
end
data = [data{:}];

function [block_end,field_width] = parse_block_size(string_list,n_first_row,block_end_line,n_components)
% Identify format field width within an spe block.
%
% Inputs:
% string_list    -- cellarray of strings, containing input data
% n_first_row    -- number of string, which contain first row of data
% block_end_line -- symbols which define line, terminating block of data
% n_components   -- number of elements, this block of data should contain.
%
% Returns
% block_end      -- number of last line of the data block
% field_width    -- how many symbols each data field occupy
%
n_rows = numel(string_list);
data_symbol_size = 0;
bel_undefined = true;
for i=n_first_row:n_rows
    the_row = string_list{i};
    if the_row(end) == char(13)
        the_row = the_row(1:end-1);
    end
    if strncmpi(the_row,block_end_line,numel(block_end_line))
        block_end = i-1;
        bel_undefined  = false;
        break
    end
    data_symbol_size = data_symbol_size + numel(the_row);
end
if bel_undefined
    block_end = [];
end
field_width = round(data_symbol_size/n_components);

function  [en,S,ERR] = read_and_parse_blocks(filename,info_only,ne,ndet)
% identify format of spe data and read spe data into memory
%
fid = fopen(filename,'rb');
if fid==-1
    error('HERBERT:read_spe:invalid_argument', ...
        ' Can not open file: %s in binary mode',filename);
end
clOb = onCleanup(@()fclose(fid));
if info_only
    %  Read extended block of data to certainly include whole energy bin
    %  boundary block.
    n_positions = 20+20+... % ne,npix values occupy max 10 symbols each
        100+(ndet+1)*20+... % phi block; each field is not bigger than 20 symblos (normally 10)
        100+(ne+1)*20;      % en block;  each field is not bigger than 20 symblos (normally 10)
    data = fread(fid,n_positions,'*char');
else
    % Read all data
    data = fread(fid,'*char');
end
%
eol_pos = find(data == newline);
eol_pos = [0;eol_pos];
if eol_pos(end) ~= numel(data) % guard against non-standard files not ending with \cr or \cl
    eol_pos = [eol_pos;numel(data)];
end
n_lines = numel(eol_pos);
idx = 1:n_lines-1;
data_strings = arrayfun(@(idx)data(eol_pos(idx)+1:eol_pos(idx+1)-1)',idx,'UniformOutput',false);

phi_grid_starts = 3;
if ~strncmp(data_strings{phi_grid_starts-1},'### Phi',7)
    error('HERBERT:read_spe:invalid_argument','Can not identify start of phi grid');
end
phi_grid_ends = parse_block_size(data_strings,phi_grid_starts,'### Energy',ndet+1);
if isempty(phi_grid_ends)
    error('HERBERT:read_spe:runtime_error', [...
        'Can not identify location of ### Energy grid.\n' ...
        'File: %s is not an spe file or broken spe file'], ...
        filename);
end

en_data_starts = phi_grid_ends+2;
[en_data_ends,en_field_width] = parse_block_size(data_strings,en_data_starts ,'### S(Phi',ne+1);

format = ['%',num2str(en_field_width),'f'];
en = parse_data_block(data_strings,en_data_starts,en_data_ends,format)';
if info_only
    S   = ne;
    ERR =ndet;
    return
end
S_start = en_data_ends + 2;
[S_end,s_field_width] = parse_block_size(data_strings,S_start ,'### Err',ne);

data_block_size = S_end-S_start+1; % number of data rows
% Convert string data into numbers
S=zeros(ne,ndet);
ERR=zeros(ne,ndet);
try
    format = ['%',num2str(s_field_width),'f'];
    for i=1:ndet
        S(:,i)= parse_data_block(data_strings,S_start,S_end,format)';

        E_start = S_end   + 2;
        E_end   = E_start + data_block_size-1;
        ERR(:,i)=parse_data_block(data_strings,E_start,E_end,format)';

        S_start  = E_end   + 2;
        S_end    = S_start + data_block_size-1;
    end
catch ME
    error('HERBERT:loader_ascii:io_error', ...
        'Error reading file %s, issue: %s',filename,ME.message);
end
