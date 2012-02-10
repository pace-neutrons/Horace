!-----------------------------------------------------------------------------------------------------------------------------------
! Interface module for maths library.
!
!-----------------------------------------------------------------------------------------------------------------------------------
	module maths

	interface bin_boundaries_get_xarr
		subroutine bin_boundaries_get_xarr (ierr, xbounds, x_in, n_out, x_out)
		use type_definitions
		real(dp), intent(in) :: xbounds(:)
		real(dp), intent(in), optional :: x_in(:)
		integer(i4b), intent(out) :: ierr
		integer(i4b), intent(out), optional :: n_out
		real(dp), intent(out), optional :: x_out(:)
		end subroutine bin_boundaries_get_xarr
	end interface

	interface integrate_1d_points
	    subroutine integrate_1d_points (ierr, x, s, e, xout, sout, eout)
	    use type_definitions
	    use tools_parameters
	    real(dp), intent(in) :: x(:), s(:), e(:)
	    real(dp), intent(out) :: xout(:), sout(:), eout(:)
	    integer(i4b), intent(out) :: ierr
		end subroutine integrate_1d_points
	end interface

	interface integrate_2d_x_points
	    subroutine integrate_2d_x_points (ierr, x, s, e, xout, sout, eout)
	    use type_definitions
	    use tools_parameters
	    real(dp), intent(in) :: x(:), s(:,:), e(:,:)
	    real(dp), intent(out) :: xout(:), sout(:,:), eout(:,:)
	    integer(i4b), intent(out) :: ierr
		end subroutine integrate_2d_x_points
	end interface
	
	interface integrate_2d_y_points
	    subroutine integrate_2d_y_points (ierr, y, s, e, yout, sout, eout)
	    use type_definitions
	    use tools_parameters
	    real(dp), intent(in) :: y(:), s(:,:), e(:,:)
	    real(dp), intent(out) :: yout(:), sout(:,:), eout(:,:)
	    integer(i4b), intent(out) :: ierr
		end subroutine integrate_2d_y_points
	end interface
	
	interface integrate_3d_x_points
	    subroutine integrate_3d_x_points (ierr, x, s, e, xout, sout, eout)
	    use type_definitions
	    use tools_parameters
	    real(dp), intent(in) :: x(:), s(:,:,:), e(:,:,:)
	    real(dp), intent(out) :: xout(:), sout(:,:,:), eout(:,:,:)
	    integer(i4b), intent(out) :: ierr
		end subroutine integrate_3d_x_points
	end interface
	
	interface integrate_3d_y_points
	    subroutine integrate_3d_y_points (ierr, y, s, e, yout, sout, eout)
	    use type_definitions
	    use tools_parameters
	    real(dp), intent(in) :: y(:), s(:,:,:), e(:,:,:)
	    real(dp), intent(out) :: yout(:), sout(:,:,:), eout(:,:,:)
	    integer(i4b), intent(out) :: ierr
		end subroutine integrate_3d_y_points
	end interface
	
	interface integrate_3d_z_points
	    subroutine integrate_3d_z_points (ierr, z, s, e, zout, sout, eout)
	    use type_definitions
	    use tools_parameters
	    real(dp), intent(in) :: z(:), s(:,:,:), e(:,:,:)
	    real(dp), intent(out) :: zout(:), sout(:,:,:), eout(:,:,:)
	    integer(i4b), intent(out) :: ierr
		end subroutine integrate_3d_z_points
	end interface
	
	interface single_integrate_1d_points
	    subroutine single_integrate_1d_points (x, s, e, xmin, xmax, ml, mu, val, errbar)
	    use type_definitions
        integer(i4b), intent(in) :: ml, mu
	    real(dp), intent(in) :: x(:), s(:), e(:), xmin, xmax
	    real(dp), intent(out) :: val, errbar
		end subroutine single_integrate_1d_points
	end interface
		
	interface single_integrate_2d_x_points
	    subroutine single_integrate_2d_x_points (x, s, e, xmin, xmax, ml, mu, val, errbar)
	    use type_definitions
        integer(i4b), intent(in) :: ml, mu
	    real(dp), intent(in) :: x(:), s(:,:), e(:,:), xmin, xmax
	    real(dp), intent(out) :: val(:), errbar(:)
		end subroutine single_integrate_2d_x_points
	end interface
		
	interface single_integrate_2d_y_points
	    subroutine single_integrate_2d_y_points (y, s, e, ymin, ymax, ml, mu, val, errbar)
	    use type_definitions
        integer(i4b), intent(in) :: ml, mu
	    real(dp), intent(in) :: y(:), s(:,:), e(:,:), ymin, ymax
	    real(dp), intent(out) :: val(:), errbar(:)
		end subroutine single_integrate_2d_y_points
	end interface
		
	interface single_integrate_3d_x_points
	    subroutine single_integrate_3d_x_points (x, s, e, xmin, xmax, ml, mu, val, errbar)
	    use type_definitions
        integer(i4b), intent(in) :: ml, mu
	    real(dp), intent(in) :: x(:), s(:,:,:), e(:,:,:), xmin, xmax
	    real(dp), intent(out) :: val(:,:), errbar(:,:)
		end subroutine single_integrate_3d_x_points
	end interface
		
	interface single_integrate_3d_y_points
	    subroutine single_integrate_3d_y_points (y, s, e, ymin, ymax, ml, mu, val, errbar)
	    use type_definitions
        integer(i4b), intent(in) :: ml, mu
	    real(dp), intent(in) :: y(:), s(:,:,:), e(:,:,:), ymin, ymax
	    real(dp), intent(out) :: val(:,:), errbar(:,:)
		end subroutine single_integrate_3d_y_points
	end interface

	interface single_integrate_3d_z_points
	    subroutine single_integrate_3d_z_points (z, s, e, zmin, zmax, ml, mu, val, errbar)
	    use type_definitions
        integer(i4b), intent(in) :: ml, mu
	    real(dp), intent(in) :: z(:), s(:,:,:), e(:,:,:), zmin, zmax
	    real(dp), intent(out) :: val(:,:), errbar(:,:)
		end subroutine single_integrate_3d_z_points
	end interface

	interface rebin_1d_hist
		subroutine rebin_1d_hist (ierr, xin, yin, ein, xout, yout, eout)
		use type_definitions
		real(dp), intent(in) :: xin(:), yin(:), ein(:)
		real(dp), intent(out) :: xout(:), yout(:), eout(:)
		integer(i4b), intent(out) :: ierr
		end subroutine rebin_1d_hist
	end interface

	interface rebin_2d_x_hist
		subroutine rebin_2d_x_hist (ierr, x, s, e, xout, sout, eout)
		use type_definitions
	    real(dp), intent(in) :: x(:), s(:,:), e(:,:)
	    real(dp), intent(out) :: xout(:), sout(:,:), eout(:,:)
	    integer(i4b), intent(out) :: ierr
		end subroutine rebin_2d_x_hist
	end interface

	interface rebin_2d_y_hist
		subroutine rebin_2d_y_hist (ierr, y, s, e, yout, sout, eout)
		use type_definitions
	    real(dp), intent(in) :: y(:), s(:,:), e(:,:)
	    real(dp), intent(out) :: yout(:), sout(:,:), eout(:,:)
	    integer(i4b), intent(out) :: ierr
		end subroutine rebin_2d_y_hist
	end interface

	interface rebin_3d_x_hist
		subroutine rebin_3d_x_hist (ierr, x, s, e, xout, sout, eout)
		use type_definitions
	    real(dp), intent(in) :: x(:), s(:,:,:), e(:,:,:)
	    real(dp), intent(out) :: xout(:), sout(:,:,:), eout(:,:,:)
	    integer(i4b), intent(out) :: ierr
		end subroutine rebin_3d_x_hist
	end interface

	interface rebin_3d_y_hist
		subroutine rebin_3d_y_hist (ierr, y, s, e, yout, sout, eout)
		use type_definitions
	    real(dp), intent(in) :: y(:), s(:,:,:), e(:,:,:)
	    real(dp), intent(out) :: yout(:), sout(:,:,:), eout(:,:,:)
	    integer(i4b), intent(out) :: ierr
		end subroutine rebin_3d_y_hist
	end interface

	interface rebin_3d_z_hist
		subroutine rebin_3d_z_hist (ierr, z, s, e, zout, sout, eout)
		use type_definitions
	    real(dp), intent(in) :: z(:), s(:,:,:), e(:,:,:)
	    real(dp), intent(out) :: zout(:), sout(:,:,:), eout(:,:,:)
	    integer(i4b), intent(out) :: ierr
		end subroutine rebin_3d_z_hist
	end interface

	end module
