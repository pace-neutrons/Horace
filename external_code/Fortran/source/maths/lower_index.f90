	function lower_index_dp (arr, val)
	use type_definitions
	implicit none
!-----------------------------------------------------------------------------------------------------------------------------------
!
!	Given monotonically increasing array ARR the function returns the smallest index M
!     ARR(M) >= VAL
!
!	If no such M (i.e. ARR(M) < VAL) then M=size(arr) + 1
!
!
!-----------------------------------------------------------------------------------------------------------------------------------
!	T.G. Perring		2002-08-15		First formal release
!	T.G. Perring		2003-08-13		Changed output index M from M=0 to M=size(arr)+1 if an error
!										This is so that we can consistently think of both lower_index and
!										upper_index as having elements arr(0) = -infinity and arr(size(arr)+1) = +infinity
!
!-----------------------------------------------------------------------------------------------------------------------------------
	real(DP), intent(in) :: arr(:), val
	integer(I4B) :: lower_index_dp

	integer(I4B) :: n, ml, mm, mh

	n = size(arr)

! return if array has zero length:
	if (n == 0) then
		lower_index_dp = n+1
		return
	endif

! find extremal cases:
	if (arr(1) >= val) then
		lower_index_dp = 1
		return
	else if (arr(n) < val) then
		lower_index_dp = n+1
		return
	endif

! binary chop to find solution
	ml = 1
	mh = n
 10 mm = (ml+mh)/2
	if (mm == ml) then
		lower_index_dp = mh
		return
	endif
	if (arr(mm) < val) then
		ml = mm
	else
		mh = mm
	endif
	goto 10

	end
!---------------------------------------------------------------------------------------------
	function lower_index_sp (arr, val)
	use type_definitions
	implicit none
!
!	Given monotonically increasing array ARR the function returns the smallest index M
!     ARR(M) >= VAL
!
!  If no such M (i.e. ARR(M) < VAL) then M=0
!
	real(SP), intent(in) :: arr(:), val
	integer(I4B) :: lower_index_sp

	integer(I4B) :: n, ml, mm, mh

	n = size(arr)

! return if array has zero length:
	if (n == 0) then
		lower_index_sp = n+1
		return
	endif

! find extremal cases:
	if (arr(1) >= val) then
		lower_index_sp = 1
		return
	else if (arr(n) < val) then
		lower_index_sp = n+1
		return
	endif

! binary chop to find solution
	ml = 1
	mh = n
 10 mm = (ml+mh)/2
	if (mm == ml) then
		lower_index_sp = mh
		return
	endif
	if (arr(mm) < val) then
		ml = mm
	else
		mh = mm
	endif
	goto 10

	end
!---------------------------------------------------------------------------------------------
	function lower_index_i4b (arr, val)
	use type_definitions
	implicit none
!
!	Given monotonically increasing array ARR the function returns the smallest index M
!     ARR(M) >= VAL
!
!  If no such M (i.e. ARR(M) < VAL) then M=0
!
	integer(I4B), intent(in) :: arr(:), val
	integer(I4B) :: lower_index_i4b

	integer(I4B) :: n, ml, mm, mh

	n = size(arr)

! return if array has zero length:
	if (n == 0) then
		lower_index_i4b = n+1
		return
	endif

! find extremal cases:
	if (arr(1) >= val) then
		lower_index_i4b = 1
		return
	else if (arr(n) < val) then
		lower_index_i4b = n+1
		return
	endif

! binary chop to find solution
	ml = 1
	mh = n
 10 mm = (ml+mh)/2
	if (mm == ml) then
		lower_index_i4b = mh
		return
	endif
	if (arr(mm) < val) then
		ml = mm
	else
		mh = mm
	endif
	goto 10

	end
	