function split = parse_split (narg, char_opt, iargs)
% Parse 'split' keyword, optionally followed by argument iargs
% Checks that the keyword is valid, and iargs has valid values
%
%   >> split = parse_split (narg, char_opt)
%   >> split = parse_split (narg, char_opt, iargs)
%
%
% Input:
% ------
%   narg        Number of arguments to which option 'split' applies
%   char_opt    Character string whose only valid value is 'split' or an
%               abbreviation of 'split'
%   iargs       Indices of arguments to be split. Must be an array of
%               unique positive integers less than or equal to narg.
%               If not given, or empty, then treated as (1:narg)
%
% Output:
% -------
%   split       Logical row vector size(1,narg)


% Parse the 'split' option to give a logical row vector, true where
% arguments are to be unpacked, false where not.


if ~isempty(char_opt) && is_string(char_opt) && ...
        strncmpi(char_opt, 'split', numel(char_opt))
    if nargin==2 || isempty(iargs)  % input argument iargs is given
        split = true(1,narg);
    else
        if isnumeric(iargs) && all(iargs(:)>=1) && all(iargs(:)<=narg) &&...
                all(rem(iargs,1)==0) && numel(unique(iargs(:)))==numel(iargs)
            split = false(1,narg);
            split(iargs) = true;
        else
            error('HERBERT:parse_rand_ind:invalid_argument',...
                ['Parameter indicies must be unique positive integers ',...
                'less than or equal to the number of function parameters']);
        end
    end
    
else
    error('HERBERT:parse_rand_ind:invalid_argument',...
        ['Expected ','''split''', 'option not found in a valid position'])
end
