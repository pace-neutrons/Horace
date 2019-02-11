function [ok,mess,t,phase] = parse_t_and_phase_ (self, varargin)
% Determine if an array of times and/or phase have been given
%
%   >> [ok,mess,t,phase] = parse_ei_and_phase (fermi, varargin)

ok = true;
mess = '';
t = Inf;
phase = self.phase;

if nargin>1
    if nargin==2
        if isnumeric(varargin{1})
            t = varargin{1};
        else
            [ok, mess, phase] = check_phase (varargin{1});
        end
    elseif nargin==3
        t = varargin{1};
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
