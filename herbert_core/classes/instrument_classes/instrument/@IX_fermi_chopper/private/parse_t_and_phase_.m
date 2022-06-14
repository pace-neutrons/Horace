function [ok, mess, t, phase, t_given] = parse_t_and_phase_ (obj, varargin)
% Determine if an array of times and/or phase have been given
%   
%   >> [ok, mess, t, phase, t_given] = parse_t_and_phase (obj, t)
%   >> [ok, mess, t, phase, t_given] = parse_t_and_phase (obj, phase)
%   >> [ok, mess, t, phase, t_given] = parse_t_and_phase (obj, t, phase)
%
% Use in methods to parse input:
%      [ok, mess, t, phase, t_given] = parse_t_and_phase, varargin{:})
%
% Input:
% ------
%   obj     IX_fermi_chopper object (scalar instance)
%
%   t       Time(s) in microseconds (scalar or array)
%
%   phase   Logical flag (scalar): =1 in-phase; =0 in anti-phase
%           Default: the value contained in the chopper object
%
% Output:
% -------
%   ok      True if 
%
%   t       Time(s): passed through unchanged if valid; =0 if not
%
%   phase   Logical flag: passed through unchanged if valid, or default if
%           the phase was not given (see above)
%
%   t_given Status of t: =true if times were given; =false if not


ok = true;
mess = '';
t = 0;
phase = obj.phase_;
t_given = false;

if nargin>1
    if nargin==2
        if isnumeric(varargin{1})
            t = varargin{1};
            t_given = true;
        else
            [ok, mess, phase] = check_phase (varargin{1});
        end
    elseif nargin==3
        if isnumeric(varargin{1})
            t = varargin{1};
            t_given = true;
        else
            ok = false;
            mess = 'Time must be numeric';
            return
        end
        [ok, mess, phase] = check_phase (varargin{2});
    else
        ok = false;
        mess = 'Check number of input arguments';
    end
end

end

%---------------------------------------------------------------------------
function [ok, mess, phase] = check_phase (phase_in)
if islognumscalar(phase_in)
    ok = true;
    phase = logical(phase_in);
    mess = '';
else
    ok = false;
    phase = [];
    mess = 'Phase must be scalar true or false (or 1 or 0)';
end

end
