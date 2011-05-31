	function upper_index_dp (arr, val)
	use type_definitions
	implicit none
!-----------------------------------------------------------------------------------------------------------------------------------
!
!	Given monotonically increasing array ARR the function returns the largest index M
!     ARR(M) =< VAL
!
!	If no such M (i.e. ARR(1) > VAL) then M=0
!
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		2002-08-15		First formal release
!
!
!-----------------------------------------------------------------------------------------------------------------------------------
	real(DP), intent(in) :: arr(:), val
	integer(I4B) :: upper_index_dp

	integer(I4B) :: n, ml, mm, mh

	n = size(arr)

! return if array has zero length:
	if (n == 0) then
		upper_index_dp = 0
		return
	endif

! find extremal cases:
	if (arr(n) <= val) then
		upper_index_dp = n
		return
	else if (arr(1) > val) then
		upper_index_dp = 0
		return
	endif

! binary chop to find solution
	ml = 1
	mh = n
 10 mm = (ml+mh)/2
	if (mm == ml) then
		upper_index_dp = ml
		return
	endif
	if (arr(mm) > val) then
		mh = mm
	else
		ml = mm
	endif
	goto 10

	end
!---------------------------------------------------------------------------------------------
	function upper_index_sp (arr, val)
	use type_definitions
	implicit none
!
!	Given monotonically increasing array ARR the function returns the largest index M
!     ARR(M) =< VAL
!
!  If no such M (i.e. ARR(1) > VAL) then M=0
!
	real(SP), intent(in) :: arr(:), val
	integer(I4B) :: upper_index_sp

	integer(I4B) :: n, ml, mm, mh

	n = size(arr)

! return if array has zero length:
	if (n == 0) then
		upper_index_sp = 0
		return
	endif

! find extremal cases:
	if (arr(n) <= val) then
		upper_index_sp = n
		return
	else if (arr(1) > val) then
		upper_index_sp = 0
		return
	endif

! binary chop to find solution
	ml = 1
	mh = n
 10 mm = (ml+mh)/2
	if (mm == ml) then
		upper_index_sp = ml
		return
	endif
	if (arr(mm) > val) then
		mh = mm
	else
		ml = mm
	endif
	goto 10

	end
!---------------------------------------------------------------------------------------------
	function upper_index_i4b (arr, val)
	use type_definitions
	implicit none
!
!	Given monotonically increasing array ARR the function returns the largest index M
!     ARR(M) =< VAL
!
!  If no such M (i.e. ARR(1) > VAL) then M=0
!
	integer(I4B), intent(in) :: arr(:), val
	integer(I4B) :: upper_index_i4b

	integer(I4B) :: n, ml, mm, mh

	n = size(arr)

! return if array has zero length:
	if (n == 0) then
		upper_index_i4b = 0
		return
	endif

! find extremal cases:
	if (arr(n) <= val) then
		upper_index_i4b = n
		return
	else if (arr(1) > val) then
		upper_index_i4b = 0
		return
	endif

! binary chop to find solution
	ml = 1
	mh = n
 10 mm = (ml+mh)/2
	if (mm == ml) then
		upper_index_i4b = ml
		return
	endif
	if (arr(mm) > val) then
		mh = mm
	else
		ml = mm
	endif
	goto 10

	end
