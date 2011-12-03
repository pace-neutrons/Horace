	subroutine single_integrate_3d_z_points (z, s, e, zmin, zmax, ml, mu, val, errbar)
	use type_definitions

!-----------------------------------------------------------------------------------------------------------------------------------
! Integrate z-axis over a 3D data set with point character along the z-axis between two limits.
! The method is a simple trapezoidal rule, with the ordinates at the points being linearly interpolated between
! the values in the array s.
!
! It is assumed that checks have been made to ensure that (1) zmin < zmax, and that (2) there is an overlap between the
! input z array and the interval [zmin,zmax] i.e. zmin =< z(ml) and z(mu) =< zmax for ml, mu in the range 1 to size(z)
!
!-----------------------------------------------------------------------------------------------------------------------------------
! [Optional arguments are marked with * below]
!
! INPUT:
!	s(:,:,:)	real		Signal
!	e(:,:,:)	real		Error bars on signal
!   zmin	    real		Lower integration limit
!   zmax	    real		Upper integration limit
!   ml          integer     Smallest ml such that zmin =< z(ml)
!   mu          integer     Largest  mu such that z(mu)=< zmax
!
! OUTPUT:
!	val(:,:)    real        Integral
!   errbar(:,:) real        Standard deviation on val
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		August 2011     First release
!
!-----------------------------------------------------------------------------------------------------------------------------------
	implicit none

    integer(i4b), intent(in) :: ml, mu
	real(dp), intent(in) :: z(:), s(:,:,:), e(:,:,:), zmin, zmax
	real(dp), intent(out) :: val(:,:), errbar(:,:)

	integer(i4b) nz, ilo, ihi, i
	real(dp) z1eff, zneff
	real(dp), dimension(size(s,1),size(s,2)) :: s1eff, sneff, e1eff, eneff

! Perform integration:
! ----------------------
    nz = size(z)

	if (mu<ml) then
!	special case of no data points in the integration range
		ilo = max(ml-1,1)	! z(1) is end point if ml=1
		ihi = min(mu+1,nz)	! z(nz) is end point if mu=nz
		val = 0.5_dp * ((zmax-zmin)/(z(ihi)-z(ilo))) * &
			&( s(:,:,ihi)*((zmax-z(ilo))+(zmin-z(ilo))) + s(:,:,ilo)*((z(ihi)-zmax)+(z(ihi)-zmin)) )
		errbar = 0.5_dp * ((zmax-zmin)/(z(ihi)-z(ilo))) * &
			& sqrt( (e(:,:,ihi)*((zmax-z(ilo))+(zmin-z(ilo))))**2 + (e(:,:,ilo)*((z(ihi)-zmax)+(z(ihi)-zmin)))**2 )
	else
!	zmin and zmax are separated by at least one data point in z(:)

!	Set up effective end points:
		if (ml>1) then	! z(1) is end point if ml=1
			z1eff = (zmin*(zmin-z(ml-1)) + z(ml-1)*(z(ml)-zmin))/(z(ml)-z(ml-1))
			s1eff = s(:,:,ml-1)*(z(ml)-zmin)/((z(ml)-z(ml-1)) + (zmin-z(ml-1)))
			e1eff = e(:,:,ml-1)*(z(ml)-zmin)/((z(ml)-z(ml-1)) + (zmin-z(ml-1)))
		else
			z1eff = z(ml)
			s1eff = 0.0_dp
			e1eff = 0.0_dp
		endif
		if (mu<nz) then	! z(mu) is end point if mu=nz
			zneff = (zmax*(z(mu+1)-zmax) + z(mu+1)*(zmax-z(mu)))/(z(mu+1)-z(mu))
			sneff = s(:,:,mu+1)*(zmax-z(mu))/((z(mu+1)-z(mu)) + (z(mu+1)-zmax))
			eneff = e(:,:,mu+1)*(zmax-z(mu))/((z(mu+1)-z(mu)) + (z(mu+1)-zmax))
		else
			zneff = z(nz)
			sneff = 0.0_dp
			eneff = 0.0_dp
		endif

!	zmin to z(ml):
		val = (z(ml)-z1eff)*(s(:,:,ml)+s1eff)
		errbar = (e1eff*(z(ml)-z1eff))**2

!	z(ml) to z(mu):
		if (mu==ml) then		! one data point, no complete intervals
			errbar = errbar + (e(:,:,ml)*(zneff-z1eff))**2
		elseif (mu==ml+1) then	! one complete interval
			val = val + (s(:,:,mu)+s(:,:,ml))*(z(mu)-z(ml))
			errbar = errbar + (e(:,:,ml)*(z(ml+1)-z1eff))**2 + (e(:,:,mu)*(zneff-z(mu-1)))**2
		else
		    val = val + (s(:,:,ml+1)+s(:,:,ml))*(z(ml+1)-z(ml))
		    errbar = errbar + (e(:,:,ml)*(z(ml+1)-z1eff))**2 + (e(:,:,mu)*(zneff-z(mu-1)))**2
		    do i=ml+1,mu-1
			    val = val + (s(:,:,i+1)+s(:,:,i))*(z(i+1)-z(i))
			    errbar = errbar + (e(:,:,i)*(z(i+1)-z(i-1)))**2
		    end do
		endif

!	z(mu) to zmax:
		val = val + (zneff-z(mu))*(s(:,:,mu)+sneff)
		errbar = errbar + (eneff*(zneff-z(mu)))**2

		val = 0.5_dp*val
		errbar = 0.5_dp*sqrt(errbar)
	endif

	return
	end
