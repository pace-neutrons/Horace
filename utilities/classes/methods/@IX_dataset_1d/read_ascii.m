function wout = read_ascii (wdummy,varargin)
% Read x,y or x,y,e column arrays into a IX_dataset_1d or array of IX_dataset_1d. Inverse of save_ascii.
%   - Automatically detects if data is point or histogram data.
%   - Skips over non-numeric blocks of data
%   - Reads succesive block of numeric data, filling succesive datasets
%   - Columns can be separated by spaces, commas or tabs. Commas and tabs
%    can be used to indicate columns to skip e.g. the line
%                   13.2, ,15.8
%    puts 13.2 in column 1 and 15.8 in column 3.
%
%
% Auto-detect a single dataset:
% -----------------------------
%   >> w = read_ascii (IX_dataset_1d)          % prompts for file
%   >> w = read_ascii (IX_dataset_1d, file)    % read from named file
%
% If just two columns of numeric data are found, then these are used as the x and y values; if
% three or more columns are found then the first three columns are used as the x,y,e values:
%
%
% Give columns to read into one or more workspaces:
% -------------------------------------------------
% (Note that if the file is not given, then prompts for the file)
%   >> w = read_ascii (..., 4,6)       % columns 4,6 are x,y; no error bars
%   >> w = read_ascii (..., 3,5,2)     % columns 3,5, and 2 are x,y,e respectively
%   >> w = read_ascii (..., 4, [6,8,10], [7,9,11])
%        % three spectra, x data is col 4, then y-e are cols 6,7, cols 8,9, cols 10,11 respectively
%   >> w = read_ascii (..., [4,7,10], [5,8,11], [6,9,12])
%        % three spectra, x-y-e are cols 4,5,6, cols 7,8,9, cols 10,11,12 respectively
%
%
%
% To return the data as an array:
%
%   >> arr = read_ascii (IX_dataset_1d,file,0)  % read from named file
%   >> arr = read_ascii (IX_dataset_1d,0)       % prompts for file

wout=[];
narg=numel(varargin);

% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if narg==0 || isnumeric(varargin{1})
    file='';
    offset=0;
else
    file=varargin{1};
    offset=1;
end
[file_full,ok,mess]=getfilecheck(file);
if ~ok, error(mess), end


% Get column numbers for x,y,e data:
% ---------------------------------------
[col_x,col_y,col_e,xye,return_array,ok,mess]=get_col_indicies(varargin{offset+1:end});
if ~ok
    error(mess)
end

% Read data from file
% ---------------------
fid = fopen(file_full);
disp (['Reading data from ',file_full,' ...'])

nw=0;
nblock=0;
while 1>0
    [w,ok,mess]=read_ascii_data_textscan (fid, col_x, col_y, col_e, xye, return_array);
    if ok
        if ~isempty(w) && isempty(wout)
            wout=w;
        elseif ~isempty(w) && ~isempty(wout)
            if ~return_array
                wout=[wout;w];
            else
                if ~iscell(wout), wout={wout}; end  % read only one array up to now; make it a cell
                wout=[wout,{w}];
            end
        else
            break
        end
        nw=nw+numel(w);
        nblock=nblock+1;
        if nblock==1, mess_1=mess; end
    else
        fclose(fid);
        error(mess)
    end
end
fclose(fid);
    
if ~isempty(wout)
    if nblock==1
        disp(mess_1)
    else
        disp(['Read ', num2str(nw),' datasets from ', num2str(nblock),' blocks of data'])
    end
else
    error('No data read from file')
end

end

%==================================================================================================
function [col_x,col_y,col_e,xye,return_array,ok,mess]=get_col_indicies(varargin)
% Create list of column numbers for x,y,e data.
% 
%   >> [col_x,col_y,col_e,xye,ok,mess]=get_col_indicies                     % default columns
%   >> [col_x,col_y,col_e,xye,ok,mess]=get_col_indicies(0)                  % just read array
%   >> [col_x,col_y,col_e,xye,ok,mess]=get_col_indicies(xfmt,yfmt)
%   >> [col_x,col_y,col_e,xye,ok,mess]=get_col_indicies(xfmt,yfmt,efmt)
%
% Input:
% ------
%   If xfmt, yfmt and efmt are missing, then attempt to read x-y or x-y-e data
%  according to the number of columns detected.
% 
%   Otherwise:
%
%   xfmt        list of column numbers for x values of output datasets
%                 - one index means all datasets will have the same x values
%                 - or one index per dataset
%   yfmt        list of column numbers for y values
%                 - one index per dataset
%   efmt        [optional] list of column numbers for error values
%                 - one index per dataset
%                 - if not given, then do not read datasets
%
% Output:
% -------
%   col_x       list of x columns
%   col_y       list of y columns
%   col_e       list of error columns, =[] if no e arrays, or auto-detect
%   xye         true=read error bars; false=do not read error bars;  []=auto-detect
%   return_array false=data to be returned as spectra; true=read numeric block as an array
%   ok          =true if no problems, =false if error
%   mess        message if ok=false

