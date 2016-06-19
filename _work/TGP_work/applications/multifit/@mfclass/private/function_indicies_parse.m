function [ok,mess,ifun] = function_indicies_parse (ifun_in,nfun)
% Check that a list of function indicies has the correct format valid values
%
%   >> [ok,mess,ifun] = function_indicies_parse (ifun,nfun)
%
% Input:
% ------
%   ifun_in     List of function indicies (row vector)
%               If empty, it is assumed that a list of all functions is
%              required i.e. the default output is (1:nfun)
%               This function checks that all indicies are in the range 1
%              to nfun, and that there are no repeated indicies
%   nfun        Maximum permissible function index
%
% Output:
% -------
%   ok          Status flag: =true if all OK; =false if not
%   mess        Error message: empty if OK, non-empty otherwise
%   ifun        List of function indicies (row vector). All elements in the
%              range 1 to nfun


ok = true;
mess = '';
if isempty(ifun_in)
    ifun = 1:nfun;
elseif ~isa_index(ifun_in,nfun)
    ok = false;
    mess = ['Function indicies must be a row of integers the range 1 - ',num2str(nfun)];
    ifun = [];
elseif numel(unique(ifun_in))~=numel(ifun_in)
    ok = false;
    mess = 'Repeated function indicies are not permitted';
    ifun = [];
else
    ifun = ifun_in;
end
