function val = mean (obj, varargin)
% Calculate the mean of shaping and monochromating chopper pulses
%
%   >> val = mean (obj)
%
% Controlling contributions of instrument components
%   >> val = mean (obj,'mc',mc_val)
%
% The average time of the pulse at the shaping chopper position and the Fermi
% chopper will in general be non-zero, as will the covariance matrix.
%
% Input:
% ------
%   obj        IX_mod_shape_mono object
%
% Optionally:
%   mc_val      Logical row vector [moderator, shape_chopper, mono_chopper]
%              which shows which components contribute to the pulse shape.
%               - If only one of moderator and shape_chopper is true,
%                 then the other is treated as having no effect i.e. it is
%                 infinitely wide.
%               - If both are turned off means a delta function in time.
%               Default: [1,1,1] i.e. all are contributing
%
% Output:
% -------
%   val         Mean times of pulses at shaping and monochromating
%              chopper positions (microseconds) [column vector]


% Parse input
if numel(varargin)==0
    mc = [1,1,1];
elseif numel(varargin)==2 && is_string(varargin{1}) &&...
        strncmpi(varargin{1},'mc',numel(varargin{1})) &&...
        numel(varargin{2})==3 && islognum(varargin{2})
    mc = logical(varargin{2}(:)');
else
    error('Check input')
end

% Retrive covariance
ind = sum([4,2,1].*mc) +1;
val = obj.t_chop_av_(:,ind);
