% Define the following:
% ---------------------
%   main            logical     Main fit function
%   synonymous      logical     Synonymous with another function
%
%   first_iine      string      Top line of the documentation
%   full_help       string      Name of function for full help


<#doc_beg:>
<first_line>
<MAIN:>
%
% The data to be fitted can be a set or sets of of x,y,e arrays, or an
% object or array of objects of a class. [Note: if you have written your own
% class, there are some required methods for this fit function to work.
% See notes at the end of this help]
%
<MAIN/END:>
%
% A background function can be added to the fit function.
% If passed an array of datasets, then each dataset is fitted independently.
%
% Differs from multifit<func_suffix>, which fits all datasets in the array
% simultaneously but with independent backgrounds.
<SYNONYMOUS:>
%
% For full help, read the documentation displayed when you type:
%   >> help <full_help>
%
<SYNONYMOUS/END:>
%
% Fit several datasets in succession to a given function:
% -------------------------------------------------------
<MAIN:>
%   >> [wout, fitdata] = fit<func_suffix> (x, y, e, func, pin)
%   >> [wout, fitdata] = fit<func_suffix> (x, y, e, func, pin, pfree)          
%   >> [wout, fitdata] = fit<func_suffix> (x, y, e, func, pin, pfree, pbind)
%
<MAIN/END:>
%   >> [wout, fitdata] = fit<func_suffix> (w, func, pin)                 
%   >> [wout, fitdata] = fit<func_suffix> (w, func, pin, pfree)          
%   >> [wout, fitdata] = fit<func_suffix> (w, func, pin, pfree, pbind)
%
% These cover the respective cases of:
%   - All parameters free
%   - Selected parameters free to fit
%   - Binding of various parameters in fixed ratios
%
%
% With optional background function added to the function:
% --------------------------------------------------------
%   >> [wout, fitdata] = fit<func_suffix> (..., bkdfunc, bpin)
%   >> [wout, fitdata] = fit<func_suffix> (..., bkdfunc, bpin, bpfree)
%   >> [wout, fitdata] = fit<func_suffix> (..., bkdfunc, bpin, bpfree, bpbind)
%
%
<#FILE:> multifit_doc:::doc_keywords_short.m
% If unable to fit, then the program will halt and display an error message. 
% To return if unable to fit without throwing an error, call with additional
% arguments that return status and error message:
%
%   >> [wout, fitdata, ok, mess] = fit<func_suffix> (...)
