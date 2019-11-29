function [ok,mess,ind] = indicies_parse (ind_in,ndatatot,str)
% Check that a list of dataset indicies has the correct format valid values
%
%   >> [ok,mess,ind] = indicies_parse (ind_in,ndatatot,str)
%
% Input:
% ------
%   ind_in      List of dataset indicies (row vector)
%               This function checks that all indicies are in the range 1
%              to ndatatot, and that there are no repeated indicies
%               Can be empty (i.e. []); this is valid even if ndatatot=0
%               If 'all' then will be interpreted as all datasets
%
%   ndatatot    Maximum permissible dataset index (can be 0)
%
%   str         String to use in error messages 'Dataset' or 'Function'
%
%
% Output:
% -------
%   ok          Status flag: =true if all OK; =false if not
%
%   mess        Error message: empty if OK, non-empty otherwise
%
%   idata       List of dataset indicies (row vector). All elements will be
%              in the range 1 to ndatatot, or will be []


% Original author: T.G.Perring
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)


ok = true;
mess = '';

if ischar(ind_in) && strcmpi(ind_in,'all')
    if ndatatot>0
        ind = 1:ndatatot;
    else
        ind = [];
    end
    
elseif isnumeric(ind_in)
    if ~isempty(ind_in)
        if ~isrowvector(ind_in) || ~all(rem(ind_in,1)==0) ||...
                ~all(isfinite(ind_in)) || any(ind_in==0) || any(ind_in>ndatatot)
            ok = false;
            mess = [str,' indicies must be a row of integers the range 1 - ',num2str(ndatatot)];
            ind = [];
        elseif numel(unique(ind_in))~=numel(ind_in)
            ok = false;
            mess = [str,' indicies that are repeated are not permitted'];
            ind = [];
        else
            ind = ind_in;
        end
    else
        ind = [];
    end
    
else
    ok = false;
    mess = [str, 'indicies must be numeric row vector or the character string ''all'''];
    ind = [];
end
