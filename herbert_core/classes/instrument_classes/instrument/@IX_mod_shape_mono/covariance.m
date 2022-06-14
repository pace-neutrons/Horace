function val = covariance (obj, varargin)
% Calculate the covariance of shaping and monochromating chopper pulses
%
%   >> val = covariance (obj)
%
% Controlling contributions of instrument components
%   >> val = covariance (obj,mc_val)
%
% The average time of the pulse at the shaping chopper position and the Fermi
% chopper will in general be non-zero, as will the covariance matrix.
%
% Input:
% ------
%   obj         IX_mod_shape_mono object
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
%   val         Covariance matrix of times at shaping and monochromating
%              choppers [var_sh_sh, var_sh_mo; var_sh_mo, var_mo_mo]
%              (microseconds^2)


% Parse input
if numel(varargin)==0
    mc = [1,1,1];
elseif numel(varargin)==1 && numel(varargin{1})==3 && islognum(varargin{1})
    mc = logical(varargin{1}(:)');
else
    error('Check input')
end

% Retrive covariance
ind = sum([4,2,1].*mc) +1;
val = obj.t_chop_cov_(:,:,ind);
