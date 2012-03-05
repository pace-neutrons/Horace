tofspectrum inherits IX_datset_2d, so all methods are inherited too.

THis would include binary and unary operations, but we would like a tofspectrum to have
priority in
	>> wout = my_IX_dataset_2d + my_tofspectrum;
	
Unfortunately, in the plus method there is no way of knowing if an IX_dataset_2d was
from an object that inherited IX_datset_2d, even if the constructor for tofspectrum
included the line
	superiorto ('IX_dataset_2d')
	
To get around this problem, as well as declaring tofspectrum as superior to IX_dataset_2d,
we also copy all the binary and unary operators into the @tofspectrum folder. In that case,
when matlab encounters a call to 
	plus(my_IX_dataset_2d,my_tofspectrum)
	
the matlab precedence rules go to the plus method for tofspectrum, which ensures the desired
behaviour.
