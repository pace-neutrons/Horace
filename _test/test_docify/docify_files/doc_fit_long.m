% Define the following:
% ---------------------
%   main            logical     Main fit function
%   method          logical     Class method
%
%   doc_forefunc    string      Nmae of file with foreground function description
%   doc_backfunc    string      Nmae of file with background function description
%
%   obj_name        string      Name of object

<#doc_beg:>
%------------------------------------------------------------------------------
% Description in full
%------------------------------------------------------------------------------
% Input:
% ======
<<--- Data documentation ---------------
<METHOD:>
%   w       <obj_name> object or array of <obj_name> objects to be fitted
<METHOD/END:>
<MAIN:>
    <#file:> meta_docs:::doc_data.m
<MAIN/END:>
%

<<--- Fore_func documentation ----------
%   func    A handle to the function to be fitted to each of the datasets.
<METHOD:>
    <#FILE:> <doc_forefunc> 
<METHOD/END:>
<MAIN:>
%           If fitting x,y,e data, or structure(s) with fields w.x,w.y,w.e,
%           then the function must have the form:
    <#file:> meta_docs:::doc_func_simple.m
%
%           If fitting objects, then if w is an instance of an object or
%           an array of objects, the function or method must have the form:
    <#file:> meta_docs:::doc_func_obj.m
%
    <#file:> meta_docs:::doc_func_advanced_use.m
<MAIN/END:>
%