ok=true;
mess='';

ncol_read=numel(varargin);

if ncol_read==0         % auto-detect x-y or x-y-e data
    col_x=1;
    col_y=2;
    col_e=[];
    xye=[];
    return_array=false;
    
elseif ncol_read==1 && isequal(varargin{1},0)
    col_x=[]; col_y=[]; col_e=[]; xye=[]; return_array=true; 
    
elseif ncol_read==2 || ncol_read==3
    if isnumeric(varargin{1}) && min(varargin{1})>0
        col_x = varargin{1}(:)';    % make a row vector
    else
        col_x=[]; col_y=[]; col_e=[]; xye=[]; return_array=[];
        ok=false; mess='Must give positive integer(s) for x-axis column number(s)'; return
    end
    if isnumeric(varargin{2}) && min(varargin{2})>0 && ...
            (numel(col_x)==1 || numel(varargin{2})==numel(col_x))
        col_y = varargin{2}(:)';
        if numel(col_x)~=numel(col_y)
            col_x = repmat(col_x,1,numel(col_y));
        end
    else
        col_x=[]; col_y=[]; col_e=[]; xye=[]; return_array=[];
        ok=false; mess='Check y-axis column number(s)'; return
    end
    if ncol_read~=3
        col_e=[];
        xye=false;
        return_array=false;
    else
        if isnumeric(varargin{3}) && min(varargin{3})>0 && numel(varargin{3})==numel(col_y)
            col_e = varargin{3}(:)';
        else
            col_x=[]; col_y=[]; col_e=[]; xye=[]; return_array=[];
            ok=false; mess='Check error column number(s)'; return
        end
        xye=true;
        return_array=false;
    end
    
else      % can only ask for zero, two or three columns
    col_x=[]; col_y=[]; col_e=[]; xye=[]; return_array=[];
    ok=false; mess='Can only read x-y or x-y-e data'; return
end

end


%==================================================================================================
function [w,ok,mess]=read_ascii_data_textscan (fid, col_x, col_y, col_e, xye, return_array)
% Read data from open ascii file; return as row vector of IX_dataset_1d objects or array, as requested
%
% OK can be true, but no data read - in which case the message is non-empty.

w=[];
ok=true;
mess='';

file_full=fopen(fid);
if ~return_array
    ncol_min = max([max(col_x),max(col_y),max(col_e)]);
else
    ncol_min=1;
end

% Skip over lines that do not consist solely of numbers, with at least the minimum required number of columns
header={};
data_found = 0;
while ~data_found
    istart=ftell(fid);
    if (istart<0)
        ok=false; mess=['No x-y-e data encountered in ' file_full]; return
    end
    tline = fgets(fid);
    if isequal(tline,-1), break, end    % reached end of file withoug encountering data
    temp = str2num(tline);
    if length(temp)>=ncol_min
        ncol = length(temp);
        data_found = 1;
        if isempty(xye)
            if ncol>=3        % autodetect x-y or x-y-e
                col_e=3;
                xye=true;
            else
                xye=false;
            end
        end
    else
        header=[header,tline];
    end
end

% Error if no data found:
if ~data_found
    ok=true; mess='No block of numeric data found with the required number of columns'; return
end

% Step back one line now that number of columns found and any format ambiguities resolved:
fstatus=fseek(fid,istart,'bof'); % step back one line
if (fstatus~=0)
    ok=false; mess=['Problem reading from file ' file_full]; return
end

% Read array to the end, or until unable to read from file with specified format
fmt=repmat('%f',1,ncol);
tab = char(9);
%a = textscan(fid, fmt, 'delimiter', [tab,',']);    % has problem if a leading tab character
a = textscan(fid, fmt);
if (isempty(a))
    ok=true; mess=['No data encountered in ' file_full]; return
end

% Perform some checks on the data that has been read:
%  The function textscan makes a cell array of column vectors. Recall that if a row contains more than ncol
% numeric fields, more than one row in the output cell array will be filled. Cannot check definitively that
% the column lengths are not all the same. We will make the assumption that all rows have the same number
% of elements, with the possible exception of the last row (which will be used to determine if histogram data
% in the case of auto-detect x-y-e)

n = length(a{1});

% Make some consistency checks
if ncol>1
    n_nan = zeros(1,n);
    for i=1:ncol
        n_nan(i) = length(find(isnan(a{i}(1:end-1))));  % the last row is treated differently
    end
    if any(n_nan(col_x)>0)
        ok=false; mess='Check format of column data - one or more x coordinates are not-a-number'; return
    end
