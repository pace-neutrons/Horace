function [t,en,intensity] = moderator_read (file)
% Return time bin boundaries, energy bin boundaries, and intensity
%
%   >> [t,en,intensity] = moderator_read (file)
%
% Input:
% ------
%   file        McStas moderator file
%
% Output:
% -------
%   t           Time bin boundaries (microseconds)
%   en          Energy bin boundaries (meV)
%   intensity   Intensity per microsecond per meV


fid = fopen(file,'r');
finishup = onCleanup(@() myCleanupFun(fid));

% Strip away lines until read find one beginning 'user bin total'
% The following line should be the energy bin line
header = true;
while header
    line = fgets(fid);
    if numel(line)>=14
        header = ~strcmpi(line(1:14),'user bin total');
    end
end

% Read in every energy block in the file
% Read in first energy block and initialise arrays
[elo,ehi,t,intensity_tmp,end_of_data] = read_energy_block (fid);
nebin = 1;

nebin_max_init = 30;
ntbin = numel(t)-1;
en = zeros(nebin_max_init+1,1);
en(1) = elo;
en(2) = ehi;
intensity = zeros(ntbin,nebin_max_init);
intensity(:,1) = intensity_tmp;

while ~end_of_data
    [elo,ehi,t_tmp,intensity_tmp,end_of_data] = read_energy_block (fid);
    nebin = nebin + 1;
    
    % Sanity checks
    if numel(intensity_tmp)~=ntbin
        error('The number of time bins is not the same for all energy blocks')
    end
    if ~all(t==t_tmp)
        error('The time bins are not the same for all energy blocks')
    end
    if elo~=en(nebin)
        error('The energy bin boundaries are not contiguous')
    end
    
    % Expand arrays if necessary to accommodate more energy blocks
    if nebin>size(intensity,2)
        en = [en; zeros(nebin_max_init,1)];
        intensity = [intensity, zeros(ntbin,nebin_max_init)];
    end
    
    % Accumulate data, and slice arrays if reached the end of the data
    en(nebin+1) = ehi;
    intensity(:,nebin) = intensity_tmp;
    if end_of_data
        en = en(1:nebin+1);
        intensity = intensity(:,1:nebin);
    end
end


%------------------------------------------------------------------------------
function [elo,ehi,t,intensity,end_of_data] = read_energy_block (fid)
% Read in block for a given energy bin, leaving at the line beginning 'energy'
% for the next block

% Energy bin: (in MeV)
line = fgets(fid);
en = sscanf(line,'%*s %*s %f %*s %f');
en = en*1e9;    % convert to meV
elo = en(1);
ehi = en(2);
de = ehi-elo;

% Time (units of 10 ns) and total intensity in time bins
C = textscan(fid,'%f %f %*s','HeaderLines',2);
t = C{1}/100;   % to convert to microseconds
dt = diff(t);

% Convert intensity to a distribution
intensity = C{2}(1:end-1) ./ dt;    % convert to intensity per microsecond
intensity = intensity / de;         % convert to intensity per meV

% Get to start of next block
line = fgets(fid);  % starts with '  total'
line = fgets(fid);  % starts with ' surface' or '1end'
if strcmpi(line(1:4),'1end')
    end_of_data = true;
else
    line = fgets(fid);  % starts with 'segment'
    line = fgets(fid);  % starts with 'user'
    end_of_data = false;
end


%------------------------------------------------------------------------------
function myCleanupFun(fid)
% If a file with identifier fid is open, then close it
if ~isempty(fopen(fid))
    fclose(fid);
end
