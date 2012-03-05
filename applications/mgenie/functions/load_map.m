function [map,wkno] = load_map (file)
% Reads the list of spectra in a map file into a cell array of 1D arrays. Old or new format files.
%
%   >> [map,wkno] = load_map           % prompts for file
%   >> [map,wkno] = load_map (file)    % read from named file
%
% Each array contains the spectra for that workspace. For example, if the examples below
% are used to load a map file into the cell array, map:
%
%   map{1}  array of spectra in workspace 1
%   map{2}  array of spectra in workspace 2
%    :                    :
%
%   wkno    array of workspace numbers (1:numel(map) if old format map file)


% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if ~exist('file','var'), file='*.map'; end
[file_internal,ok,mess]=getfilecheck(file);
if ~ok, error(mess), end

% Open file
% ---------
fid=fopen(file_internal,'rt');
if fid<0
    error(['Cannot open map file ',file_internal])
end

% Read data from file
% ---------------------
% Have a try...catch block so that wherever the failure takes place, the file can always be closed and the error thrown
try
    % skip over lines that begin with '!'
    first_line = 1;
    nw = 0;
    iw = 1;
    ns = 0;
    while 1
        istring = fgetl(fid);
        if ~ischar(istring)
            if nw < 1 || iw<= nw
                error ('Check format of .map file')
            else
                break   % have reached end of the file
            end
        end
        if ~isempty(istring) && ~strcmp(istring(1:1),'!')
            if first_line==1 % first line to be read
                first_line = 0;
                nw = str_to_iarray(istring);
                if length(nw)~=1
                    error ('Check format of map file')
                elseif nw < 1
                    error ('Check number of workspaces declared in first non-comment line')
                else
                    map = cell(1,nw);
                end
                wkno=zeros(1,nw);   % to hold workspace number
            else
                if ns==0   % Not read the number of spectra yet
                    if iw > nw
                        error ('Check format of .map file: excess uncommented information at bottom of file')
                    end
                    % if first workspace, determine format of map file
                    [wdata,count] = sscanf(istring,'%d %g %g %g',4);
                    if iw==1 && wkno(iw)==0  % first line for first workspace
                        if count==1
                            vms_format=false;
                        elseif count==4
                            vms_format=true;
                        else
                            error('Check format of .map file')
                        end
                    end
                    % Get workspace number (if not VMS format) and number of spectra
                    if ~isempty(wdata)   % header line for workspace
                        if ~vms_format
                            if wkno(iw)==0  % haven't read workspace number yet
                                if wdata(1)<0
                                    error('Workspace number must be greater or equal to 1')
                                end
                                wkno(iw)=wdata(1);
                            else
                                if wdata(1)<=0
                                    error (['Check number of spectra declared for workspace ',num2str(wkno(iw))])
                                end
                                ns = wdata(1);
                            end
                        else
                            wkno(iw)=iw;    % just 1,2,...nw
                            if wdata(1)<=0
                                error (['Check number of spectra declared for workspace ',num2str(wkno(iw))])
                            end
                            ns = wdata(1);
                        end
                    else
                        error (['Check format of map file at workspace entry number ',num2str(iw)])
                    end
                else
                    map{iw} = [map{iw}, str_to_iarray(istring)];
                    if length(map{iw})==ns
                        map{iw}=sort(map{iw});
                        if round(min(diff(map{iw}))) == 0
                            error (['One or more spectra are repeated in mapping for workspace ',num2str(iw)])
                        else
                            map{iw}=round(map{iw});
                        end
                        iw = iw + 1;
                        ns = 0;
                    elseif length(map{iw})>ns
                        error (['Check number of spectra declared for workspace ',num2str(wkno(iw))])
                    end
                end
            end
        end
    end
    fclose (fid);
    
catch
    fclose(fid);
    rethrow(lasterror)
end
