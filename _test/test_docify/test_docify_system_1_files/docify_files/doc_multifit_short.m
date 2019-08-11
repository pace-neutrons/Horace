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
% Allows background functions (one per dataset) whose parameters
% vary independently for each dataset to be added to the fit function.
%
% Note: instead of a global foreground function, you can specify foreground
% functions (one per dataset) whose parameters vary independently for each
% dataset can be specified if the 'local_foreground' keyword is given.
% Similarly, you can specify a global background function, by given the
% keyword option 'global_background'
%
<DIFFERS_FROM:>
% Differs from fit<func_suffix>, which independently fits each dataset in
% succession.
<DIFFERS_FROM/END:>
<SYNONYMOUS:>
%
% For full help, read the documentation displayed when you type:
%   >> help <full_help>
%
<SYNONYMOUS/END:>
%
% Simultaneously fit datasets to a single function ('global foreground'):
% -----------------------------------------------------------------------
<MAIN:>
%   >> [wout, fitdata] = <func_prefix><func_suffix> (x, y, e, func, pin)
%   >> [wout, fitdata] = <func_prefix><func_suffix> (x, y, e, func, pin, pfree)          
%   >> [wout, fitdata] = <func_prefix><func_suffix> (x, y, e, func, pin, pfree, pbind)
%
<MAIN/END:>
%   >> [wout, fitdata] = <func_prefix><func_suffix> (w, func, pin)                 
%   >> [wout, fitdata] = <func_prefix><func_suffix> (w, func, pin, pfree)          
%   >> [wout, fitdata] = <func_prefix><func_suffix> (w, func, pin, pfree, pbind)
%
% These cover the respective cases of:
%   - All parameters free
%   - Selected parameters free to fit
%   - Binding of various parameters in fixed ratios
%
%
% With optional background functions added to the foreground:
% -----------------------------------------------------------
%   >> [wout, fitdata] = <func_prefix><func_suffix> (..., bkdfunc, bpin)
%   >> [wout, fitdata] = <func_prefix><func_suffix> (..., bkdfunc, bpin, bpfree)
%   >> [wout, fitdata] = <func_prefix><func_suffix> (..., bkdfunc, bpin, bpfree, bpbind)
%
%   If you give just one background function then that function will be used for
%   all datasets, but the parameters will be varied independently for each dataset
%
%
% Local foreground functions and/or a global background function
% --------------------------------------------------------------
% The default is for the foreground function to be global, and the
% background function(s) to be local. That is, the parameters of a single 
% foreground function are varied to minimise chi-squared acroos all the
% datasets, and the background function parameters are varied independently
% for each dataset.
%
% To have independent foreground functions for each dataset:
%   >> [wout, fitdata] = <func_prefix><func_suffix> (..., 'local_foreground')
%
%   If you give just one foreground function then that function will be used for
%   all datasets, but the parameters will be varied independently for each dataset
%
% To have a global background function across all datasets:
%   >> [wout, fitdata] = <func_prefix><func_suffix> (..., 'global_background')
%
%
<#FILE:> meta_docs:::doc_keywords_short.m
%
% If unable to fit, then the program will halt and display an error message. 
% To return if unable to fit without throwing an error, call with additional
% arguments that return status and error message:
%
%   >> [wout, fitdata, ok, mess] = <func_prefix><func_suffix> (...)
