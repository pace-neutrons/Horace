function ave_pars = get_header_average(header)
% Create average parameters across a series of spe files for lattice and energy bins
%
%   >> ave_pars = header_average(header)
%
%   header      sqw structure header block. can be for single or multiple spe file 
%   ave_pars    Average fields as follows:
%                   ave_pars.alatt
%                   ave_pars.angdeg
%                   ave_pars.u_to_rlu
%                   ave_pars.ulen
%                   ave_pars.en
%
% *** Currently simplest implementation: uses first header block

% T.G.Perring   2 August 2007

if isstruct(header)
    header_ref = header;
else
    header_ref = header{1};
end
ave_pars.alatt = header_ref.alatt;
ave_pars.angdeg = header_ref.angdeg;
ave_pars.u_to_rlu = header_ref.u_to_rlu;
ave_pars.ulen = header_ref.ulen;
ave_pars.en = header_ref.en;
