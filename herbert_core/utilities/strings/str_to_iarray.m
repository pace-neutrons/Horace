function [x, le_nmax] = str_to_iarray (str, nmax)
% Read integers from a character vector or array, or cell array of character vectors
%
%   >> [x, le_nmax] = str_to_iarray (str)
%   >> [x, le_nmax] = str_to_iarray (str, nmax)
%
% Input:
% ------
%   str     Input text: can be one of:
%               - Character vector (i.e. row vector of characters length >= 0
%                 or the empty character array, '')
%               - Two-dimensional character array
%               - Cell array of character vectors
%               - strings or string array (Matlab release R2017a onwards)
%
%           The contents of each string (or row in a character array) can be any
%          number of delimited single integers or ranges of integers as specified
%          by the tokens '-' (as used in e.g. spectra mask or map files at ISIS)
%          or the Matlab format 'i1:i2' or 'i1:istep:i2'. No whitespace is
%          permitted in such range specifications.
%           e.g.
%               '34-30'   => [34,33,32,31,30]
%               '-12--10' => [-12,-11,-10]
%               '-3--5'   => [-3,-4,-5]
%
%           If a range is specified by the token ':', then the rules obeyed by
%          Matlab array ranges are followed:
%           e.g.
%               '34:30'   => []
%               '-12:-10' => [-12,-11,-10]
%               '-3:-5'   => []
%
%           Multiple tokens can appear on a line, of either format:
%           e.g.
%               '34:30, -12--10' ==> [34,33,32,31,30,-12,-11,-10]
%
%           Lines beginning with '%' or '!' are considered comment lines and are
%          ignored, as are any characters beyond the first occurence of '%' or
%          '!'. This allows in-line comments to be added.
%           e.g.
%               '34-36 ! some values' => [34,35,36]
%
%           If a string (or row in a character array) begins with '[' and end
%          with ']', then these are ignored in order to be consistent with the
%          simplest form of the standard Matlab array assignment:
%           e.g.
%               '[24:2:28, 11:13]' => [24,26,28,11,12,13]
%           but also
%               '[-4--6, 11:13]' => [-4,-5,-6,11,12,13]
%
%   nmax    [Optional] maximum number of integers to read in total from the
%          input strings. If there are more integers, then they will be ignored.
%           Default: +Inf
%
% Output:
% -------
%   x       Row vector of integers.
%
%   le_nmax If true: the input represents less than or equal to nmax integers
%           If false: the input represents more than nmax integers
%           (This output allows [~,le_max] = str_to_iarray (...) without filling
%           the array x)
%
% EXAMPLE
%
%   >> str_to_iarray('5:9,12-16 7 11 -4--7')
% ans =
%     5   6   7   8   9  12  13  14  15  16   7  11  -4  -5  -6  -7


% Determine maximum number of integers to be read
if nargin == 1
    nmax = Inf;
else
    if ~isnumeric(nmax) || ~isscalar(nmax) || rem(nmax,1)~=0 || nmax < 1
        error('HERBERT:str_to_iarray:invalid_argument', ['The maximum number ',...
            'of integers to be read must be greater or equal to unity (Default: +Inf)'])
    end
end

% Check character data (input will be turned into one long string)
[ok, cout] = str_make_cellstr_trim (str);
if ~ok
    error('HERBERT:str_to_iarray:invalid_argument', ['The input data must be ',...
        'a character string, character array or cellarray of strings'])
end

% Remove comment lines and trailing comments (first occurence of '%' or '!'), and
% then remove brackets if has form '[...]'
cout = cellfun(@(x)strip_square_brackets(strip_comment(x)), cout, 'UniformOutput', false);
ok = ~cellfun(@isempty, cout);
cout = cout(ok);

% Concatenate all strings into one (with a leading space to ensure whitespace delimiter)
if ~isempty(cout)
    strtmp = strjoin(cout, ' ');
else
    strtmp = ' ';   % ensures output consistent with non-empty but no-integer string
end

% Find positions of tokens: 
% - Delimiters are:
%   - A comma with any number of whitespace characters before and after
%    (including no white space): \s*,\s*
%   - One or more whitespace characters: \s+
% - Tokens run from iend(i)+1:ibeg(i+1)-1, but we must allow for the case of 
%   tokens at beginning &/or running to end; the construction below means that
%   the first and/or last tokens are empty, which are handled in the function
%   str_token_to_iarray
[ibeg, iend] = regexp (strtmp, '\s*,\s*|\s+');  % delimiters
itok_beg = [1,iend+1];
itok_end = [ibeg-1, numel(strtmp)];

% Parse each token in turn, and pick out only those ranges with at least one point
ntok=numel(itok_beg);
x1 = NaN(1, ntok);
dx = NaN(1, ntok);
n = NaN(1,ntok);
for i=1:ntok
    [x1(i), dx(i), ~, n(i)] = str_token_to_iarray (strtmp(itok_beg(i):itok_end(i)));
end
ok = (n>0);
ntok = sum(ok);
x1 = x1(ok);
dx = dx(ok);
n = n(ok);

% Fill output array
if isempty(n)
    % Case of no integers read
    x = NaN(1,0);   % to be consistent with e.g. 3:2 which has size == [1,0]
    le_nmax = true; % nmax is guaranteed to be >= 1
    
