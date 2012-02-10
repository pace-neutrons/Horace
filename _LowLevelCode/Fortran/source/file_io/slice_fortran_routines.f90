!-----------------------------------------------------------------------
! Routines for reading and writing Mslice slices in Fortran
!
! T.G.Perring March 2008
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
! Read number of points in the slice
subroutine load_slice_header(filename, header)
	use type_definitions
	implicit none
	integer(i4b) :: i
	real(dp) :: header(6)
	character(*) :: filename

	open(unit=1,file=filename,action='READ',err=999)
	read(1,*,err=999) (header(i),i=1,6)
	close(unit=1)  
	return  

999 header(1)=0	! convention for error reading file
	close(unit=1)
	return 
end subroutine load_slice_header
	

!-----------------------------------------------------------------------
! Read slice data 
subroutine load_slice(filename,np,x,y,c,e,npix,npixtot,nfooter)
	use type_definitions
	use slice_pixel_info
	use slice_footer_info
    implicit none      
    integer(i4b) :: np, npixtot, nfooter
	real(dp) :: x(np), y(np), c(np), e(np), npix(np)	! if pass from F77 code, need to declare sizes, not x(:) etc.
	character(*) :: filename

	integer(i4b) :: iunit, npixbuff, nfooterbuff, ip, npix_int, ipix, i
	real(dp) :: dummy(6)
	real(dp), allocatable :: old_pix(:,:)	! temporary storage if reallocate pix
	character(linlen), allocatable :: old_footer(:)	! temporary footer storage if reallocate footer

	iunit=1			! unit from which to read data
	npixbuff=10000	! initial size of pixel buff
	nfooterbuff=100	! initial size of footer buffer (>0)

	open(unit=iunit,file=filename,action='READ',err=999)
	read(iunit,*,err=999) (dummy(i),i=1,6)

	if (allocated(pix)) deallocate(pix)			! will be saved between calls from Matlab
	allocate (pix(7,npixbuff))	! allocate storage

	if (allocated(footer)) deallocate(footer)
	allocate (footer(nfooterbuff))


	! Read in the pixel information
	npixtot = 0
	do ip = 1, np
		read (iunit,*,err=999,end=999) x(ip), y(ip), c(ip), e(ip), npix(ip)
		npix_int = nint(npix(ip))
		! Reallocate pixel buffer if not large enough to hold the extra pixels from this point
		if (npixtot+npix_int > npixbuff) then
			if (allocated(old_pix)) deallocate(old_pix)
			allocate(old_pix(7,npixtot))
			old_pix=pix(:,1:npixtot)
			deallocate(pix)
			npixbuff=2_i4b*max(npixbuff,npix_int)	! guaranteed to be large enough to hold extra pixels
			allocate(pix(7,npixbuff))
			pix(:,1:npixtot)=old_pix
			deallocate(old_pix)
		endif
		! Read pixel information
		if (npix_int>0) then
			do ipix =npixtot+1,npixtot+npix_int
				read (iunit,*,err=999,end=999) (pix(i,ipix),i=1,7)
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
end subroutine load_slice

!-----------------------------------------------------------------------
! Transfer pixel info to an array of exactly the correct size, and cleanup
subroutine load_slice_pixels(npixtot,pix_out)
	use type_definitions
	use slice_pixel_info
    implicit none      
    integer(i4b) :: npixtot
	real(dp) :: pix_out(7,npixtot)
	pix_out=pix(:,1:npixtot)
	deallocate(pix)
	return
end subroutine load_slice_pixels

!-----------------------------------------------------------------------
! Transfer as much of footer information as can into string, and cleanup
subroutine load_slice_footer(nfooter,footer_out)
	use type_definitions
	use slice_footer_info
    implicit none      
    integer(i4b) :: nfooter, i
	character(*) footer_out(nfooter)
	do i=1,nfooter
		footer_out(i)=footer(i)
	end do
	deallocate(footer)
	return
end subroutine load_slice_footer
