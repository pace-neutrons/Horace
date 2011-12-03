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


!-----------------------------------------------------------------------
module cut_footer_info
	use type_definitions
	integer, parameter :: linlen = 255_i4b
	character(linlen), allocatable :: footer(:)
end module cut_footer_info


!-----------------------------------------------------------------------
! Read number of points in the cut
subroutine load_cut_header(filename,np)
	use type_definitions
	implicit none
	integer(i4b) :: np
	character(*) :: filename

	open(unit=1,file=filename,READONLY,err=999)
	read(1,*,err=999) np 
	close(unit=1)  
	return  

999 np=0	! convention for error reading file
	close(unit=1)
	return 
end subroutine load_cut_header
	

!-----------------------------------------------------------------------
! Read cut data 
subroutine load_cut(filename,np,x,y,e,npix,npixtot,nfooter)
	use type_definitions
	use cut_pixel_info
	use cut_footer_info
    implicit none      
    integer(i4b) :: np, npixtot, nfooter
	real(dp) :: x(np), y(np), e(np), npix(np)	! if pass from F77 code, need to declare sizes, not x(:) etc.
	character(*) :: filename

	integer(i4b) :: iunit, npixbuff, nfooterbuff, dummy, ip, npix_int, ipix, i
	real(dp), allocatable :: old_pix(:,:)	! temporary storage if reallocate pix
	character(linlen), allocatable :: old_footer(:)	! temporary footer storage if reallocate footer

	iunit=1			! unit from which to read data
	npixbuff=10000	! initial size of pixel buff
	nfooterbuff=100	! initial size of footer buffer (>0)

	open(unit=iunit,file=filename,READONLY,err=999)
	read(iunit,*,err=999) dummy

	if (allocated(pix)) deallocate(pix)			! will be saved between calls from Matlab
	allocate (pix(6,npixbuff))	! allocate storage

	if (allocated(footer)) deallocate(footer)
	allocate (footer(nfooterbuff))


	! Read in the pixel information
	npixtot = 0
	do ip = 1, np
		read (iunit,*,err=999,end=999) x(ip), y(ip), e(ip), npix(ip)
		npix_int = nint(npix(ip))
		! Reallocate pixel buffer if not large enough to hold the extra pixels from this point
		if (npixtot+npix_int > npixbuff) then
			if (allocated(old_pix)) deallocate(old_pix)
			allocate(old_pix(6,npixtot))
			old_pix=pix(:,1:npixtot)
			deallocate(pix)
			npixbuff=2_i4b*max(npixbuff,npix_int)	! guaranteed to be large enough to hold extra pixels
			allocate(pix(6,npixbuff))
			pix(:,1:npixtot)=old_pix
			deallocate(old_pix)
		endif
		! Read pixel information
		if (npix_int>0) then
			do ipix =npixtot+1,npixtot+npix_int
				read (iunit,*,err=999,end=999) (pix(i,ipix),i=1,6)
			end do
			npixtot = npixtot + npix_int 
		endif
	end do

	! Read in the footer (if any)
	nfooter = 0
100 if (nfooter == nfooterbuff) then
		if (allocated(old_footer)) deallocate(old_footer)
		allocate(old_footer(nfooterbuff))
		old_footer=footer
		deallocate(footer)
		nfooterbuff=2_i4b*nfooterbuff
		allocate(footer(nfooterbuff))
		footer(1:nfooter)=old_footer
		deallocate(old_footer)
	endif
	nfooter = nfooter + 1
	read (iunit,'(a)',err=999,end=900) footer(nfooter)
	goto 100

	! Close down in orderly fashion
900	close(unit=1) 
    nfooter = nfooter - 1
	if (allocated(old_pix)) deallocate(old_pix)
	if (allocated(old_footer)) deallocate(old_footer)
	return

999 npixtot=-1    ! convention for error reading file
	nfooter=-1
    close(unit=1)
	if (allocated(pix)) deallocate(pix)
	if (allocated(footer)) deallocate(footer)
	if (allocated(old_pix)) deallocate(old_pix)
	if (allocated(old_footer)) deallocate(old_footer)
    return
end subroutine load_cut

!-----------------------------------------------------------------------
! Transfer pixel info to an array of exactly the correct size, and cleanup
subroutine load_cut_pixels(npixtot,pix_out)
	use type_definitions
	use cut_pixel_info
    implicit none      
    integer(i4b) :: npixtot
	real(dp) :: pix_out(6,npixtot)
	pix_out=pix(:,1:npixtot)
	deallocate(pix)
	return
end subroutine load_cut_pixels

!-----------------------------------------------------------------------
! Transfer as much of footer information as can into string, and cleanup
subroutine load_cut_footer(nfooter,footer_out)
	use type_definitions
	use cut_footer_info
    implicit none      
    integer(i4b) :: nfooter, i
	character(*) footer_out(nfooter)
	do i=1,nfooter
		footer_out(i)=footer(i)
	end do
	deallocate(footer)
	return
end subroutine load_cut_footer
