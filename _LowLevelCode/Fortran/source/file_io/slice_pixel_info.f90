!-----------------------------------------------------------------------
! Routines for reading and writing Mslice slices in Fortran
!
! T.G.Perring March 2008
!-----------------------------------------------------------------------
module slice_pixel_info
	use type_definitions
	real(dp), allocatable :: pix(:,:)
	save :: pix
end module slice_pixel_info
