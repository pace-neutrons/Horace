% Some good test cases to check test rebin_boundaries_check
% ----------------------------------------------------------
[ok,xbounds,any_dx_zero,mess]=rebin_boundaries_check(1,[])

[ok,xbounds,any_dx_zero,mess]=rebin_boundaries_check(1,0)

[ok,xbounds,any_dx_zero,mess]=rebin_boundaries_check(1,4,6)

[ok,xbounds,any_dx_zero,mess]=rebin_boundaries_check(1,4,0,6)

[ok,xbounds,any_dx_zero,mess]=rebin_boundaries_check(1,4,5.5,6)

[ok,xbounds,any_dx_zero,mess]=rebin_boundaries_check(1,[4,6])

[ok,xbounds,any_dx_zero,mess]=rebin_boundaries_check(1,[4,0,6])

[ok,xbounds,any_dx_zero,mess]=rebin_boundaries_check(1,[4,5.5,6])

