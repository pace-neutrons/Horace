12 May 2013	 	T.G.Perring

The new version of multifit replaces the previous, now in the folder named multifit_legacy.
We keep this for the time-being in case there are problems that we need to side-step with
a quick fix.

Two utility functions are here to enable that:

 - set_multifit_version:
	To put the legacy version on the path and remove the latest version, type
		>> set_multifit_version ('legacy')
	
	To put the new version back on the path and remove the legacy version, type
		>> set_multifit_version ('current')
		
 - Convert output of legacy version
	The format of the output of the fit parameter values is slightly different:
	If there was just one background function, the parameter values were nevertheless
	placed as a vector as the first (and only) element of a cell array. In the 
	new version this is not the case. The same applies to the estimated errors and
	the parameter names. Convert the old format to the nw format with
		>> fitpar_new_format = multifit_legacy_convert_output (fitpar_legacy_format)
		