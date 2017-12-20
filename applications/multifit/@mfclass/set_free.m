function obj = set_free (obj, varargin)
% Set which foreground function parameters are free and which are fixed
%
% Set fixed/free status for all foreground functions
%   >> obj = obj.set_free (free)
%
% Set for one or more specific foreground function(s)
%   >> obj = obj.set_free (ifun, free)
%
% Input:
% ------
%   free    Logical row vector or cell array of logical row vectors that
%          define which parameters are free to float in a fit.
%           Each element of a row vector consists of logical true or
%          false (or 1 or 0) indicating if the corresponding parameter
%          for a function is free to float during a fit or is fixed.
%
%           In general:
%           - If the fit function is global, then give only one row
%             vector: the one function applies to every dataset
%
%           - If the fit functions are local, then:
%               - if every dataset is to be fitted to the same function
%                you can give just one vector of fixed/float values if
%                you want the same parameters to be fixed or floating
%                for each dataset, even if the initial values are
%                different.
%
%               - if the functions are different for different datasets
%                or the float status of the parameters is different for
%                different datasets, give a cell array of function
%                handles, one per dataset
%
% Optional argument:
%   ifun    Scalar or row vector of function indicies to which the operation
%          will be applied. [Default: all functions]
%
%
% See also set_bfree set_fun set_bfun

% -----------------------------------------------------------------------------
% <#doc_def:>
%   mfclass_doc = fullfile(fileparts(which('mfclass')),'_docify')
%   doc_set_free_intro = fullfile(mfclass_doc,'doc_set_free_intro.m')
%
%   type = 'fore'
%   pre = ''
%
% -----------------------------------------------------------------------------
% <#doc_beg:> multifit
%   <#file:> <doc_set_free_intro> <type> <pre>
%
%
% See also set_bfree set_fun set_bfun
% <#doc_end:>
% -----------------------------------------------------------------------------


% Original author: T.G.Perring
%
% $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)


% Process input
isfore = true;
[ok, mess, obj] = set_free_private_ (obj, isfore, varargin);
if ~ok, error(mess), end
