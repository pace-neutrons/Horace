function t_sh = initial_pulse_DGdisk (mc_moderator, mc_shape_chopper, shape_mod,...
    t_ch, x0, xa, mod_ind, mod_table, mod_profile, mod_t_av, chop_fwhh)
% Sample the initial pulse structure from moderator and pulse shaping disk chopper
%
%   >> t_sh = initial_pulse_DGdisk (shape_mod, mod_ind, mod_table,...
%          mod_profile, mod_t_av, chop_ind, chop_fwhh, t_ch, x0, xa)
%
% Input:
% ------
%   mc_moderator        Logical: true if the finite moderator pulse width will
%                      be sampled; false if it will be ignored
%
%   mc_shape_chopper    Logical: true if the finite moderator pulse width will
%                      be sampled; false if it will be ignored
%
%   shape_mod   True for pixels where the pulse shaping chopper is the
%              primary determinant of the initial pulse width, false where
%              the moderator pulse has that role (row vector length = npix)
%
%   t_ch        Array of deviations of tme of arrival at monochromating
%              chopper (row vector length = npix)
%
%   x0          Moderator to monochromating chopper distance
%              (row vector length = npix)
%
%   xa          Pulse shaping chopper to monochromating chopper distance
%              (row vector length = npix)
%
%   mod_ind     Row vector of indicies into table, profile and t_av
%              length(ind)=no. runs in sqw object
%
% 	mod_table   Lookup table size(npnt,nmod), where nmod is the number of
%              unique tables.
%
% 	mod_profile Lookup table size(npnt,nmod), where nmod is the number of
%              unique tables.
%
%   mod_t_av    First moment of time distribution (row vector length nmod)
%
%   chop_fwhh   FWHH of pulse shaping chopper (row vector length = npix)
%
% Note: If only one of mc_moderator and mc_shape_chopper is turned on,
% then treat the other as having no effect i.e. it is infinitely wide. Only
% if both are turned off then do we have delta function in time.
%
% Output:
% -------
%   t_sh        Random time deviation at the position of the pulse shaping
%              chopper (row vector length = npix)


if mc_moderator || mc_shape_chopper
    if ~mc_shape_chopper
        % Deviations determined solely by moderator
        t_sh = shaped_mod_pulse (t_ch, x0, xa, mod_ind, mod_table, mod_t_av);
    elseif ~mc_moderator
        % Deviations determined soley by pulse shaping chopper
        t_sh = shaped_chop_pulse (t_ch, x0, xa, chop_fwhh);
    else
        % Moderator and chopper both determine the deviations
        t_sh = zeros(size(t_ch));
        if ~any(shape_mod)
            % Moderator dominates for all pixels
            t_sh = shaped_mod_pulse (t_ch, x0, xa, mod_ind, mod_table,...
                mod_t_av, chop_fwhh);
        elseif all(shape_mod)
            % Pulse chaping chopper dominates for all pixels
            t_sh = shaped_chop_pulse (t_ch, x0, xa, chop_fwhh, mod_ind,...
                mod_profile, mod_t_av);
        else
            t_sh(shape_mod) = shaped_chop_pulse (t_ch(shape_mod), x0(shape_mod),...
                xa(shape_mod), chop_fwhh(shape_mod), mod_ind(shape_mod),...
                mod_profile, mod_t_av);
            shape_chop = (~shape_mod);
            t_sh(shape_chop) = shaped_mod_pulse (t_ch(shape_chop), x0(shape_chop),...
                xa(shape_chop), mod_ind(shape_chop), mod_table, mod_t_av,...
                chop_fwhh(shape_chop));
        end
    end
else
    % All deviations set to zero
    t_sh = zeros(size(t_ch));
end


%--------------------------------------------------------------------------------------------------
function t_sh = shaped_mod_pulse (t_ch, x0, xa, mod_ind, mod_table, mod_t_av, chop_fwhh)
% Return time deviations at pulse shaping chopper position for dominant moderator.
%
% No shaping by pulse shaping chopper:
%   >> t_sh = shaped_mod_pulse (t_ch, x0, xa, mod_ind, mod_table, mod_t_av)
%
% Shaping by pulse shaping chopper:
%   >> t_sh = shaped_mod_pulse (t_ch, x0, xa, mod_ind, mod_table, mod_t_av, chop_fwhh)


% Assume moderator pulse is the dominant determinant
t_red = rand_cumpdf_arr (mod_table, mod_ind);       % row vector
t_m = mod_t_av(mod_ind) .* (t_red./(1-t_red) - 1);  % must subtract first moment

% Get the time deviation at the shaping chopper
t_sh = (xa.*t_m + (x0-xa).*t_ch)./x0;

% If necessary, account for shaping chopper using a rejection method
shaped = (nargin>6);
if shaped
    % Get the transmission of shaping chopper at those times
    trans = 1 - abs(t_sh)./chop_fwhh;
    bad = (rand(size(trans))>trans);    % this rejection condition also covers |t_sh|>chop_fwhh
    
    % Iteratively replace any rejected points
    if any(bad)
        t_sh(bad) = shaped_mod_pulse (t_ch(bad), x0(bad), xa(bad),...
            mod_ind(bad), mod_table, mod_t_av, chop_fwhh(bad));
    end
end


%--------------------------------------------------------------------------------------------------
function t_sh = shaped_chop_pulse (t_ch, x0, xa, chop_fwhh, mod_ind, mod_profile, mod_t_av)
% Return time deviations at pulse shaping chopper position for dominant chopper.
%
% No shaping by moderator:
%   >> t_sh = shaped_chop_pulse (t_ch, x0, xa, chop_fwhh)
%
% Shaping by pulse moderator:
%   >> t_sh = shaped_chop_pulse (t_ch, x0, xa, chop_fwhh, mod_ind, mod_profile, mod_t_av)


% Assume shaping chopper is the dominant determinant of the pulse
t_sh = chop_fwhh .* rand_triangle(size(chop_fwhh));     % row vector

% If necessary, account for shaping chopper using a rejection method
shaped = (nargin>4);
if shaped
    % Get the time deviation at the moderator
    t_m = (x0.*t_sh - (x0-xa).*t_ch)./xa;
    t_red = (mod_t_av(mod_ind)+t_m)./(2*mod_t_av(mod_ind)+t_m);     % must add first moment
    
    % Get the relative moderator profile (peak value unity) at those times
    trans = zeros(size(t_red));
    ok = (t_red>0);     % chopper may correspond to before proton pulse
    trans(ok) = interp1_arr(mod_profile,t_red(ok),mod_ind(ok));
    bad = (rand(size(trans))>trans);
    
    % Iteratively replace any rejected points
    if any(bad)
        t_sh(bad) = shaped_chop_pulse (t_ch(bad), x0(bad), xa(bad), chop_fwhh(bad),...
            mod_ind(bad), mod_profile, mod_t_av);
    end
end
