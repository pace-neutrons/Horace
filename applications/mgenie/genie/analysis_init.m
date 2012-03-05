function analysis_init (mon_norm, mon_tlo, mon_thi, mon_norm_constant)
% Set up default parameters for analysis utilities using data access routines
%
%   >> analysis_init (mon_norm, mon_tlo, mon_thi, mon_norm_constant)
%
%   >> analysis_init                % To view current settings
%
%   mon_norm            Default monitor for normalisation
%   mon_tlo             Lower time integration limit
%   mon_thi             Upper time integration limit
%   mon_norm_constant   Normalisation constant
%                      Data will be normalised by monitor counts in units of mon_norm_constant
%                      i.e. data is divided by (integral/mon_norm_constant)

global mgenie_globalvars

if nargin==4
    if isa(mon_norm,'double') && isa(mon_tlo,'double') && isa(mon_thi,'double') && isa(mon_norm_constant,'double') &&...
            isscalar(mon_norm) && isscalar(mon_tlo) && isscalar(mon_thi) && isscalar(mon_norm_constant)
        mgenie_globalvars.analysis.mon_norm   = mon_norm;
        mgenie_globalvars.analysis.mon_tlo    = mon_tlo;
        mgenie_globalvars.analysis.mon_thi    = mon_thi;
        mgenie_globalvars.analysis.mon_norm_constant = mon_norm_constant;
    else
        error ('Check parameters are numerical scalars')
    end
elseif nargin~=0
    error ('Check number of parameters')
end

disp(['                Monitor for normalisation : ',num2str(mgenie_globalvars.analysis.mon_norm)])
disp(['             Lower time integration limit : ',num2str(mgenie_globalvars.analysis.mon_tlo)])
disp(['             Upper time integration limit : ',num2str(mgenie_globalvars.analysis.mon_thi)])
disp(['Normalise by monitor integral in units of : ',num2str(mgenie_globalvars.analysis.mon_norm_constant)])
disp(' ')
