function str_out=iarray_to_str (val,varargin)
% Convert array of integers to cell array of strings suitable for writing to a text file.
%
%   >> str_out=iarray_to_str (val)
%   >> str_out=iarray_to_str (val,lenlin)
%   >> str_out=iarray_to_str (...,'m')
%
%  - Consecutive increasing numbers M, M+1, M+2,...,N in the input array are written
%    as M-N in the cell string.
%  - Consecutive decreasing numbers M, M-1, M-2,...,N in the input array are also written
%    as M-N in the cell string.
%  - Default minimum string length is 50 characters; can change this to desired value.
%    Set lenlin=0 to have only one contiguous range per line.
%  - Use the option 'm' to write in matlab array assignment format
%
% e.g. 
%   >> iarray_to_str([-5,-4,-3,21,20,19,5,7,9,10,11,12])
%   ans = 
%       '-5--3  21-19 5  7 9-12'
%
%   >> iarray_to_str([-5,-4,-3,21,20,19,5,7,9,10,11,12],'m')
%   ans = 
%       '-5:-3  21:-1:19 5  7 9:12'

% T.G.Perring 3 August 2010: Modified to work with decreasing contiguous ranges

% Options
lenlin=50;  % Default minimum length of line
matlab_fmt=false;
narg=numel(varargin);
if narg>=1
    if ischar(varargin{narg}) && strcmpi(varargin{narg},'m')
        matlab_fmt=true;
        narg=narg-1;
    end
    if narg==1 && isnumeric(varargin{1}) && isscalar(varargin{1}) && varargin{1}>=0
        lenlin=varargin{1};
    elseif narg~=0
        error('Check number and type of optional argument(s)')
    end
end

% Trivial case of empty array
if isempty(val)
    str_out='';
    return
end

% Make input an integer row vector
val=round(val(:)');

% Find ranges of consecutive elements
[ibeg,iend]=iarray_contiguous_ranges(val);
ind=find(iend-ibeg+1>1);    % find ranges of at least two consecutive numbers
ibeg=ibeg(ind);
iend=iend(ind);

% Find ranges of elements not part of a consecutive sequence
if ~isempty(ibeg)   % at least one block of consecutive numbers
    % Allow for the possibility of non-contiguous range at the very beginiing and end of the array
    istart=[1,1+iend];
    ifinish=[ibeg-1,length(val)];
    strtmp=cell(1,1+2*length(ibeg));    % Create temporary cellstr to hold output
    lentmp=zeros(size(strtmp));
else    % no consecutive numbers
    istart=1;
    ifinish=length(val);
    strtmp=cell(1);
end

% Write to strings:
% Get an extra space between strings containing contiguous blocks even if they are not separated by non-conguous blocks
% (Do not bother catching this case because get multiple spaces from int2str anyway)
for i=1:length(istart)
    if istart(i)<=ifinish(i)
        strtmp{2*i-1}=[int2str(val(istart(i):ifinish(i))),' '];
        lentmp(2*i-1)=length(strtmp{2*i-1});
    else
        strtmp{2*i-1}=' ';
        lentmp(2*i-1)=1;
    end
    if i~=length(istart)
        if iend(i)-ibeg(i)~=1
            if ~matlab_fmt
                strtmp{2*i}=[int2str(val(ibeg(i))),'-',int2str(val(iend(i))),' '];
                lentmp(2*i)=length(strtmp{2*i});
            else
                if val(ibeg(i))<val(ibeg(i)+1)
                    strtmp{2*i}=[int2str(val(ibeg(i))),':',int2str(val(iend(i))),' '];
                else
                    strtmp{2*i}=[int2str(val(ibeg(i))),':-1:',int2str(val(iend(i))),' '];
                end
                lentmp(2*i)=length(strtmp{2*i});
            end
        else   % only two numbers in the consecutive range
            strtmp{2*i}=[int2str([val(ibeg(i)),val(iend(i))]),' '];
            lentmp(2*i)=length(strtmp{2*i});
        end
    end
end

% Make one string:
str=blanks(sum(lentmp));
clen=cumsum([0,lentmp]);
for i=1:length(strtmp)
    str(clen(i)+1:clen(i+1))=strtmp{i};
end

% Find points where equal or exceed minimum line length
ctokb=find(diff(isspace(str))==-1)+1;       % elements at beginning of tokens
ctoke=find(diff(isspace(str))==1);          % elements at end of tokens
if ~isspace(str(1)), ctokb=[1,ctokb]; end   % catch case of first token starting at beginning of string
if ~isspace(str(end)), ctoke=[ctoke,numel(str)]; end    % catch case of last token filling to end of string

itoklin=upper_index(ctoke,ctokb+lenlin-1);
ntok=numel(ctokb);
itokbeg=false(1,ntok);
i=1;
while i<=ntok
    itokbeg(i)=true;
    i=max(i,itoklin(i))+1;  % ensure that contains at least one token
end
ilinbeg=find(itokbeg);
ilinend=[ilinbeg(2:end)-1,ntok];

nlin=numel(ilinbeg);
str_out=cell(1,nlin);
for i=1:nlin
    str_out{i}=str(ctokb(ilinbeg(i)):ctoke(ilinend(i)));
end
