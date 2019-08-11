!-----------------------------------------------------------------------
! Routines for reading and writing Mslice slices in Fortran
!
! T.G.Perring March 2008
!-----------------------------------------------------------------------

module slice_footer_info
	use type_definitions
	integer, parameter :: linlen = 255_i4b
	character(linlen), allocatable :: footer(:)
end module slice_footer_info
