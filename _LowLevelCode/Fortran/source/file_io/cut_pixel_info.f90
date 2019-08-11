!-----------------------------------------------------------------------
! Routines for reading and writing Mslice cuts in Fortran
!
! T.G.Perring March 2008
!-----------------------------------------------------------------------
module cut_pixel_info
	use type_definitions
	real(dp), allocatable :: pix(:,:)
	save :: pix
end module cut_pixel_info

