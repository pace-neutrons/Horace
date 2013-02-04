Guiding principles of functions that can take an object or file
===============================================================
 * Can take array of objects, or array of filenames. The latter can be a character array or 
   cell array of strings
   
 * If they cannot take an array of objects, they cannot take an array of files, and vice versa
 
 * They always appears as
	myfunc_horace 		Takes sqw, dnd objects or file(s) containing data of those types
						sqw objects MUST have pixel information;
						files MUST be either all sqw type or all have same dimension (will be treated as  
						***
						Arrays of sqw objects or files can be any dimensionality
						 BUT WHAT ABOUT CUT? Argumnets differ for different dimensionality
						Arrays of dnd objects must all have same dimensionality
	myfunc_sqw 			Takes sqw objects only
	myfunc_dnd 			Takes dnd objects only
	
   and the corresponding methods are defined
	myfunc 				For all classes sqw, d0d, d1d, d2d, d3d, d4d
						 BUT SOME FUNCTIONS MAY ONLY BE DEFINED FOR PARTICULAR DIMENSIONALITY
	
 * They can have any number of input or output arguments
 
 * The methods must always be able to take alternative argument lists
	myfunc(w,arg1,arg2,...)
	myfunc(wdummy,filename,arg1,arg2,...)
	myfunc(wdummy,data_source_struct,arg1,arg2,...)
 
 * Errors can be thrown by the underlying methods. myfunc_horace, myfunc_sqw, myfunc_dnd
   should only thrown errors that are related to the specific parsing of the file names, the
   dimensionality of the data in the files etc. Errors that are sepcific to the methods should
   be thrown by those methods.
   
 * Have as many generic operations shoved into utility functions as possible to maximise uniform
   behaviour across functions, and to make it easy to write new functions.
   
   
   
   
 Thoughts
 ========
 There is no absolute requirement for a dnd method to call an equivalent sqw method - there may
 simply not be a meaningful equivalent method for an sqw object, or we may not have iomplemented it.
 
 Likewise, there is no need for there to be an equivalent dnd method to an sqw method.
 
 What we do insist is that *if* an sqw method is defined for dnd-type sqw objects, it has precisely
 the same syntax and function as the equivalent dnd method. We would naturally have the dnd method
 call the sqw method having converted the dnd object to the dnd-type sqw object beforehand.