%   pin     Initial function parameter values
%            - If the function takes just a numeric array of parameters, p, 
%              then pin contains the initial values, that is, pin is the
%              array [pin(1), pin(2)...]
%
%            - If further parameters are needed by the function, then wrap
%              them as a cell array, that is, pin is the cell array
%               {[pin(1), pin(2)...], c1, c2, ...}  
%
%   pfree   [Optional] Indicates which are the free parameters in the fit.
%           e.g. pfree=[1,0,1,0,0] indicates first and third parameters 
%           are free, and the 2nd, 4th and 5th are fixed.
%           Default: if pfree is omitted or pfree=[] all parameters are free.
%
%   pbind   [Optional] Cell array that indicates which parameters are bound
%           to other parameters in a fixed ratio determined by the initial
%           parameter values contained in pin.
%           Default: if pbind is omitted or pbind=[] all parameters are unbound.
%             pbind={1,3}               Parameter 1 is bound to parameter 3.
%
%           Multiple bindings are made from a cell array of cell arrays
%             pbind={{1,3},{4,3},{5,6}} Parameter 1 bound to 3, 4 bound to 3,
%                                      and 5 bound to 6.
%
%           To explicity give the ratio, ignoring that determined from pin:
%             pbind=(1,3,[],7.4)        Parameter 1 is bound to parameter 3
%                                      with ratio 7.4 (the [] is required to
%                                      indicate binding is to a parameter in
%                                      the same function i.e. the foreground
%                                      function rather than the optional
%                                      background function.
%             pbind={1,3,0,7.4}         Same meaning: 0 (or -1) for foreground
%                                      function
%
%           To bind to background function parameters (see below)
%             pbind={1,3,1}             Parameter 1 bound to parameter 3 of
%                                      the background function, in the ratio
%                                      given by the initial values.
%             pbind={1,3,1,3.14}        Give explicit binding ratio.
%   
%           EXAMPLE:
%             pbind={{1,3,[],7.4},{4,3,0,0.023},{5,2,1},{6,3,1,3.14}}
%                                       Parameters 1 and 4 bound to parameter
%                                      3, and parameters5 and 6 bound to
%                                      parameters 2 and 3 of the background.
%
%           Note that you cannot bind a parameter to a parameter that is
%           itself bound to another parameter. You can bind to a fixed or free
%           parameter.
%
%
%   Optional background function:
%   -----------------------------
%   bkdfunc A handle to the background function to be fitted to each of the
%           datasets.
<METHOD:>
    <#FILE:> <doc_backfunc>
<METHOD/END:>
<MAIN:>
%           See the description of the foreground function for details
<MAIN/END:>
%   
%   bpin    Initial parameter values for the background function.  See the
%           description of the foreground function for details.
%
%   bpfree  Array indicating which parameters are free. See the
%           description of the foreground function for details.
%
%   bpbind  [Optional] Cell array that that indicates which parameters are bound
%           to other parameters in a fixed ratio determined by the initial
%           parameter values contained in pin and bpin.
%           The syntax is the same as for the foreground function:
%           
%             bpbind={1,3}              Parameter 1 is bound to parameter 3.
%
%           Multiple bindings are made from a cell array of cell arrays
%             bpbind={{1,3},{4,3},{5,6}} Parameter 1 bound to 3, 4 bound to 3,
%                                      and 5 bound to 6.
%
%           To explicity give the ratio, ignoring that determined from bpin:
%             bpbind=(1,3,[],7.4)       Parameter 1 is bound to parameter 3,
%                                      ratio 7.4 (the [] is required to
%                                      indicate binding is to a parameter in
%                                      the same function i.e. the background
%                                      function rather than the foreground
%                                      function.
%             bpbind={1,3,1,7.4}         Same meaning: 1 for background function
%
%           To bind to foreground function parameters:
%             bpbind={1,3,0}            Parameter 1 bound to parameter 3 of
%                                      the foreground function.
%             bpbind={1,3,0,3.14}       Give explicit binding ratio.
%       
%
<#FILE:> meta_docs:::doc_keywords_long.m
%
%
% Output:
% =======
<METHOD:>
%   wout    <obj_name> object or array of <obj_name> objects evaluated at the
%           final fit parameter values.
%
%           If there was a problem for ith data set i.e. ok(i)==false, then
%           wout(i)==w(i)
%
<METHOD/END:>
<MAIN:>
%   wout    Output with same form as input data but with y values evaluated
%           at the final fit parameter values. If the input was three separate
%           x,y,e arrays, then only the calculated y values are returned.
%
%           If there was a problem for ith data set i.e. ok(i)==false, then
%           wout(i)==w(i) if w is an array of structures or objects, or
%           wout{i}=[] if cell array input).
%
<MAIN/END:>
%           If there was a fundamental problem e.g. incorrect input argument
%          syntax, or none of the fits succeeded (i.e. all(ok(:))==false)
%          then wout=[].
%
% fitdata   Structure with result of the fit for each dataset. The fields are:
%          	p      - Parameter values [Row vector]
%           sig    - Estimated errors of global parameters (=0 for fixed 
%                    parameters) [Row vector]
%           bp     - Background parameter values [Row vector]
%        	bsig   - Estimated errors of background (=0 for fixed parameters)
%                    [Row vector]
%       	corr   - Correlation matrix for free parameters
%          	chisq  - Reduced Chi^2 of fit (i.e. divided by
%                                (no. of data points) - (no. free parameters))
%       	converged - True if the fit converged, false otherwise
%           pnames - Parameter names: a cell array (row vector)
%        	bpnames- Background parameter names: a cell array (row vector)
%
%           Single data set input:
%           ----------------------
%           If there was a problem i.e. ok==false, then fitdata=[]
%
%           Array of data sets:
%           -------------------
%           fitdata is an array of structures with the size of the input
%          data array.
%
%           If there was a problem for ith data set i.e. ok(i)==false, then
%          fitdata(i) will contain dummy information.
%
%           If there was a fundamental problem e.g. incorrect input argument
%          syntax, or none of the fits succeeded (i.e. all(ok(:))==false)
%          then fitdata=[].
%
%   ok      True: A fit coould be performed. This includes the cases of
%             both convergence and failure to converge
%           False: Fundamental problem with the input arguments e.g.
%             the number of free parameters equals or exceeds the number
%             of data points
%
%           Array of data sets:
%           -------------------
%           If an array of input datasets was given, then ok is an array with
%          the size of the input data array.
%
%           If there was a fundamental problem e.g. incorrect input argument
%          syntax, or none of the fits succeeded (i.e. all(ok(:))==false)
%          then ok is scalar and ok==false.
%
%   mess    Error message if ok==false; Empty string if ok==true.
%
%           Array of data sets:
%           -------------------
%           If an array of datasets was given, then mess is a cell array of
%          strings with the same size as the input data array.
%
%           If there was a fundamental problem e.g. incorrect input argument
%          syntax, or none of the fits succeeded (i.e. all(ok(:))==false)
%          then mess is a single character string.
