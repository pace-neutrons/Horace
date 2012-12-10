function [x, le_nmax] = str_to_iarray (str, nmax)
% Reads an array of integers from a character string, character array or cell array of strings
%
%   >> x = str_to_iarray (str)
%
% Input:
% ------
%   str     Character string, character array or cell array of strings
%           The contents of each string (or row in a character array) can be any number of delimited
%          single integers or ranges of integers as specified by the tokens '-' or ':'
%           e.g.
%               '34-30' => [34,33,32,31,30]
%               '-12--10' => [-12,-11,-10]
%               '-3--5' => [-3,-4,-5]
%           If a range is specified by the token ':', then the rules obeyed by matlab
%          array ranges are followed, for example 15:-13 is empty.
%           Thus the above examples are:
%               '34:30' => []
%               '-12:-10' => [-12,-11,-10]
%               '-3:-5' => []
%
%           If information is found on the string that does not conform to the above format
%          then the information will be ignored from that point onwards. This can be useful
%          for skipping comment information
%           e.g.  '34-36 ! some values' => [34,35,36]
%
%   nmax    [Optional] maximum number of integers to read. If there are more integers, then
%          these will be ignored.
%
% Output:
% -------
%   x       1 x n array of integers.
%
%   le_nmax Set to true if the input contained less than or equal to nmax integers
%           Is false if there were more than nmax integers in the input.
%           If nmax was not set, then le_nmax is returned as true.
%
% EXAMPLE
%
%   >> str_to_iarray('5:9,12-16 7 11 -4--7')
% ans =
%     5     6     7     8     9    12    13    14    15    16     7    11    -4    -5    -6    -7

