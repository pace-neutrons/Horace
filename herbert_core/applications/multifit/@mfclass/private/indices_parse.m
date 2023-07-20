function ind = indices_parse (ind_in,ndatatot,str)
% Check that a list of dataset indices has the correct format valid values
%
% This function checks that all indices are in the range 1
%    to ndatatot, and that there are no repeated indices
%
%   >> ind = indices_parse (ind_in,ndatatot,str)
%
% Input:
% ------
%   ind_in      List of dataset indices (row vector)
%               Can be empty (i.e. []); this is valid even if ndatatot=0.
%               If ind_in=='all' then 1:ndatatot will be returned unless ndatatot==0,
%                  in which case [] will be returned.
%
%   ndatatot    Maximum permissible dataset index (can be 0)
%
%   str         String to use in error messages 'Dataset' or 'Function'
%
%
% Output:
% -------
%   ind         List of dataset indices (row vector). All elements will be
%                  in the range 1 to ndatatot, or will be []


% Original author: T.G.Perring

if istext(ind_in) && strcmpi(ind_in,'all')

    if ndatatot > 0
        ind = 1:ndatatot;
    else
        ind = [];
    end

elseif isnumeric(ind_in)
    if ~isrow(ind_in) || ~all(rem(ind_in,1) == 0) ||...
            any(ind_in < 1 | ind_in > ndatatot)
        error('HORACE:indices_parse:invalid_argument', ...
              '%s indices must be a row of integers in the range 1 - %d', str, ndatatot);

    elseif numel(unique(ind_in)) ~= numel(ind_in)
        error('HORACE:indices_parse:invalid_argument', ...
              '%s indices that are repeated are not permitted', str);
    end

    if isempty(ind_in)
        ind = [];
    else
        ind = ind_in;
    end

else
    error('HORACE:indices_parse:invalid_argument', ...
          '%s indices must be numeric row vector or the character string ''all''', str);
end

end
