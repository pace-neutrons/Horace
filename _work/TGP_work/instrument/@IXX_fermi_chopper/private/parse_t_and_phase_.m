function [ok,mess,t,phase,t_given] = parse_t_and_phase_ (self, varargin)
% Determine if an array of times and/or phase have been given
%
%   >> [ok,mess,t,phase,t_given] = parse_ei_and_phase (fermi, varargin)

ok = true;
mess = '';
t = Inf;
phase = self.phase_;
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
