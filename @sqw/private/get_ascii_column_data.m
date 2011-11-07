function [data,det] = get_ascii_column_data (datafile)
% Get data from ascii file with column data qx-qy-qz-eps-signal-error
%
%   >> data = get_diffraction_ascii_column_data (datafile)
%
%   datafile    Full file name of ascii data file
%               Format is one of the following column arrangements:
%                   qx  qy  qz  S
%                   qx  qy  qz  eps  S
%                   qx  qy  qz  eps  S  ERR
%
%               where qx,qy,qz are the components of momentum in
%              spectrometer coordinates (qx||ki, qz up; x,y,z orthonormal
%              with units Ang^-1), and error is standard deviation.
%
%   data        Data structure with following fields:
%                   data.filename   Name of file excluding path
%                   data.filepath   Path to file including terminating file separator
%                   data.qspec      [4 x n] array of qx,qy,qz,eps of all the data points
%                   data.S          [1 x n] array of signal values
%                   data.ERR        [1 x n] array of error values (st. dev.)
%                   data.en         Column vector length 2 of min and max eps in the ascii file
%   det         Data structure containing fake detector parameters for unmasked
%              detectors (see get_par for fields)
%
%   keep        
%
%   det0        Data structure containing fake detector parameters for a single
%              detector (see get_par for fields).
%

%   data            Data structure containing data for unmasked detectors
%                  (see get_spe for list of fields)
%   det             Data structure containing detector parameters for unmasked
%                  detectors (see get_par for fields)
%   keep            List of the detector groups that were unmasked
%   det0            Data structure of detector parameters before masking

% Read data from file
% ---------------------
fid = fopen(datafile);

% Get file name and path (incl. final separator)
[path,name,ext]=fileparts(datafile);
data.filename=[name,ext];
data.filepath=[path,filesep];

% Skip over lines that do not consist solely of two or three numbers
data_found = 0;
while ~ data_found
    istart = ftell(fid);
    if (istart<0)
        fclose(fid);
        error (['No data with valid format encountered in ' file_internal])
    end
    tline = fgets(fid);
    temp = str2num(tline);
    if (length(temp)==6)        % x-y-z-e-sig-err data
        data_found = 1;
        eps = 1;
        xye = 1;
    elseif (length(temp)==5)    % x-y-z-e-sig data only (no error bars)
        data_found = 1;
        eps = 1;
        xye = 0;
    elseif (length(temp)==4)    % x-y-z-sig data only (no energy or error bars)
        data_found = 1;
        eps = 0;
        xye = 0;
    end
end
fstatus=fseek(fid,istart,'bof'); % step back one line
if (fstatus~=0)
    fclose(fid);
    error (['Error reading from file ' file_internal])
end
% read array to the end, or until unable to read from file with specified format
if xye && eps
    a = fscanf(fid,'%g %g %g %g %g %g',[6,inf]);
elseif eps
    a = fscanf(fid,'%g %g %g %g %g',[5,inf]);
else
    a = fscanf(fid,'%g %g %g %g',[4,inf]);
end
if (isempty(a))
    fclose(fid);
    error (['No qx-qy-qz-eps-S-ERR data encountered in ' file_internal])
end
fclose(fid);

if xye && eps
    data.qspec=a(1:4,:);
    data.S=a(5,:);
    data.ERR=a(6,:);
elseif eps
    data.qspec=a(1:4,:);
    data.S=a(5,:);
    data.ERR=zeros(1,size(a,2));
else
    % Horace doesn't seem like all values the same: data.qspec=[a(1:3,:);zeros(1,size(a,2))];
    eps=1e-4*(2*(rand([1,size(a,2)])-0.5));
    data.qspec=[a(1:3,:);eps];
    data.S=a(4,:);
    data.ERR=zeros(1,size(a,2));
end
data.en=[min(data.qspec(4,:));max(data.qspec(4,:))];

% Write succesful data read message
disp (['Data read from ' datafile])


% Create fake detector information
% ---------------------------------
% Needs to be a single detector to the rest of the code to work
det.filename='';
det.filepath='';
det.x2=0;
det.group=1;
det.phi=0;
det.azim=0;
det.width=0;
det.height=0;
