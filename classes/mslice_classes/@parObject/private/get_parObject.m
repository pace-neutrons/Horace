function [par,ok,mess]=get_parObject(filename)
% Read an ASCII .par file
%
%   >> [par,ok,mess]=get_parObject(filename)
%
% Input:
% ------
%   filename        Name of file from which to read .par format data
%
% Output:
% -------
%   par             Structure with the fields described below
%   ok              =true if all OK; =false otherwise
%   mess            ='' if OK==true error message if OK==false
%
% The field of the returned structure are:
%
%   par.filename    Name of file excluding path
%   par.filepath    Path to file including terminating file separator
%   par.group       Row vector of detector group number - assumed to be 1:ndet
%   par.x2          Secondary flightpath (m) (must be all greater than zero)
%   par.phi         Row vector of scattering angles (deg)
%   par.azim        Row vector of azimuthal angles (deg)
%                       (West bank=0 deg, North bank=90 deg etc.)
%   par.width       Row vector of detector widths (m) (all >=0)
%   par.height      Row vector of detector heights (m) (all >=0)
%
%
% The format of a .par file is
%   - a line with the number of detectors, ndet
%   - five or six columns:
%       1st column    sample-detector distance
%       2nd  "        scattering angle (deg)
%       3rd  "        azimuthal angle (deg)
%                    (west bank = 0 deg, north bank = -90 deg etc.)
%                    (Note the reversed sign convention cf .phx files)
%       4th  "        width (m)
%       5th  "        height (m)
%       6th  "       [Optional] detector group number
%                    If the detector group is not given, or they are all the
%                    same, they will be returned as 1,2,...ndet
%
% The sign of the azimuthal angle as contained in the file is reversed
% before it is placed in the corresponding field in the structure.

ok=true;
mess='';

% Remove blanks from beginning and end of filename
file_tmp=strtrim(filename);

% Read file (use matlab, as files are generally small, so Fortran or C++ code not really necessary)
try
    % Open file for reading
    fid=fopen(file_tmp,'rt');
    if fid==-1
        par=[];
        ok=false;
        mess=['Error opening file ' file_tmp ];
        return
    end
    [fpath,fname]=fileparts(fopen(fid));
    % Get number of detectors
    ndet=fscanf(fid,'%d\n',1);
    disp(['Loading .par file with ' num2str(ndet) ' detectors : ' file_tmp]);
    if ndet<0
        fclose(fid);
        par=[];
        ok=false;
        mess='Number of detectors in a .par file must be greater than zero';
        return
    end
    % Get number of columns
    temp=fgetl(fid);
    arr=sscanf(temp,'%f');
    ncols=numel(arr);     % number of columns 5 or 6
    if ncols<5 || ncols>6
        fclose(fid);
        par=[];
        ok=false;
        mess='Number of columns in a .par file must be 5 or 6';
        return
    end
    % Read the rest of the par file
    arr=[arr;fscanf(fid,'%f')];
    fclose(fid);
    if numel(arr)~=ndet*ncols
        par=[];
        ok=false;
        mess=['File determined to have ',num2str(ndet),' detectors in ',num2str(ncols),' column format, but contents are inconsistent with a .par file'];
        return
    end
    arr=reshape(arr,[ncols,ndet]);
    % Fill output object
    par.filename=fname;
    if ~isempty(fpath)
        par.filepath=[fpath,filesep];
    else
        par.filepath=fpath;
    end
    if ncols==5
        par.group=1:ndet;
        par.x2=arr(1,:);
        par.phi=arr(2,:);
        par.azim=-arr(3,:);     % note: sign change from file contents
        par.width=arr(4,:);
        par.height=arr(5,:);
    else
        group=unique(round(arr(6,:)));
        if numel(group)==1      % all group numbers were the same (when rounded to the nearest integer)
            group=1:ndet;
        elseif numel(group)==ndet && min(group)>0
            group=arr(6,:);
        else
            par=[];
            ok=false;
            mess='The detector group numbers must be unique integers >= 1, or all the same (when they will be set to 1:ndet';
            return
        end
        par.group=group;
        par.x2=arr(1,:);
        par.phi=arr(2,:);
        par.azim=-arr(3,:);     % note: sign change from file contents
        par.width=arr(4,:);
        par.height=arr(5,:);
    end

catch
    if exist('fid','var') && fid>0 && ~isempty(fopen(fid))  % close file, if open
        fclose(fid);
    end
    par=[];
    ok=false;
    mess='Unable to read .par data from file.';
    return
end
