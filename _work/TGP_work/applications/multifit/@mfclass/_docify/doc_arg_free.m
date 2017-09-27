% Description of argument free as used by set_fun, set_free,
% and corresponding methods for background functions
%
% -----------------------------------------------------------------------------
% <#doc_def:>
%   type   = '#1'    % 'back' or 'fore'
%   pre    = '#2'    % 'b' or ''
%   is_free= '#3'    % true if the help for set_free (cf set_fun) is being made
%   is_fun = '#4'    % opposite of is_pin
%
% -----------------------------------------------------------------------------
% <#doc_beg:>
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
% <#doc_end:>
% -----------------------------------------------------------------------------