function [phx,ok,mess]=get_phxObject(filename)
% Read an ASCII .phx file
%
%   >> [phx,ok,mess]=get_phxObject(filename)
%
% Input:
% ------
%   filename        Name of file from which to read .phx data
%
% Output:
% -------
%   phx             Structure with the fields described below
%   ok              =true if all OK; =false otherwise
%   mess            ='' if OK==true error message if OK==false
%
% The field of the returned structure are:
%
%   phx.filename    Name of file excluding path
%   phx.filepath    Path to file including terminating file separator
%   phx.group       Row vector of detector group number - assumed to be 1:ndet
%   phx.x2          Secondary flightpath (m) (must be all greater than zero)
%   phx.phi         Row vector of scattering angles (deg)
%   phx.azim        Row vector of azimuthal angles (deg)
%                       (West bank=0 deg, North bank=90 deg etc.)
%   phx.dphi        Row vector of angular widths (deg)
%   phx.danght      Row vector of angular heights (deg)
%
%
% The format of a .phx file is
%   - a line with the number of detectors, ndet
%   - seven columns:
%       1st column    Dummy value
%       2nd  "        Dummy value
%       3rd  "        scattering angle (deg)
%       4th  "        azimuthal angle (deg)
%                    (west bank = 0 deg, north bank = 90 deg etc.)
%       5th  "        angular width (deg)
%       6th  "        angular height (deg)
%       7th  "        detector group number
%                    If the detector group numbers are all the same, they will
%                    be returned as 1,2,...ndet

ok=true;
mess='';

% Remove blanks from beginning and end of filename
file_tmp=strtrim(filename);

% Read file (use matlab, as files are generally small, so Fortran or C++ code not really necessary)
try
    % Open file for reading
    fid=fopen(file_tmp,'rt');
    if fid==-1
        phx=[];
        ok=false;
        mess=['Error opening file ' file_tmp ];
        return
    end
    [fpath,fname]=fileparts(fopen(fid));
    % Get number of detectors
    ndet=fscanf(fid,'%d\n',1);
    disp(['Loading .phx file with ' num2str(ndet) ' detectors : ' file_tmp]);
    if ndet<0
        fclose(fid);
        phx=[];
        ok=false;
        mess='Number of detectors in a .phx file must be greater than zero';
        return
    end
    % Read the the phx file
    arr=fscanf(fid,'%f');
    fclose(fid);
    if numel(arr)~=ndet*7
        phx=[];
        ok=false;
        mess=['File determined to have ',num2str(ndet),' detectors, but contents are inconsistent with a .phx file'];
        return
    end
    arr=reshape(arr,[7,ndet]);
    % Fill output object
    phx.filename=fname;
    if ~isempty(fpath)
        phx.filepath=[fpath,filesep];
    else
        phx.filepath=fpath;
    end
    group=unique(round(arr(7,:)));
    if numel(group)==1      % all group numbers were the same (when rounded to the nearest integer)
        group=1:ndet;
    elseif numel(group)==ndet && min(group)>0
        group=arr(7,:);
    else
        phx=[];
        ok=false;
        mess='The detector group numbers must be unique integers >= 1, or all the same (when they will be set to 1:ndet';
        return
    end
    phx.group=group;
    phx.phi=arr(3,:);
    phx.azim=arr(4,:);
    phx.dphi=arr(5,:);
    phx.danght=arr(6,:);
    
catch
    if exist('fid','var') && fid>0 && ~isempty(fopen(fid)) % close file, if open
        fclose(fid);
    end
    phx=[];
    ok=false;
    mess='Unable to read .phx data from file.';
    return
end
