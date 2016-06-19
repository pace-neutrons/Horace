function [ok,mess,idata] = dataset_indicies_parse (idata_in,ndatatot)
% Check that a list of function indicies has the correct format valid values
%
%   >> [ok,mess,ifun] = dataset_indicies_parse (idata_in,ndatatot)
%
% Input:
% ------
%   idata_in    List of dataset indicies (row vector)
%               If empty, it is assumed that a list of all datasets is
%              required i.e. the default output is (1:ndatatot)
%               This function checks that all indicies are in the range 1
%              to ndatatot, and that there are no repeated indicies
%   ndatatot    Maximum permissible dataset index
%
% Output:
% -------
%   ok          Status flag: =true if all OK; =false if not
%   mess        Error message: empty if OK, non-empty otherwise
%   idata       List of dataset indicies (row vector). All elements in the
%              range 1 to ndatatot


ok = true;
mess = '';
if isempty(idata_in)
    idata = 1:ndatatot;
elseif ~isa_index(idata_in,ndatatot)
    ok = false;
    mess = ['Dataset indicies must be a row of integers the range 1 - ',num2str(ndatatot)];
    idata = [];
elseif numel(unique(idata_in))~=numel(idata_in)
    ok = false;
    mess = 'Repeated dataset indicies are not permitted';
    idata = [];
else
    idata = idata_in;
end
