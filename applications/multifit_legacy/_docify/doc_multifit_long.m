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
% Note on form of arguments if 'local_foreground' or 'local_background':
%
% If the parameters of the fit functions to the datasets are independent
% then the general rule is as follows:
% - Each input argument should be a cell array, with each element of the cell
%   array being the input argument for the function fitting the corresponding
%   data set;
% *OR*
% - If the input argument is not a cell array, it is taken as the input
%   for the function fitting each data set. That is, internally it is
%   converted to repmat({arg},size(w)), where arg is the argument and w is 
%   the array of input data sets.
%
% Use this rule to avoid any confusion about how to provide the initial
% parameter values or binding of parameters, where the input for a single
% data set can itself be a cell array. For full details, see the corresponding
% entries for these arguments below.
%
%
% Input:
% ======
<<--- Data documentation ---------------
<METHOD:>
%   w       <obj_name> object or array of <obj_name> objects to be fitted
<METHOD/END:>
<MAIN:>
    <#file:> fullfile('<multifit_doc>','doc_data.m')
<MAIN/END:>
%

<<--- Fore_func documentation ----------
%   func    A handle to the function to be fitted to the datasets.
%           If 'local_forground' is set to true, then the same function will
%           be fitted independently to each dataset. Alternatively, give an
%           array of handles, one per dataset.
<METHOD:>
    <#FILE:> <doc_forefunc> 
<METHOD/END:>
<MAIN:> 
%           If fitting x,y,e data, or a structure with fields w.x,w.y,w.e,
%           then the function must have the form:
    <#file:> fullfile('<multifit_doc>','doc_func_simple.m')
%
%           If fitting objects, then if w is an instance of an object, the
%           function(s) or method(s) must have the form:
    <#file:> fullfile('<multifit_doc>','doc_func_obj.m')
%
    <#file:> fullfile('<multifit_doc>','doc_func_advanced_use.m')
<MAIN/END:>
%

