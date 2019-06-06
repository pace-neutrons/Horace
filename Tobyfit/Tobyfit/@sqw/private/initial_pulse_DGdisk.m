function t_sh = initial_pulse_DGdisk (iw, irun, x0, xa, t_ch, moderator_table,...
    shaping_chopper_table, mc_moderator, mc_shape_chopper, shaped_mod)
% Sample the initial pulse structure from moderator and pulse shaping disk chopper
%
%   >> t_sh = initial_pulse_DGdisk (iw, irun, x0, xa, t_ch, moderator_table,...
%       shaping_chopper_table, mc_moderator, mc_shape_chopper, shaped_mod)
%
% Input:
% ------
%   iw          Index of workspace in object lookup tables
%
%   irun        Array of run indices (column vector length = npix)
%
%   x0          Moderator to monochromating chopper distance
%              (column vector length = npix)
%
%   xa          Pulse shaping chopper to monochromating chopper distance
%              (column vector length = npix)
%
%   t_ch        Array of deviations of time of arrival at monochromating
%              chopper (column vector length = npix) (microseconds)
%
%   moderator_table         Moderator object_lookup object indexed into by
%                          iw and irun
%
%   shaping_chopper_table   Shaping chopper object_lookup object indexed
%                          into by iw and irun
%
%   mc_moderator        Logical scalar: true if the finite moderator pulse
%                      width will be sampled; false if it will be ignored
%
%   mc_shape_chopper    Logical scalar: true if the finite shaping chopper
%                      pulse width will be sampled; false if it will be ignored
%
%   shaped_mod  True for pixels where the pulse shaping chopper is the
%              primary determinant of the initial pulse width, false where
%              the moderator pulse has that role (column vector length = npix)
%
% Note: If only one of mc_moderator and mc_shape_chopper is turned on,
% then treat the other as having no effect i.e. it is infinitely wide. Only
% if both are turned off then do we have delta function in time.
%
% Output:
% -------
%   t_sh        Random time deviation at the position of the pulse shaping
%              chopper (column vector length = npix) (microseconds)


if mc_moderator || mc_shape_chopper
    if ~mc_shape_chopper
        % Deviations determined solely by moderator
        t_sh = mod_pulse (iw, irun, x0, xa, t_ch, moderator_table);
        
    elseif ~mc_moderator
        % Deviations determined soley by pulse shaping chopper
        t_sh = chop_pulse (iw, irun, x0, xa, t_ch, shaping_chopper_table);
        
    else
        % Moderator and chopper both determine the deviations
        if ~any(shaped_mod)
            % Moderator dominates for all pixels
            t_sh = mod_pulse (iw, irun, x0, xa, t_ch,...
                moderator_table, shaping_chopper_table);
            
        elseif all(shaped_mod)
            % Pulse shaping chopper dominates for all pixels
            t_sh = chop_pulse (iw, irun, x0, xa, t_ch,...
                shaping_chopper_table, moderator_table);
            
        else
            t_sh = zeros(size(t_ch));   % need to initialise t_sh

            t_sh(shaped_mod) = chop_pulse (iw, irun, x0(shaped_mod),...
                xa(shaped_mod), t_ch(shaped_mod), shaping_chopper_table, moderator_table);
            
            shaped_chop = (~shaped_mod);
            t_sh(shaped_chop) = mod_pulse (iw, irun, x0(shaped_chop),...
                xa(shaped_chop), t_ch(shaped_chop), moderator_table, shaping_chopper_table);
        end
    end
else
    % All deviations set to zero
    t_sh = zeros(size(t_ch));
end


%--------------------------------------------------------------------------------------------------
function t_sh = mod_pulse (iw, irun, x0, xa, t_ch, moderator_table, shaping_chopper_table)
% Return time deviations at pulse shaping chopper position when the pulse shape
% is primarily determined by the moderator pulse shape (i.e. the shaping chopper
% pulse width is larger than the fwhh of the moderator)
%
% No shaping by pulse shaping chopper:
%   >> t_sh = mod_pulse (iw, irun, x0, xa, t_ch, moderator_table))
%
% Shaping by pulse shaping chopper:
%   >> t_sh = mod_pulse (..., shaping_chopper_table)


% Assume moderator pulse is the primary determinant
[~,mod_t_av] = moderator_table.func_eval (iw, irun, @pulse_width);
t_m = moderator_table.rand_ind(iw, irun) - mod_t_av;    % times wrt mean

% Get the time deviation at the shaping chopper
t_sh = (xa.*t_m + (x0-xa).*t_ch)./x0;

% If necessary, account for shaping chopper using a rejection method
shaped = (nargin>6);
if shaped
    bad = ~shaping_chopper_table.func_eval_ind (iw, irun, @retain, t_sh);
    % Iteratively replace any rejected points
    if any(bad)
        t_sh(bad) = mod_pulse (iw, irun(bad), x0(bad), xa(bad), t_ch(bad),...
            moderator_table, shaping_chopper_table);
    end
end


%--------------------------------------------------------------------------------------------------
function t_sh = chop_pulse (iw, irun, x0, xa, t_ch, shaping_chopper_table, moderator_table)
% Return time deviations at pulse shaping chopper position when the pulse shape
% is primarily determined by the shaping chopper (i.e. the moderator pulse width
% is larger than that of the shaping chopper pulse)
%
% No shaping by moderator:
%   >> t_sh = chop_pulse (iw, irun, x0, xa, t_ch, shaping_chopper_table)
%
% Shaping by pulse moderator:
%   >> t_sh = chop_pulse (..., moderator_table)


% Assume shaping chopper is the dominant determinant of the pulse
t_sh = shaping_chopper_table.rand_ind(iw,irun);

% If necessary, account for shaping chopper using a rejection method
shaped = (nargin>6);
if shaped
    [~,mod_t_av] = moderator_table.func_eval (iw, irun, @pulse_width);
    t_m = (x0.*t_sh - (x0-xa).*t_ch)./xa;   % get the time deviation at the moderator
    t_m = t_m + mod_t_av;   % must add first moment to get to origin of moderator pulse
    
    bad = ~moderator_table.func_eval_ind (iw, irun, @retain, t_m);
    % Iteratively replace any rejected points
    if any(bad)
        t_sh(bad) = chop_pulse (iw, irun(bad), x0(bad), xa(bad), t_ch(bad),...
            shaping_chopper_table, moderator_table);
    end
end