else
    % At least one integer read
    nend = cumsum(n);
    nbeg = nend - n + 1;
    if isfinite(nmax) && (nend(ntok) > nmax)
        % The number of integers encoded in the strings is greater than the number
        % to be read. Find the token which includes the maximum, and truncate the
        % number of integers it encodes if necessary
        ntok = lower_index(nend, nmax); % number of tokens required to contain nmax integers
        nend(ntok) = nmax;              % update nend(ntok); we will ignore all later entries
        n(ntok) = nmax - nbeg(ntok) + 1;% will be >=1 by design
        le_nmax = false;
    else
        le_nmax = true;
    end
    
    x = NaN(1,nend(ntok));
    for i=1:ntok
        x(nbeg(i):nend(i)) = x1(i) + (0:n(i)-1) * dx(i);
    end
end


%-------------------------------------------------------------------------------
function cout = strip_comment (cin)
% Remove trailing comments and trim a character string
ind = [strfind(cin, '!'), strfind(cin, '%')];
if ~isempty(ind)
    cout = strtrim(cin(1:min(ind)-1));
else
    cout = strtrim(cin);
end


%-------------------------------------------------------------------------------
function cout = strip_square_brackets (cin)
% Remove leading '[' and trailing ']' then trim a character string
if numel(cin)>=2 && cin(1)=='[' && cin(end)==']'
    cout = strtrim(cin(2:end-1));
else
    cout = strtrim(cin);
end

%-------------------------------------------------------------------------------
function [x1, dx, x2, n] = str_token_to_iarray (token)
% Reads string and parses to elements of Matlab form in xlo:dx:xhi
%
%   >> [x1, dx, x2, n] = str_token_to_iarray (token)
%
% Input:
% ------
%   token   Character string to be parsed. Valid formats are:
%
%           Empty string or whitespace: <no numbers>
%
%           Single integer: 'mmm'  '-mmm'
%
%           List of integers:
%               non-Matlab format:
%                   'mmm-nnn'  '-mmm-nnn'  'mmm--nnn'  '-mmm--nnn'
%
%                   These havethe matlab equivalent mmm:sss:nnn where
%                   sss = 1 or -1 according as mmm<nnn or mmm>nnn respectively
%
%               Matlab format:
%                   'mmm:nnn', 'mmm:sss:nnn'
%
%                   Interpretation follows Matlab format e.g. 15:-13 and
%                   15:-2:13 result in NaN(1,0)
%
%
%           e.g. '34-30' => [34,33,32,31,30]
%                '-12--10' => [-12,-11,-10]
%                '-3--5' => [-3,-4,-5]
%
% Output:
% -------
%   x1  -|
%   dx   |- Integers such the array xlo:dx:xhi corresponds to the token
%   x2  -|  (if string was empty, then xlo, dx, xhi all returned as NaN
%
%   n       Number of integers encoded in the token


token = strtrim(token);

% Catch case of empty token
if isempty(token)
    x1 = NaN; dx = NaN; x2 = NaN; n = 0; return
end

% Parse token
% Use str2double to turn character vectors into integers, because no character
% string can caus it to crash; something that is not a valid double array will
% return NaN. We can mop up all the non-integer results of parsing at the end
ind = strfind (token, ':');
switch numel(ind)
    case 0
        % No colon operators - the only valid possibilities are a single integer
        % or one of the non_matlab forms
        idash = strfind (token(2:end), '-') + 1;    % position of non-leading '-'
        switch numel(idash)
            case 0      
                % No non-leading '-'. The only valid possibility is a single integer
                x1 = str2double(token);
                x2 = x1;
                dx = 1;
            otherwise
                % At least one non-leading '-'. The only valid possibility is the
                % non-Matlab format x1-x2 (x1 and x2 could be -ve integers)
                x1 = str2double(token(1:idash(1)-1));
                x2 = str2double(token(idash(1)+1:end));
                if x2>=x1
                    dx = 1;
                else
                    dx = -1;
                end
        end
        
    case 1  % x1:x2
        x1 = str2double(token(1:ind-1));
        x2 = str2double(token(ind+1:end));
        dx = 1;
        
    case 2  % x1:dx:x2
        x1 = str2double(token(1:ind(1)-1));
        x2 = str2double(token(ind(2)+1:end));
        dx = str2double(token(ind(1)+1:ind(2)-1));
        
    otherwise
        error ('HERBERT:str_to_iarray:invalid_argument',...
            'Invalid format array descriptor found: %s', token)
end

% Perform checks
if isempty(dx) || ~finite_real_scalar(dx) || ~finite_real_scalar(x1) || ...
        ~finite_real_scalar(x2)
    error ('HERBERT:str_to_iarray:invalid_argument',...
        'Invalid format array descriptor, or Inf or NaN found in: %s', token)
end

if round(x1)~=x1 || round(dx)~=dx || round(x2)~=x2
    error ('HERBERT:str_to_iarray:invalid_argument',...
        'Non-integer terms found in array descriptor: %s', token)
end

if dx==0
    error ('HERBERT:str_to_iarray:invalid_argument',...
        'Zero size stride found in array descriptor: %s', token)
end

% Compute number of elements. Recall we ensure dx ~= 0
nstep = (x2-x1)/dx;
if nstep >= 0
    n = 1 + floor(nstep);
else
    n = 0;
end

%-------------------------------------------------------------------------------
function ok = finite_real_scalar(x)
ok = isscalar(x) && isfinite(x) && isreal(x);
