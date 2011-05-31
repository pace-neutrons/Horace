!-----------------------------------------------------------------------------------------------------------------------------------
! dataset_definitions module. Contains data points and errors
!
!-----------------------------------------------------------------------------------------------------------------------------------
module dataset_definitions
	use type_definitions
	type datum
		real(dp) :: val, err
	end type

	type data_1d
		real(dp), pointer :: val(:)		!data points
		real(dp), pointer :: err(:)		!errors
	end type

	type data_2d
		real(dp), pointer :: val(:,:)	!data points
		real(dp), pointer :: err(:,:)	!errors
	end type

end module dataset_definitions
