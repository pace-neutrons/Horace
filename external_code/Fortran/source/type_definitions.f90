!-----------------------------------------------------------------------------------------------------------------------------------
! Type definitions. Taken from Numerical Recipes in Fortran 90, and added to these definitions
!
!-----------------------------------------------------------------------------------------------------------------------------------
module type_definitions
	integer, parameter :: i4b = selected_int_kind(9)
	integer, parameter :: i2b = selected_int_kind(4)
	integer, parameter :: i1b = selected_int_kind(2)
	integer, parameter :: sp = kind(1.0)
	integer, parameter :: dp = kind(1.0d0)
	integer, parameter :: spc = kind((1.0,1.0))
	integer, parameter :: dpc = kind((1.0d0,1.0d0))
	integer, parameter :: lgt = kind(.true.)
	real(sp), parameter :: pi_sp=3.141592653589793238462643383279502884197_sp
	real(sp), parameter :: pio2_sp=1.57079632679489661923132169163975144209858_sp
	real(sp), parameter :: twopi_sp=6.283185307179586476925286766559005768394_sp
	real(sp), parameter :: sqrt2_sp=1.41421356237309504880168872420969807856967_sp
	real(sp), parameter :: euler_sp=0.5772156649015328606065120900824024310422_sp
	real(dp), parameter :: pi_dp=3.141592653589793238462643383279502884197_dp
	real(dp), parameter :: pio2_dp=1.57079632679489661923132169163975144209858_dp
	real(dp), parameter :: twopi_dp=6.283185307179586476925286766559005768394_dp
	real(dp), parameter :: sqrt2_dp=1.41421356237309504880168872420969807856967_dp
	real(dp), parameter :: euler_dp=0.5772156649015328606065120900824024310422_dp
	real(sp), parameter :: null_sp = -1.0e30
	real(dp), parameter :: null_dp = -1.0d30
end module type_definitions
