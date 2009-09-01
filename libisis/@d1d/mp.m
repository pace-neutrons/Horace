function mp(win,varargin)
%
% mp(win,varargin)
% Libisis mp command - multiplot data
% works for either a 2d dataset, or an array of 1d datasets.

% Optional inputs:
% mp(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'color','red'); etc
%
% see help for libisis\mp for more details of options
%
% R.A. Ewings 14/10/2008

for n=1:numel(win)
    nd(n)=dimensions(win(n));
end

if any(nd==0) || any(nd>=3)
    error('Error - mp only works for 2d datasets, or arrays of 1d datasets');
end

%check to see if all of the datasets in the array have the same
%dimensionality:
if all(nd~=nd(1))
    error('All elements of array must be datasets of the same dimensionality');
end

data1d=[]; data2d=[];

for n=1:numel(nd)
    if nd(n)==1
        data1d=[data1d IXTdataset_1d(win(n))];
    else
        data2d=[data2d IXTdataset_2d(win(n))];
    end
end

if nd==1
    mp(data1d,varargin{:});
else
    mp(data2d,varargin{:});
end

