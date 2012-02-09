!-----------------------------------------------------------------------
! Routines for reading and writing Mslice cuts in Fortran
!
! T.G.Perring March 2008
!-----------------------------------------------------------------------
module cut_footer_info
	use type_definitions
	integer, parameter :: linlen = 255_i4b
	character(linlen), allocatable :: footer(:)
end module cut_footer_info
