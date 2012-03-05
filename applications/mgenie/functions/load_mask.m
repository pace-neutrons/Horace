function ind = load_mask (file)
% Reads the list of spectra in a mask file into a 1D array.
%
%   >> arr = load_mask           % prompts for file
%   >> arr = load_mask (file)    % read from named file


% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if ~exist('file','var'), file='*.msk'; end
[file_internal,ok,mess]=getfilecheck(file);
if ~ok, error(mess), end

% Open file
% ---------
fid=fopen(file_internal,'rt');
if fid<0
    error(['Cannot open mask file ',file_internal])
end

% Read data from file
% ---------------------
% skip over lines that begin with '!'
ind = [];
while 1
    istring = fgetl(fid);
    if (~ischar(istring)), break, end
    if (~isempty(istring) && ~strcmp(istring(1:1),'!'))
        ind = [ind, str_to_iarray(istring)];
    end
end
fclose (fid);

% Sort list of masked spectra
% ---------------------------
if (isempty(ind))
    error (['No data read from file ' file_internal])
end

ind = sort(ind);
ind=ind(find([1,ind(2:end)-ind(1:end-1)])); % remove double counts

disp (['Data read from ' file_internal])
