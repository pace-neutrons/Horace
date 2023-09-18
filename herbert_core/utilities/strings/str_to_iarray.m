function [x, le_nmax] = str_to_iarray (str, nmax)
% Reads a row vector of integers from a character string, array or cell array
%
%   >> x = str_to_iarray (str)
%
% Input:
% ------
%   str     Character string, character array or cell array of strings
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
%     5     6     7     8     9    12    13    14    15    16     7    11    -4    -5    -6    -7


% Determine maximum number of integers to be read
if nargin == 1
    nmax = Inf;
else
    nmax = floor(nmax);
    if nmax < 1
        error('HERBERT:str_to_iarray:invalid_argument', ['The maximum number ',...
            'of integers to be read must be greater or equal to unity (Default: +Inf)'])
    end
end

% Check character data (input will be turned into one long string)
[ok, cout] = str_make_cellstr_trim (str);
if ~ok
    error('HERBERT:str_to_iarray:invalid_argument', ['The input data must be',...
        'a character string, character array or cellarray of strings'])
end

% Remove comment lines and trailing comments (first occurence of '%' or '!')
cout = cellfun(@strip_comment, cout, 'UniformOutput', false);
ok = ~cellfun(@isempty, cout);
cout = cout(ok);

% Remove brackets if has form '[...]'
cout = cellfun(@strip_square_brackets, cout, 'UniformOutput', false);
ok = ~cellfun(@isempty, cout);
cout = cout(ok);

% Concatenate all strings into one (with a leading space to ensure whitespace delimiter)
if ~isempty(cout)
    ctmp = cellfun(@(x)([' ', x]), cout, 'UniformOutput', false);
    strtmp = strcat(ctmp{:});
else
    strtmp = ' ';   % ensures output consistent with non-empty but no-integer string
end

% Find positions of tokens: 
% - delimiters are [<whitespace>],[<whitespace>] or <whitespace>
% - tokens run from iend(i)+1:ibeg(i+1)-1, but we must allow for the case of 
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
    le_nmax = true;  % nmax is guaranteed to be >= 1
    
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
    end
    
    x = NaN(1,nend(ntok));
    for i=1:ntok
        x(nbeg(i):nend(i)) = x1(i) + (0:n(i)-1) * dx(i);
    end
    le_nmax = (numel(x) <= nmax);
end


%-------------------------------------------------------------------------------
function cout = strip_comment (cin)
% Remove trailing comments and trim a character string
ind = [strfind(cin, '!'), strfind(cin, '%')];
if ~isempty(ind)
    cout =strtrim(cin(1:min(ind)-1));
else
    cout = cin;
end


%-------------------------------------------------------------------------------
function cout = strip_square_brackets (cin)
% Remove leading '[' and trailing ']' then trim a character string
if numel(cin)>=2 && cin(1)=='[' && cin(end)==']'
    cout = strtrim(cin(2:end-1));
else
    cout = cin;
end

%-------------------------------------------------------------------------------
function [x1, dx, x2, n] = str_token_to_iarray (token)
% Reads string and parses to elements of Matlab form in xlo:dx:xhi
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
%   xlo -|
%   dx   |- Integers such the array xlo:dx:xhi corresponds to the token
%   xhi -|  (if string was empty, then xlo, dx, xhi all returned as NaN
%
%   n       Number of integers encoded in the token


token = strtrim(token);

% Catch case of empty token
if isempty(token)
    x1 = NaN; dx = NaN; x2 = NaN; n = 0; return
end

% Parse token
ind = strfind (token, ':');
switch numel(ind)
    case 0  % no colon operators - single integer or non_matlab form
        idash = strfind (token(2:end), '-') + 1;    % position of non-leading '-'
        switch numel(idash)
            case 0      % Can only be a single integer
                x1 = str2double(token);
                x2 = x1;
                dx = 1;
            otherwise   % At least one non-leading '-'; try non-Matlab format x1-x2
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
if isempty(dx) || ~isfinite(dx) || ~isfinite(x1) || ~isfinite(x2)
    error ('HERBERT:str_to_iarray:invalid_argument',...
        'Invalid format array descriptor, Inf or NaN found in: %s', token)
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
