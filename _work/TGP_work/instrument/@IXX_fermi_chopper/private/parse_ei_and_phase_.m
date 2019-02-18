function [ok,mess,ei,phase] = parse_ei_and_phase_ (self, varargin)
% Determine if an array of energies and/or phase have been given
%
%   >> [ok,mess,ei,phase] = parse_ei_and_phase (fermi, varargin)

ok = true;
mess = '';
ei = self.energy_;
phase = self.phase_;

if nargin>1
    if nargin==2
        if isnumeric(varargin{1})
            if ~isempty(varargin{1})
                [ok, mess, ei] = check_ei (varargin{1});
            end
        else
            [ok, mess, phase] = check_phase (varargin{1});
        end
    elseif nargin==3
        if ~isempty(varargin{1})
            [ok, mess, ei] = check_ei (varargin{1});
        end
        if ~ok, return, end
        [ok, mess, phase] = check_phase (varargin{2});
    else
        ok = false;
        mess = 'Check number of input arguments';
    end
end

%---------------------------------------------------------------------------
function [ok, mess, ei] = check_ei (ei_in)
if all(ei_in(:)>=0)
    ok = true;
    ei = ei_in;
    mess = '';
else
    ok = false;
    ei = [];
    mess = 'Incident energy or energies must all be greater than or equal to zero';
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