end

% Determine if histogram data or not by examining the last row
last_row = zeros(1,ncol);
for i=1:ncol
    last_row(i)=a{i}(end);
end
if ~return_array
    nx=length(a{col_x(1)});
    nw=length(col_x);
    lx=length(find(isnan(last_row(col_x))));
    ly=length(find(isnan(last_row(col_y))));
    if ~xye
        if lx==0 && ly==nw && nx>1  % all data are histogram
            ny=nx-1;
        elseif lx==0 && ly==0       % all data are point
            ny=nx;
        elseif lx==nw && ly==nw && nx>1     % last row has entries, but none for the columns of interest, and all are point
            nx=nx-1;
            ny=nx;
        else
            ok=false; mess='Check format of column data - must be all histogram or all point x-y-e data'; return
        end
    else               
        le=length(find(isnan(last_row(col_e))));
        if lx==0 && ly==nw && le==nw && nx>1
            ny=nx-1;
        elseif lx==0 && ly==0 && le==0
            ny=nx;
        elseif lx==nw && ly==nw && le==nw && nx>1
            nx=nx-1;
            ny=nx;
        else
            ok=false; mess='Check format of column data - must be all histogram or all point x-y-e data'; return
        end
    end
else
    if ~isempty(find(isnan(last_row), 1))
        ok=false; mess='Check format of column data - some empty fields in last row'; return
    end
end


% Return data
if ~return_array
    % *** Should check monotonicity of x values. If histogram data, then require all x are monotonic increasing
    % For point data, reorder x to be monotonic to make valid IX_dataset_1d objects
    
    wref=read_header(header);
    if isempty(wref.title),
        wref.title = char(avoidtex(file_full));
    end
    if (xye)
        w = IX_dataset_1d(a{col_x(1)}(1:nx)',a{col_y(1)}(1:ny)',a{col_e(1)}(1:ny)',...
                                    wref.title,wref.x_axis,wref.s_axis,wref.x_distribution);
        if nw>1
            for i=2:nw
                w(i) = IX_dataset_1d(a{col_x(i)}(1:nx)',a{col_y(i)}(1:ny)',a{col_e(i)}(1:ny)',...
                                    wref.title,wref.x_axis,wref.s_axis,wref.x_distribution);
            end
        end
    else
        w = IX_dataset_1d(a{col_x(1)}(1:nx)',a{col_y(1)}(1:ny)',zeros(ny,1)',...
                                    wref.title,wref.x_axis,wref.s_axis,wref.x_distribution);
        if nw>1
            for i=2:nw
                w(i) = IX_dataset_1d(a{col_x(i)}(1:nx)',a{col_y(i)}(1:ny)',zeros(ny,1)',...
                                    wref.title,wref.x_axis,wref.s_axis,wref.x_distribution);
            end
        end
    end
else
    w = cell2mat(a);
end

if ~return_array
    if nx~=ny; type = 'histogram'; else type = 'point'; end;
    if xye; cols='x-y-e'; else cols='x-y'; end;
    if nw>1
        mess=['Read ', num2str(nw),' datasets of ', cols, ' ', type,' data [', num2str(ny), ' signal values]'];
    else
        mess=['Read one dataset of ', cols, ' ', type, ' data [', num2str(ny), ' signal values]'];
    end
else
    mess=['Read array of data: ',num2str(size(w,2)),' columns, ',num2str(size(w,1)),' rows'];
end

end

%==================================================================================================
function w=read_header(header)
% Read titling information from header, if possible
w=IX_dataset_1d;
if ~isempty(header)
    tmp=get_labels_to_struct(header);
    if isfield(tmp,'title'), w.title=tmp.title; end
    try
        s_axis=IX_axis;
        if isfield(tmp,'signal_caption'), s_axis.caption=tmp.signal_caption; end
        if isfield(tmp,'signal_units'), s_axis.units=tmp.signal_units; end
        if isfield(tmp,'signal_code'), s_axis.code=tmp.signal_code; end
        w.s_axis=s_axis;
    catch
        disp('Header information has wrong format to create signal axis labels')
    end
    try
        x_axis=IX_axis;
        if isfield(tmp,'x_caption'), x_axis.caption=tmp.x_caption; end
        if isfield(tmp,'x_units'), x_axis.units=tmp.x_units; end
        if isfield(tmp,'x_code'), x_axis.code=tmp.x_code; end
        w.x_axis=x_axis;
    catch
        disp('Header information has wrong format to create x-axis labels')
    end
    if isfield(tmp,'x_distribution')
        var=tmp.x_distribution;
        if is_string(var) && numel(str2num(var))==1
            w.x_distribution=str2num(var);
        else
            disp('Header information has wrong format to create x-axis distribution flag')
        end
    end
end

end
