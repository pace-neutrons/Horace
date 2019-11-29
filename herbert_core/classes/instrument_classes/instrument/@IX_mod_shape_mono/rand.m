function X = rand (obj, varargin)
% Generate random times at the shaping and monochromating choppers
%
%   >> X = rand (obj)               % generate a single random number
%   >> X = rand (obj, n)            % n x n matrix of random numbers
%   >> X = rand (obj, sz)           % array of size sz
%   >> X = rand (obj, sz1, sz2,...) % array of size [sz1,sz2,...]
%
% Optionally:
%   >> X = rand (...,'mc',mc_val)   % exclude one or more components
%
% Input:
% ------
%   obj         IX_mod_shape_mono object
%
% Optionally:
%   n           Return square array of random numbers with size n x n
%      *OR*
%   sz          Size of array of output array of random numbers
%      *OR*
%   sz1,sz2...  Extent along each dimension of random number array
%
%   mc_val      Logical row vector [moderator, shape_chopper, mono_chopper]
%              which shows which components contribute to the pulse shape.
%               - If only one of moderator and shape_chopper is true,
%                 then the other is treated as having no effect i.e. it is
%                 infinitely wide.
%               - If both are turned off means a delta function in time.
%
% Output:
% -------
%   X           Array of random time deviations at the shaping chopper and
%              the Fermi chopper (microseconds).
%               The array has size [2, sz], with a leading singleton in sz
%              squeezed away. e.g. if sz=[1,5] then size(X)=[2,5], and if
%              sz=[1,1,5] then size(X)=[2,1,5]
%
% Note that in general the deviations in times at thee shaping and
% monochromating choppers are correlated.


if ~isscalar(obj), error('Method only takes a scalar moderator-shaping-monochromatic chopper object'), end

if numel(varargin)>=2 && is_string(varargin{end-1})
    if strncmpi(varargin{end-1},'mc',numel(varargin{end-1}))
        mc = logical(varargin{end}(:)');
        args = varargin(1:end-2);
    else
        error('Check optional input arguments')
    end
else
    mc = [true, true, true];
    args = varargin;
end
mc_moderator = mc(1);
mc_shape_chopper = mc(2);
mc_mono_chopper = mc(3);

% Pick out constituent instrument components and quantities
moderator = obj.moderator_;
shaping_chopper = obj.shaping_chopper_;
mono_chopper = obj.mono_chopper_;
t_m_offset = obj.t_mod_offset(mc);

x1 = mono_chopper.distance;
x0 = moderator.distance - x1;       % distance from mono chopper to moderator face
xa = shaping_chopper.distance - x1; % distance from shaping chopper to mono chopper

% Monochromating chopper pulse
if mc_mono_chopper
    t_ch = mono_chopper.rand(args{:});
else
    t_ch = zeros(args{:});
end

% Moderator and shaping chopper
if mc_moderator || mc_shape_chopper
    if ~mc_shape_chopper
        % Deviations determined solely by moderator
        t_sh = mod_pulse (x0, xa, t_m_offset, t_ch, moderator);
        
    elseif ~mc_moderator
        % Deviations determined soley by pulse shaping chopper
        t_sh = chop_pulse (x0, xa, t_m_offset, t_ch, shaping_chopper);
        
    else
        % Moderator and chopper both determine the deviations
        if obj.shaped_mod
            t_sh = chop_pulse (x0, xa, t_m_offset, t_ch(:), shaping_chopper, moderator);
        else
            t_sh = mod_pulse (x0, xa, t_m_offset, t_ch(:), moderator, shaping_chopper);
        end
    end
else
    % All deviations set to zero
    t_sh = zeros(size(t_ch));
end

X = reshape([t_sh(:)';t_ch(:)'], size_array_stack([2,1], size(t_ch)));


%--------------------------------------------------------------------------------------------------
function t_sh = mod_pulse (x0, xa, t_m_offset, t_ch, moderator, shaping_chopper)
% Return time deviations at pulse shaping chopper position when the pulse shape
% is primarily determined by the moderator pulse shape (i.e. the shaping chopper
% pulse width is larger than the fwhh of the moderator)
%
% No shaping by pulse shaping chopper:
%   >> t_sh = mod_pulse (x0, xa, t_m_offset, t_ch, moderator)
%
% Shaping by pulse shaping chopper:
%   >> t_sh = mod_pulse (..., shaping_chopper)


% Assume moderator pulse is the primary determinant
t_m = moderator.rand(size(t_ch)) - t_m_offset;    % times wrt t_m_offset

% Get the time deviation at the shaping chopper
t_sh = (xa*t_m + (x0-xa)*t_ch)/x0;

% If necessary, account for shaping chopper using a rejection method
shaped = (nargin>5);
if shaped
    %disp(['mod_pulse; ',num2str(numel(t_sh))])
    bad = ~shaping_chopper.retain(t_sh);
    % Iteratively replace any rejected points
    if any(bad)
        t_sh(bad) = mod_pulse (x0, xa, t_m_offset, t_ch(bad),...
            moderator, shaping_chopper);
    end
end


%--------------------------------------------------------------------------------------------------
function t_sh = chop_pulse (x0, xa, t_m_offset, t_ch, shaping_chopper, moderator)
% Return time deviations at pulse shaping chopper position when the pulse shape
% is primarily determined by the shaping chopper (i.e. the moderator pulse width
% is larger than that of the shaping chopper pulse)
%
% No shaping by moderator:
%   >> t_sh = chop_pulse (x0, xa, t_m_offset, t_ch, shaping_chopper)
%
% Shaping by pulse moderator:
%   >> t_sh = chop_pulse (..., moderator)


% Assume shaping chopper is the dominant determinant of the pulse
t_sh = shaping_chopper.rand(size(t_ch));

% If necessary, account for shaping chopper using a rejection method
shaped = (nargin>5);
if shaped
    %disp(['chop_pulse; ',num2str(numel(t_sh))])
    t_m = (x0*t_sh - (x0-xa)*t_ch)/xa;   % get the time deviation at the moderator
    t_m = t_m + t_m_offset;   % must add offset time to get to origin of moderator pulse
    
    bad = ~moderator.retain(t_m);
    % Iteratively replace any rejected points
    if any(bad)
        t_sh(bad) = chop_pulse (x0, xa, t_m_offset, t_ch(bad),...
            shaping_chopper, moderator);
    end
end
