function str_out=iarray_to_str (val,varargin)
% Convert array of integers to cell array of strings suitable for writing to a text file.
%  - Consecutive increasing numbers M, M+1, M+2,...,N in the input array are written
%    as M-N in the cell string.
%  - Consecutive decreasing numbers M, M-1, M-2,...,N in the input array are also written
%    as M-N in the cell string.
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

% T.G.Perring 3 August 2010: Modified to work with -ve contiguous ranges

% Options
matlab_fmt=false;
if nargin>1
    if ischar(varargin{1}) && strcmpi(varargin{1},'m')
        matlab_fmt=true;
    else
        error('Check optional argumnet(s)')
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

% Reformat into similar length strings

% Make one string:
str=blanks(sum(lentmp));
clen=cumsum([0,lentmp]);
for i=1:length(strtmp)
    str(clen(i)+1:clen(i+1))=strtmp{i};
end

% Find points where 
lenlin=50;  % Minimum length of line
itoken_new=find(diff(isspace(str))==-1);  % elements immediately preceeding another token
ibrk=find(diff(mod(itoken_new,lenlin))<0);      % last element number on a line
if ~isempty(ibrk)
    ilinbeg=[1,itoken_new(ibrk)+1];
    ilinend=[itoken_new(ibrk),length(str)];
    str_out=cell(1,length(ibrk)+1);
    for i=1:length(ilinbeg)
        str_out{i}=strtrim(str(ilinbeg(i):ilinend(i)));
    end
else
    str_out{1}=strtrim(str);
end
