function data = read_cut_diff(file1,file2,ebars)
% Return the difference between two cut files as a cut object, with control over how error bars are handled
%
%   >> data = read_cut_diff(file1,file2)
%   >> data = read_cut_diff(file1,file2,ebars)
%
%   file1   First cut file. All the titles, labels etc. taken from this file.
%   file2   Second cut file
%   ebars  (Optional) 1x2 array to indicate how to treat error bars
%          e.g. [1,0] means treat error bars of file2 as zeros
%           Default is [1,1] i.e. use error bars from both files


% Get input files, prompting if not given
if ~exist('file1','var'), file1='*.cut'; end
[file1_full,ok,mess]=getfilecheck(file1);
if ~ok, error(mess), end

if ~exist('file','var'), file2='*.cut'; end
[file2_full,ok,mess]=getfilecheck(file2);
if ~ok, error(mess), end

% Read data
data1=cut(file1_full);
data2=cut(file2_full);

if ~exist('ebars','var')
    ebars=logical([1,1]);
elseif ~(isnumeric(ebars)||islogical(ebars)) || ~isvector(ebars) || length(ebars)~=2
    error('Check ebars option is vector length 2 containing only 0 or 1')
else
    ebars=logical(ebars);
end

% Check that the two files are commensurate
if ~all(data1.x==data2.x) ||...
   ~all(data1.npixels==data2.npixels) ||...
   ~all(all(data1.pixels(:,1:4)==data2.pixels(:,1:4)))
    error('Cut files do not have same number of points and same contributing pixels')
end

% Take difference between the cut files, looking after error bars appropriately
data=data1;     % pick up values from first dataset

data.y=data1.y-data2.y;    
data.pixels(:,5)=data1.pixels(:,5)-data2.pixels(:,5);
if all(ebars==[0,0])
    data.e=zeros(size(data.e));
    data.pixels(:,6)=0;
elseif all(ebars==[0,1])
    data.e=data2.e;
    data.pixels(:,6)=data2.pixels(:,6);
elseif all(ebars==[1,1])
    data.e=sqrt(data1.e.^2+data2.e.^2);
    data.pixels(:,6)=sqrt(data1.pixels(:,6).^2+data2.pixels(:,6).^2);
end