%   pin     Initial function parameter values
%
%           Case of global foreground function
%           ----------------------------------
%            - If the function takes just a numeric array of parameters, p, 
%              then pin contains the initial values, that is, pin is the
%              array [p0(1), p0(2)...]
%
%            - If further parameters are needed by the function, then wrap
%              them as a cell array, that is, pin is the cell array
%               {[p0(1), p0(2)...], c1, c2, ...}  
%
%           Case of local foreground functions:
%           -----------------------------------
%           If the function applies independently to each data set, that is,
%           'local_foreground' is set, then the same initial parameters will
%           be used for each of the functions. Alternatively, give a cell
%           array of initial values, one per data set.
%
%           EXAMPLES: Suppose there are two data sets:
%               pin=[area1,pos1,wid1];      % pin will be the input to the
%                                           % both fitting functions
%               pin={[area1,pos1,wid1],[area2,pos2,wid2]};
%                                           % Different starting values for
%                                           % the two data sets
%
%           If the parameters needed by the functions are cell arrays, take care:
%               pin={[area1,pos1,wid1],c1,c2}; % INVALID: cell array input
%                                           % is unpacked as the first element
%                                           % [area1,pos1,wid1] going to the
%                                           % first function, then c1 going
%                                           % to the second, and c2 not used
%                                           % This results in an error.
%               pin={{[area1,pos1,wid1],c1,c2}}; % Both functions are fed
%                                           % {[area2,pos2,wid2],c1,c2}
%               pin ={{[area1,pos1,wid1],c1_1,c2_1},[area2,pos2,wid2],c1_2,c2_2}}
% 
%
%   pfree   [Optional] Indicates which are the free parameters in the fit.
%
%           Case of global foreground function
%           ----------------------------------
%           e.g. pfree=[1,0,1,0,0] indicates first and third parameters 
%           are free, and the 2nd, 4th and 5th are fixed.
%           Default: if pfree is omitted or pfree=[] all parameters are free.
%
%
%           Case of local foreground functions
%           ----------------------------------
%           If the function applies independently to each dat set, that is,
%           'local_foreground' is set, then pfree applies equally to each
%           of the functions. Alternatively, give a cell array of logical
%           arrays e.g. if two functions, each with 5 parameters:
%               pfree = {[1,0,1,0,0],[1,0,0,1,1]}
%               pfree = {[1,0,1,0,0],[]}    % all parameter are free
%                                           % for the second data set
%           
%
%   pbind   [Optional] Cell array that indicates which parameters are bound
%           to other parameters in a fixed ratio determined by the initial
%           parameter values contained in pin, (and also in bpin if there are
%           background functions).
%           Default: if pbind is omitted or pbind=[] all parameters are unbound.
%
%           Case of global foreground function
%           ----------------------------------
%           A binding element describes how one parameter is bound to another:
%             pbind={1,3}               Parameter 1 is bound to parameter 3.
%
%           A binding description is made from a cell array of binding elements:
%             pbind={{1,3},{4,3},{5,6}} Parameter 1 bound to 3, 4 bound to 3,
%                                      and 5 bound to 6.
%
%           To explicity give the ratio in a binding element, ignoring that
%           determined from pin:
%             pbind=(1,3,[],7.4)        Parameter 1 is bound to parameter 3
%                                      with ratio 7.4 (the [] is required to
%                                      indicate binding is to a parameter in
%                                      the same function i.e. in this case 
%                                      the foreground function rather than
%                                      the optional background function(s).
%             pbind={1,3,0,7.4}         Same meaning: 0 (or -1) for foreground
%                                      function
%
%           To bind to background function parameters (see below)
%             pbind={1,3,7}             Parameter 1 bound to parameter 3 of
%                                      the background function for the 7th
%                                      data set, in the ratio given by the
%                                      initial values.
%             pbind={1,3,7,3.14}        Give explicit binding ratio.
%             pbind={1,3,[2,3],3.14}    The binding is to parameter 3 of the
%                                      data set with index [2,3] in the array
%                                      of data sets (index must be a valid one
%                                      in the array size returned by size(w))
%
%           If the background function is defined as global i.e. you have set
%           'global_background' as true, then always refer to background with
%           index 1 because in this case there is only one background function.
%             pbind={1,3,1,3.14}
%
%           EXAMPLE:
%             pbind={{1,3,[],7.4},{4,3,0,0.023},{5,2,1},{6,3,2,3.14}}
%                                       Parameters 1 and 4 bound to parameter
%                                      3, and parameter 5 is bound to the 2nd
%                                      parameter of the background to the first
%                                      data set, and parameter 6 is bound to
%                                      parameter 3 of the background to the 
%                                      second data set.
%
%           Note that you cannot bind a parameter to a parameter that is
%           itself bound to another parameter. You can bind to a fixed or free
%           parameter.
%
%           Case of local foreground functions
%           ----------------------------------
%           If the function applies independently to each data set, that is,
%           'local_foreground' is set, then pbind must be a cell array of 
%           binding descriptions of the form above, for each data set. Each
%           of those binding descriptions is in turn a cell array.
%           E.g. if there are two datasets, a valid pbind is:
%            pbind={ {{1,3},{4,3},{5,6}}, {{1,3},{7,10}} }
%           where the element {{1,3},{4,3},{5,6}} is the binding description
%           for the first data set, and {{1,3},{7,10}} is for the second.
%
%           To reference parameters in the foreground function applying to 
%           a particular data set, give the index of the dataset as a
%           negative number or array (c.f. a positive index to reference
%           the background function applying to a particular dataset)
%            pbind={1,3}               Parameter 1 is bound to parameter 3
%                                     of the same function
%
%            pbind={1,3,-4}            Parameter 1 is bound to parameter 3
%                                     of the function fitting the 4th data set
%
%            pbind={1,3,-[2,3]}        Parameter 1 is bound to parameter 3
%                                     of the function fitting data set w(2,3)
%       
%           It is easy to get confused about how pbind applies to the
%           datasets, because to bind two parameters requires a cell array
%           (e.g. {1,3}), to bind several parameters requires a cell array 
%           of cell arrays (e.g. {{1,3},{2,4,[],1.3}}), and lastly if there 
%           are several data sets we will in general have a cell array of
%            *these* cell arrays. The rule is as follows:
%           - If pbind is scalar cell array (i.e. size(pbind)==[1,1]), then
%            pbind applies to every one of the data sets.
%           - If size(pbind)==size(w) i.e. the number of cell arrays inside
%            pbind matches the number of data sets, then each cell array of
%            pbind applies to one dataset.
%             
%           EXAMPLE: Suppose we have three data sets
%             pbind={{1,3,[],7.4}, {4,3,[],0.023}}          INVALID
%                                       size(pbind)==[1,2] i.e. there are
%                                      two cell arrays in pbind, which is
%                                      inconsistent with the number of data sets
%
%             pbind={{{1,3,[],7.4}, {4,3,[],0.023}}}        OK
%                                       size(pbind)==[1,1] so the content:
%                                           {{1,3,[],7.4},{4,3,[],0.023}}
%                                       applies to every data set; which is
%                                       parameters 1 and 4 bound to parameter 3
%             
%             pbind={{1,3,[],7.4}, {4,3,[],0.023}, {{2,6},{3,6}}}   OK
%                                       size(pbind)==[1,3] i.e. there are
%                                      three cell arrays in pbind, which
%                                      corresponds to one for each data set.
%                                      In this case parameter 1 is bound to
%                                      parameter 3 in the function fitting the
%                                      first data set, parameters 4 is bound 
%                                      to parameter 3 in the function fitting
%                                      the second data set, and parameters 2
%                                      and 3 are bound to parameter 6 in the
%                                      function fitting the third data set.
%
%   Optional background function:
%   -----------------------------
<<--- back_func documentation ----------
%   bkdfunc A handle to the background function that will be independently
%           fitted to the datasets, or an array of function handles, one
%           per dataset.
%           If 'global_background' is set to true, then give just one 
%           function handle; that function will be fitted globaly to all
%           data sets.
<METHOD:>
    <#FILE:> <doc_backfunc> 
<METHOD/END:>
<MAIN:>
%           If fitting x,y,e data, or a structure with fields w.x,w.y,w.e,
%           then the function(s) must have the form:
    <#file:> fullfile('<multifit_doc>','doc_func_simple.m')
%
%           If fitting objects, then if w is an instance of an object, the
%           function(s) or method(s) must have the form:
    <#file:> fullfile('<multifit_doc>','doc_func_obj.m')
%
    <#file:> fullfile('<multifit_doc>','doc_func_advanced_use.m')
<MAIN/END:>
%

%   bpin    Initial parameter values for the background functions:
%           See the description of the foreground function for details for
%           both global and local fitting functions.
%           Remember that the default is for local background functions.
%
%   bpfree  Array indicating which parameters are free. See the
%           description of the foreground function for details for
%           both global and local fitting functions.
%           Remember that the default is for local background functions.
%
%   bpbind  [Optional] Indicates which parameters are bound to other 
%           parameters in a fixed ratio determined by the initial
%           parameter values contained in pin and bpin.
%           Default: if pbind is omitted or pbind=[] all parameters are unbound.
%           
%           The syntax is the same as for the foreground function. Rather than
%           repeat the documentation for pbind with minor changes to refer to
%           background functions, the general form of both pbind and bpbind is
%           described here.
%
%           - A binding description for a fit function is a cell array of
%             binding elements of the form:
%               {1,3}                   Parameter 1 is bound to parameter 3
%                                      of the same function, in the ratio
%                                      determined by the initial values.
%               {1,3,[],7.4}            Parameter 1 is bound to parameter 3,
%                                      of the same function, with ratio 7.4
%               {1,3,ind,7.4}            Parameter 1 is bound to parameter 3
%                                      of a different function, determined by
%                                      the value of ind, with ratio 7.4
%                where  ind = []        Binding parameters within he same
%                                      function
%
%                or, in the case of foreground function(s):
%                       ind = -1        The foreground function for the first
%                                      data set (or the global foreground
%                                      function, if 'global_foreground' is true)
%                       ind = -3        The foreground function for the third
%                                      data set (an index other than -1 is
%                                      only valid if 'local_foreground')
%                       ind = -[2,3]    The foreground function for data set
%                                      with index [2,3] in the input data w
%
%                or, in the case of background function(s):
%                       ind =  1        The background function for the first
%                                      data set (or the global foreground
%                                      function, if 'global_background' is true)
%                       ind =  3        The background function for the third
%                                      data set (an index other than 1 is
%                                      only valid if 'local_background')
%                       ind= [2,3]      The foreground function for data set
%                                      with index [2,3] in the input data w
%
%           - If the fit function is global, you can only give a single
%             binding description
%
%           - If the fit functions are local, then give a cell array of
%             binding descriptions
%               - if there is only one binding description in the cell array
%                 then it will apply to all fit functions
%               - if the number of binding descriptions equlas the number of
%                 data sets, then there is one binding description per fit
%                 function
%       
%
<#FILE:> fullfile('<multifit_doc>','doc_keywords_long.m')
%
%
% Output:
% =======
<METHOD:>
%   wout    <obj_name> object or array of <obj_name> objects evaluated at the
%           final fit parameter values.
%
<METHOD/END:>
<MAIN:>
%   wout    Output with same form as input data but with y values evaluated
%           at the final fit parameter values. If the input was three separate
%           x,y,e arrays, then only the calculated y values are returned.
%
<MAIN/END:>
%           If there was a problem i.e. ok==false, then wout=[].
%
%   fitdata Structure with result of the fit for each dataset. The fields are:
%           p      - Best fit foreground function parameter values
%                      If only one function, a row vector
%                      If more than one function: a row cell array of row vectors
%           sig    - Estimated errors of foreground parameters (=0 for fixed
%                    parameters)
%                      If only one function, a row vector
%                      If more than one function: a row cell array of row vectors
%           bp     - Background parameter values
%                      If only one function, a row vector
%                      If more than one function: a row cell array of row vectors
%           bsig   - Estimated errors of background (=0 for fixed parameters)
%                      If only one function, a row vector
%                      If more than one function: a row cell array of row vectors
%           corr   - Correlation matrix for free parameters
%           chisq  - Reduced Chi^2 of fit i.e. divided by:
%                       (no. of data points) - (no. free parameters))
%           converged - True if the fit converged, false otherwise
%           pnames - Foreground parameter names
%                      If only one function, a cell array (row vector) of names
%                      If more than one function: a row cell array of row vector
%                                                 cell arrays
%           bpnames- Background parameter names
%                      If only one function, a cell array (row vector) of names
%                      If more than one function: a row cell array of row vector
%                                                 cell arrays
%
%           If there was a problem i.e. ok==false, then fitdata=[].
%
%   ok      True: A fit coould be performed. This includes the cases of
%                 both convergence and failure to converge
%           False: Fundamental problem with the input arguments e.g. the
%                 number of free parameters equals or exceeds the number
%                 of data points
%               
%   mess    Error message if ok==false; Empty string if ok==true.
