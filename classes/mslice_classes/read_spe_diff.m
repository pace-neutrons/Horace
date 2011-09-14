function data = read_spe_diff(file1,file2,ebars)
% Return the difference between two spe files as an spe object, with control over how error bars are handled
%
%   >> data = read_spe_diff(file1,file2)
%   >> data = read_spe_diff(file1,file2,ebars)
%
%   file1   First spe file. All the titles, labels etc. taken from this file.
%   file2   Second spe file
%   ebars  (Optional) 1x2 array to indicate how to treat error bars
%          e.g. [1,0] means treat error bars of file2 as zeros
%           Default is [1,1] i.e. use error bars from both files

% Get input files, prompting if not given
if ~exist('file1','var'), file1='*.spe'; end
[file1_full,ok,mess]=getfilecheck(file1);
if ~ok, error(mess), end

if ~exist('file2','var'), file2='*.spe'; end
[file2_full,ok,mess]=getfilecheck(file2);
if ~ok, error(mess), end

% Read data
data1=spe(file1_full);
data2=spe(file2_full);

if ~exist('ebars','var')
    ebars=logical([1,1]);
elseif ~(isnumeric(ebars)||islogical(ebars)) || ~isvector(ebars) || length(ebars)~=2
    error('Check ebars option is vector length 2 containing only 0 or 1')
else
    ebars=logical(ebars);
end

% Check that the two files are commensurate
if ~all(size(data1.S)==size(data2.S)) || ~(all(size(data1.en)==size(data2.en)) && all(data1.en==data2.en))
    error('.spe files do not have same number of detectors and same energy bins')
end

% Take difference between the spe files, looking after error bars appropriately
data=data1;     % pick up values from first dataset

data.S=data1.S-data2.S;    
if all(ebars==[0,0])
    data1.ERR=zeros(size(data1.ERR));
elseif all(ebars==[0,1])
    data1.ERR=data2.ERR;
elseif all(ebars==[1,1])
    data1.ERR=sqrt(data1.ERR.^2+data2.ERR.^2);
end

% Put nulldata with 0 error bar in output data set for detectors masked in either of the datasets
index=isnan(data1.S)|isnan(data2.S);   % find masked detectors in one or both .spe files
data1.S(index)=NaN;
data1.ERR(index)=0;
