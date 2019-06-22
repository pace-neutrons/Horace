function X = rand (self, varargin)
% Generate random numbers from the Fermi chopper pulse shape
%
%   >> X = rand (obj)               % generate a single random number
%   >> X = rand (obj, n)            % n x n matrix of random numbers
%   >> X = rand (obj, sz)           % array of size sz
%   >> X = rand (obj, sz1, sz2,...) % array of size [sz1,sz2,...]
%
% Optionally:
%   >> X = rand (obj, mc, ...)      % exclude one or more components
%
% Input:
% ------
%   mc          Structure with which components contribute to the pulse
%               shape. Each field is true or false:
%                   - mc.moderator
%                   - mc.shape_chopper
%                   - mc.mono_chopper
%               If only one of mc_moderator and mc_shape_chopper is true,
%              then the other is treated as having no effect i.e. it is
%              infinitely wide. Only if both are turned off then do we
%              have a delta function in time.
%
%   n           Return square array of random numbers with size n x n
%      *OR*
%   sz          Size of array of output array of random numbers
%      *OR*
%   sz1,sz2...  Extent along each dimension of random number array
%
% Output:
% -------
%   X           Array of random time deviations at shaping chopper (microseconds)
%
%   t_ch        Array of random time deviations at monochromating chopper (microseconds)
%
% Note that t_sh and t_ch are correlated; it is as pairs that they 


if ~isscalar(self), error('Method only takes a scalar moderator-shaping-monochromatic chopper object'), end

if nargin>=2 && islognum(varargin{1}) && numel(varargin{1})==3
    mc = logical(varargin{1}(:)');
    mc_moderator = mc(1);
    mc_shape_chopper = mc(2);
    mc_mono_chopper = mc(3);
    args = varargin(2:end);
else
    mc_moderator = true;
    mc_shape_chopper = true;
    mc_mono_chopper = true;
    args = varargin;
end

% if nargin>=2 && isstruct(varargin{1})
%     mc = varargin{1};
%     mc_moderator = mc.moderator;
%     mc_shape_chopper = mc.shape_chopper;
%     mc_mono_chopper = mc.mono_chopper;
%     args = varargin(2:end);
% else
%     mc_moderator = true;
%     mc_shape_chopper = true;
%     mc_mono_chopper = true;
%     args = varargin;
% end

% Pick out constituent instrument components and quantities
moderator = self.moderator_;
shaping_chopper = self.shaping_chopper_;
mono_chopper = self.mono_chopper_;

[~,t_m_av] = moderator.pulse_width();
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
        t_sh = mod_pulse (x0, xa, t_m_av, t_ch, moderator);
        
    elseif ~mc_moderator
        % Deviations determined soley by pulse shaping chopper
        t_sh = chop_pulse (x0, xa, t_m_av, t_ch, shaping_chopper);
        
    else
        % Moderator and chopper both determine the deviations
        if self.shaped_mod
            t_sh = chop_pulse (x0, xa, t_m_av, t_ch(:), shaping_chopper, moderator);
        else
            t_sh = mod_pulse (x0, xa, t_m_av, t_ch(:), moderator, shaping_chopper);
        end
    end
else
    % All deviations set to zero
    t_sh = zeros(size(t_ch));
end

X = reshape([t_sh(:)';t_ch(:)'], size_array_stack([2,1], size(t_ch)));


%--------------------------------------------------------------------------------------------------
function t_sh = mod_pulse (x0, xa, t_m_av, t_ch, moderator, shaping_chopper)
% Return time deviations at pulse shaping chopper position when the pulse shape
% is primarily determined by the moderator pulse shape (i.e. the shaping chopper
% pulse width is larger than the fwhh of the moderator)
%
% No shaping by pulse shaping chopper:
%   >> t_sh = mod_pulse (x0, xa, t_m_av, t_ch, moderator)
%
% Shaping by pulse shaping chopper:
%   >> t_sh = mod_pulse (..., shaping_chopper)


% Assume moderator pulse is the primary determinant
t_m = moderator.rand(size(t_ch)) - t_m_av;    % times wrt mean

% Get the time deviation at the shaping chopper
t_sh = (xa*t_m + (x0-xa)*t_ch)/x0;

% If necessary, account for shaping chopper using a rejection method
shaped = (nargin>5);
if shaped
    %disp(['mod_pulse; ',num2str(numel(t_sh))])
    bad = ~shaping_chopper.retain(t_sh);
    % Iteratively replace any rejected points
    if any(bad)
        t_sh(bad) = mod_pulse (x0, xa, t_m_av, t_ch(bad),...
            moderator, shaping_chopper);
    end
end


%--------------------------------------------------------------------------------------------------
function t_sh = chop_pulse (x0, xa, t_m_av, t_ch, shaping_chopper, moderator)
% Return time deviations at pulse shaping chopper position when the pulse shape
% is primarily determined by the shaping chopper (i.e. the moderator pulse width
% is larger than that of the shaping chopper pulse)
%
% No shaping by moderator:
%   >> t_sh = chop_pulse (x0, xa, t_m_av, t_ch, shaping_chopper)
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
    t_m = t_m + t_m_av;   % must add first moment to get to origin of moderator pulse
    
    bad = ~moderator.retain(t_m);
    % Iteratively replace any rejected points
    if any(bad)
        t_sh(bad) = chop_pulse (x0, xa, t_m_av, t_ch(bad),...
            shaping_chopper, moderator);
    end
end
