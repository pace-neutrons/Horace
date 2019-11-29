function modStruct = ISIS_Baseline2016_moderator_load (file, nsmooth)
% Load previously prepared moderator .mat file created from mcstas files
%
%   >> S = ISIS_Baseline2016_moderator_load (file)
%
% Input:
% ------
%   file        Moderator file (.mat file)
%
%   nsmooth     Smoothing
%                   n       box averaging by square array size [n,n]
%                   [m,n]   box averaging by square array size [m,n]
%
% Output:
% -------
%   modStruct   Structure with the following fields
%                   t           Time bin boundaries (microseconds)
%                   en          Energy bin boundaries (meV)
%                   intensity   Intensity per microsecond per meV
%                   tcent       Time bin centres
%                   encent      Energy bin centres
%
% The bin centres are calculated from the centre of the logarithm of the
% boundaries. The reason is because the bin boundaries are logarithmically
% spaced.


if isempty(fileparts(file))
    p = fileparts(mfilename('fullpath'));
    if exist(fullfile(p,'ISIS_TS1',file),'file')==2
        modStruct = load(fullfile(p,'ISIS_TS1',file));
    elseif exist(fullfile(p,'ISIS_TS2',file),'file')==2
        modStruct = load(fullfile(p,'ISIS_TS2',file));
    else
        error('Moderator not found. Check file name, and ensure there is no path.');
    end
else
    error('Moderator not found. Check file name, and ensure there is no path.');
end

if nargin==2
    if numel(nsmooth)==1 || numel(nsmooth)==2
        box = ones(nsmooth);
        box = box/sum(box(:));
    else
        error('Check smoothing')
    end
    modStruct.intensity = convn(modStruct.intensity, box, 'same');
end

t = modStruct.t;
en = modStruct.en;

t_log = log(t(:));
tcent_log = 0.5*(t_log(2:end)+t_log(1:end-1));

en_log = log(en(:));
en_log(1) = log(1e-12);     % en(1)=0, so must make finite for the interpolation
encent_log = 0.5*(en_log(2:end)+en_log(1:end-1));

modStruct.tcent = exp(tcent_log);
modStruct.encent = exp(encent_log);
