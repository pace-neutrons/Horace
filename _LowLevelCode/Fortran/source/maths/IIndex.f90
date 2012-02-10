!-----------------------------------------------------------------------------------------------------------------------------------
! Interface module for maths library.
!
!-----------------------------------------------------------------------------------------------------------------------------------
	module IIndex
	interface lower_index
		function lower_index_dp (arr, val)
		use type_definitions
		real(DP), intent(in) :: arr(:), val
		integer(I4B) :: lower_index_dp
		end function lower_index_dp

		function lower_index_sp (arr, val)
		use type_definitions
		real(SP), intent(in) :: arr(:), val
		integer(I4B) :: lower_index_sp
		end function lower_index_sp

		function lower_index_i4b (arr, val)
		use type_definitions
		integer(I4B), intent(in) :: arr(:), val
		integer(I4B) :: lower_index_i4b
		end function lower_index_i4b
	end interface

	interface upper_index
		function upper_index_dp (arr, val)
		use type_definitions
		real(DP), intent(in) :: arr(:), val
		integer(I4B) :: upper_index_dp
		end function upper_index_dp

		function upper_index_sp (arr, val)
		use type_definitions
		real(SP), intent(in) :: arr(:), val
		integer(I4B) :: upper_index_sp
		end function upper_index_sp

		function upper_index_i4b (arr, val)
		use type_definitions
		integer(I4B), intent(in) :: arr(:), val
		integer(I4B) :: upper_index_i4b
		end function upper_index_i4b
	end interface

	
	end module
