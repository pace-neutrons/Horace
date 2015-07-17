function [data,det,is_mat_file] = get_mat_column_data (datafile)
% Get data from .mat file with column data qx-qy-qz-eps-signal-error
%
%   >> data = get_mat_column_data (datafile)
%
% Input:
% ------
%   datafile    Full file name of .mat data file
%               File must contain one of the following sets of arrays
%                   qx  qy  qz  S
%                   qx  qy  qz  S  ERR
%                   qx  qy  qz  eps  S  ERR
%
%               Here qz is the component of momentum along ki (Ang^-1)
%                   qy  is component vertically upwards (Ang^-1)
%                   qx  defines a hight-hand coordinate frame with qy and qz
%                   S   signal
%                   ERR standard deviation
%
% Output:
% -------
%   data        Data structure with following fields:
%                   data.filename   Name of file excluding path
%                   data.filepath   Path to file including terminating file separator
%                   data.qspec      [4 x n] array of qx,qy,qz,eps of all the data points
%                                  where now the component are in spectrometer coordinates
%                                 (qx||ki, qz up; qx,qy,qz orthonormal and units Ang^-1)
%                   data.S          [1 x n] array of signal values
%                   data.ERR        [1 x n] array of error values (st. dev.)
%                   data.en         Column vector length 2 of min and max eps in the ascii file
%
%   det         Data structure containing fake detector parameters for unmasked
%              detectors (see get_par for fields)
%
%   is_mat_file True if could read file as mat file


% Get file name and path (incl. final separator)
[path,name,ext]=fileparts(datafile);
data.filename=[name,ext];
data.filepath=[path,filesep];

% Try to read file as mat file
try
    warn_state=warning('off','all');    % turn off warnings (so don't get message if cannot find some fields)
    try
        data_in=load(datafile,'-mat','qx','qy','qz','eps','S','ERR');
        warning(warn_state);    % return warnings to initial state
    catch
        warning(warn_state);    % return warnings to initial state
        rethrow(lasterror)
    end
    is_mat_file=true;
catch
    data=[];
    det=[];
    is_mat_file=false;
    return
end

% Check minimum number of fields
if ~(isfield(data_in,'qx') && isfield(data_in,'qy') && isfield(data_in,'qz') && isfield(data_in,'S'))
    error('File does not contain one or more variables ''qx'', ''qy'', ''qz'', ''S''');
else
    nd=numel(data_in.qx);
    if nd<1 || numel(data_in.qy)~=nd || numel(data_in.qz)~=nd || numel(data_in.S)~=nd
        error('Check that the arrays ''qx'', ''qy'', ''qz'', ''S'' all contain the same number of elements');
    end
end

if isfield(data_in,'eps')
    if numel(data_in.eps)==nd
        data.qspec=[data_in.qz(:)';data_in.qx(:)';data_in.qy(:)';data_in.eps(:)'];
        mess='qx-qy-qz-eps';
    else
        error('Check that the array ''eps'' has the same number of elements as the signal array');
    end
else
    % Horace doesn't seem to like all energy values the same
    eps=1e-4*(2*(rand([1,nd])-0.5));
    data.qspec=[data_in.qz(:)';data_in.qx(:)';data_in.qy(:)';eps];
    mess='qx-qy-qz';
end

data.S=data_in.S(:)';
if isfield(data_in,'ERR')
    data.ERR=data_in.ERR(:)';
    mess=[mess,'-S-ERR data read from: ' datafile];
else
    data.ERR=zeros(size(data.S));
    mess=[mess,'-S data read from: ' datafile];
end

data.en=[min(data.qspec(4,:));max(data.qspec(4,:))];

% Filter out NaN and Inf data
ok=isfinite(data.S)&isfinite(data.ERR);
n_ok=sum(ok);
data.qspec=data.qspec(repmat(ok,4,1));
data.qspec=reshape(data.qspec,4,n_ok);
data.S=data.S(ok);
data.ERR=data.ERR(ok);

% Write succesful data read message
disp(mess)


% Create fake detector information
% ---------------------------------
% Needs to be a single detector for the rest of the code to work
det.filename='';
det.filepath='';
det.group=1;
det.x2=0;
det.phi=0;
det.azim=0;
det.width=0;
det.height=0;