% Check input arguments (input will be turned into one long string)
if ischar(str)
    sz=size(str);
    if isempty(str)
        x=[]; le_nmax=true; return
    elseif numel(sz)==2
        if sz(1)>1
            strtmp=reshape([str';repmat(' ',1,sz(1))],1,sz(1)*(sz(2)+1));  % make a single string
        else
            strtmp=str;
        end
    else
        error('Character arrays must be strings or two dimensional arrays')
    end
elseif iscellstr(str)
    len=zeros(1,numel(str));
    for i=1:numel(str)
        len(i)=numel(str{i});
    end
    if all(len==0)
        x=[]; le_nmax=true; return
    end
    cend=cumsum(len);
    cbeg=[1,cend(1:end-1)+1];
    strtmp=repmat(' ',1,cend(end)+numel(str)-1);
    for i=1:numel(str)
        strtmp(cbeg(i)+i-1:cend(i)+i-1)=str{i};
    end
else
    error('Input must be character string, two-dimensional character array or cellstr')
end

if nargin>1
    if nmax<1
        error('The maximum number of integers to be read must be greater or equal to unity (Default: +Inf)')
    end
else
    nmax=Inf;
end
        
% Find positions of tokens:
%  [Add final position, so that beg(i):beg(i+1) contains a token, including any trailing delimiters
%  which it turns out that sscanf happily ignores]
delim=[0,sort([strfind(strtmp,char(9)),strfind(strtmp,char(32)),strfind(strtmp,',')]),length(strtmp)+1];
beg=[delim(diff(delim)>1)+1,length(strtmp)+1];

ntok=numel(beg)-1;

% Catch case of no tokens
if ntok==0
    x=[]; le_nmax=true; return
end

% Parse each token in turn
xlo=zeros(1,ntok);
xhi=zeros(1,ntok);
n=zeros(1,ntok);
for i=1:ntok
    [xlo(i),xhi(i),n(i)]=str_token_to_iarray(strtmp(beg(i):beg(i+1)-1));
    if n(i)<0
        error('Check format of string contents')
    end
end

% Fill output array
nend=cumsum(n);
nbeg=[1,nend(1:end-1)+1];
if isfinite(nmax)
    if nend(ntok)>nmax
        le_nmax=false;
        ntok=lower_index(nend,nmax);    % find the number of tokens required to contain nmax integers
        nend(ntok)=nmax;                % update nend(ntok); we will ignore all later entries
        n(ntok)=nmax-nbeg(ntok)+1;
        if xhi(ntok)>xlo(ntok)
            xhi(ntok)=xlo(ntok)+n(ntok)-1;
        else
            xhi(ntok)=xlo(ntok)-n(ntok)+1;
        end
    else
        le_nmax=true;
    end
else
    le_nmax=true;
end

x=zeros(1,nend(ntok));
for i=1:ntok
    if n(i)>1
        x(nbeg(i):nend(i))=linspace(xlo(i),xhi(i),n(i));
    elseif n(i)==1
        x(nbeg(i))=xlo(i);
    end
end

%--------------------------------------------------------------------------------------------------
function [xlo,xhi,n] = str_token_to_iarray (string)
% Reads string and converts to integer row array. Valid strings have form
%        single integers: 'mmm', '-mmm'
%       list of integers: 'mmm-nnn', '-mmm-nnn', 'mmm--nnn', '-mmm--nnn'
%
% Matlab format:
%       list of integers: 'mmm:nnn', 'mmm:1:nnn', 'mmm:-1:nnn'
%
%       Interpretation follows matlab format e.g. 15:-13 is empty
%
%   If not a valid integer or integer list, then returns empty array []
%   If the first number in a pair is larger than the second, then a
%   list is created with the higher number first.
%
% e.g.   '34-30' => [34,33,32,31,30]
%      '-12--10' => [-12,-11,-10]
%        '-3--5' => [-3,-4,-5]

% Catch case of empty token
if isempty(string)
    xlo=[]; xhi=[]; n=0; return
end

% Parse token

% Check matlab formats
a=strfind(string,':-1:');
if ~isempty(a)
    xlotmp = sscanf(string(1:a(1)-1),'%d');
    xhitmp = sscanf(string(a(1)+4:end),'%d');
    [xlo,xhi,n]=check_range(xlotmp,xhitmp,false);
    return
end

a=strfind(string,':1:');
if ~isempty(a)
    xlotmp = sscanf(string(1:a(1)-1),'%d');
    xhitmp = sscanf(string(a(1)+3:end),'%d');
    [xlo,xhi,n]=check_range(xlotmp,xhitmp,true);
    return
end

a=strfind(string,':');
if ~isempty(a)
    xlotmp = sscanf(string(1:a(1)-1),'%d');
    xhitmp = sscanf(string(a(1)+1:end),'%d');
    [xlo,xhi,n]=check_range(xlotmp,xhitmp,true);
    return
end

% Check for non-matlab format for the token
a=strfind(string,'-');
a=a(a>1);        % array of positions of '-', excluding case of position 1
if ~isempty(a)
    xlotmp = sscanf(string(1:a(1)-1),'%d');
    xhitmp = sscanf(string(a(1)+1:end),'%d');
    [xlo,xhi,n]=check_range(xlotmp,xhitmp);
    return
end

% Must be single integer
xlotmp=sscanf(string,'%d');
if ~isempty(xlotmp) && isscalar(xlotmp)
    xlo=xlotmp; xhi=xlotmp;
    n=1;
else
    xlo=0; xhi=0; n=0;
end

%--------------------------------------------------------------------------------------------------
function [xlo,xhi,n]=check_range(xlotmp,xhitmp,pos_incr)
if isscalar(xlotmp) && isscalar(xhitmp)
    if nargin==2 || (xhitmp>=xlotmp && pos_incr) || (xhitmp<=xlotmp && ~pos_incr)
        xlo=xlotmp; xhi=xhitmp;
        n=abs(xhi-xlo)+1;
    else
        xlo=0; xhi=0; n=0;
    end
else
    xlo=0; xhi=0; n=-1;
end
