function [data,det] = qspec2sqw_get_ascii_column_data (datafile)
% Get data from ascii file with column data qx-qy-qz-eps-signal-error
%
%   >> data = get_ascii_column_data (datafile)
%
% Input:
% ------
%   datafile    Full file name of ascii data file
%               Format is one of the following column arrangements:
%                   qx  qy  qz  S
%                   qx  qy  qz  S  ERR
%                   qx  qy  qz  eps  S  ERR
%
%               Here qz is the component of momentum along ki (Ang^-1)
%                   qy  is component vertically upwards (Ang^-1)
%                   qx  defines a hight-hand coordinate frame with qy' and qz'
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

% Read data from file
% ---------------------
fid = fopen(datafile);

% Get file name and path (incl. final separator)
[path,name,ext]=fileparts(datafile);
data.filename=[name,ext];
data.filepath=[path,filesep];

% Skip over lines that do not consist solely of two or three numbers
data_found = 0;
while ~data_found
    istart = ftell(fid);
    if (istart<0)
        fclose(fid);
        error (['No data with valid format encountered in ' file_internal])
    end
    tline = fgets(fid);
    temp = str2num(tline);
    % Determine number of columns
    if (length(temp)==6)        % x-y-z-e-sig-err data
        ncol=6;
        data_found = 1;
        eps = 1;
        xye = 1;
    elseif (length(temp)==5)    % x-y-z-sig-err data 
        ncol=5;
        data_found = 1;
        eps = 0;
        xye = 1;
    elseif (length(temp)==4)    % x-y-z-sig data only (no energy or error bars)
        ncol=4;
        data_found = 1;
        eps = 0;
        xye = 0;
    end
end
% Determine if comma separated or not
fmt=[repmat('%g , ',[1,ncol-1]),'%g'];   % needs the spaces around the commas!
temp2=sscanf(tline,fmt,[ncol,inf]);
if ~(numel(temp2)==ncol)
    fmt=[repmat('%g ',[1,ncol-1]),'%g'];
    temp2=sscanf(tline,fmt,[ncol,inf]);
    if ~(numel(temp2)==ncol)
        fclose(fid);
        error('Unrecognised format for data')
    end
end

% Read data
fstatus=fseek(fid,istart,'bof'); % step back one line
if (fstatus~=0)
    fclose(fid);
    error (['Error reading from file ' file_internal])
end
% Read array to the end, or until unable to read from file with specified format
a = fscanf(fid,fmt,[ncol,inf]);

if (isempty(a))
    fclose(fid);
    error (['Check format of data in ' file_internal])
end
fclose(fid);

% Interpret cases of different numbers of columns
if eps
    data.qspec=a(1:4,:);
    data.S=a(5,:);
    if xye
        data.ERR=a(6,:);
    else
        data.ERR=zeros(1,size(a,2));
    end
elseif ~eps
    % Horace doesn't seem to like all values the same: data.qspec=[a(1:3,:);zeros(1,size(a,2))];
    eps=1e-4*(2*(rand([1,size(a,2)])-0.5));
    data.qspec=[a(1:3,:);eps];
    data.S=a(4,:);
    if xye
        data.ERR=a(5,:);
    else
        data.ERR=zeros(1,size(a,2));
    end
end
data.qspec=data.qspec([3,1,2,4],:);     % transform from spherical polar to spectrometer coordinates
data.en=[min(data.qspec(4,:));max(data.qspec(4,:))];

% Filter out NaN and Inf data
ok=isfinite(data.S)&isfinite(data.ERR);
n_ok=sum(ok);
data.qspec=data.qspec(repmat(ok,4,1));
data.qspec=reshape(data.qspec,4,n_ok);
data.S=data.S(ok);
data.ERR=data.ERR(ok);

% Write succesful data read message
disp (['qx-qy-qz-eps data read from: ' datafile])


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
