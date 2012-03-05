function wout=load_detector_file(file)
% Read full format ASCII detector.dat file into structure of row vectors
%
%   >> wout=load_detector_file              % prompt for file
%   >> wout=load_detector_file(file_in)     % read from the named file
%
%   wout is a structure with fields (all row vectors):
%     'det_no'
%     'delta'
%     'x2'
%     'code'
%     'twotheta'
%     'azimuth'
%     'wx'
%     'wy'
%     'wz'
%     'ax'
%     'ay'
%     'az'
%     'dead_time'
%     'xs'
%     'thick'
%     'index'
%
%   See detector.dat format documentation for full details
%   Note that function does not return the false widths of detectors


% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if ~exist('file','var'), file='*.dat'; end
[file_internal,ok,mess]=getfilecheck(file);
if ~ok, error(mess), end

% Open file
% ---------
fid=fopen(file_internal);
if fid<0
    error(['Cannot open detector file ',file_internal])
end

% Read data from file
% ---------------------
% Have a try...catch block so that wherever the failure takes place, the file can always be closed and the error thrown
try
    % Read header info
    tline=fgets(fid);
    tline=fgets(fid);
    temp = str2num(tline);
    ndet=temp(1);
    nuser=temp(2);
    ncol=nuser+5;
    tline=fgets(fid);
    
    % Two formats acceptable:
    % - 15 columns, last three are detector parameters
    % - 19 columns, last four are detector parameters
    if ~(ncol==15 || ncol==19)
        error('Unrecognised file format')
    end
    
    % Read array to the end, or until unable to read from file with specified format
    fmt=repmat('%f',1,ncol);
    tab = char(9);
    w = textscan(fid, fmt, 'delimiter', [tab,',']);
    fclose(fid);
catch
    fclose(fid);
    rethrow(lasterror)
end

% Pick out columns according to format
wout.det_no=int32(w{1}(:)');        % *** is there any reason why we preserve int32 ? consistency with genie_get/gget?
if numel(unique(wout.det_no))~=numel(wout.det_no)
    error('Detector numbers are not unique in detector.dat file')
end
wout.delta=w{2}(:)';
wout.x2=w{3}(:)';
wout.code=w{4}(:)';
wout.twotheta=w{5}(:)';
wout.azimuth=w{6}(:)';
wout.wx=w{7}(:)';
wout.wy=w{8}(:)';
wout.wz=w{9}(:)';
if ncol==19
    wout.ax=w{13}(:)';
    wout.ay=w{14}(:)';
    wout.az=w{15}(:)';
    wout.dead=w{16}(:)';
    wout.xs=w{17}(:)';
    wout.thick=w{18}(:)';
    wout.index=w{19}(:)';
elseif ncol==15
    wout.ax=w{10}(:)';
    wout.ay=w{11}(:)';
    wout.az=w{12}(:)';
    wout.dead=zeros(size(wout.det_no));
    wout.xs=w{13}(:)';
    wout.thick=w{14}(:)';
    wout.index=w{15}(:)';
end
