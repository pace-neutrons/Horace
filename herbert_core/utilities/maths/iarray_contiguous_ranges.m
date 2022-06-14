function [mbeg,mend]=iarray_contiguous_ranges(iarr)
% Find the first and last indicies of contiguous ranges in an integer array
%
%   >> [mbeg,mend]=iarray_contiguous_ranges(iarr)
%
% Input:
% ------
%   iarr    Array of integers (need not be sorted)
%
% Output:
% -------
%   mbeg    Indicies of first element in a range of contiguous integers
%   mend    Indicies of final element of the ranges
%
% A contiguous range of integers means a sequence  i,i+1,i+2,...i+|n|
% or  i,i-1,i-2,...,i-|n|. The sequence i,i,i,...i  is treated as any
% other set of isolated integers. Isolated integers are treted as ranges
% of length unity i.e. mbeg(j)==mend(j).
%
% Note:
% In the case when an increasing series turns into decreasing series or vice versa
% the shared integer is considered part of the first sequence
%   e.g. the array [10,11,12,11,10,9] becomes [10:12, 11:-1:9]

% T.G.Perring, 2 August 2010
% T.G.Perring, 10 October 2012   Revised to correct error that can occur if not a sorted array.

if numel(iarr)>1
    iarr=iarr(:)';    % make row
    % Find ranges of consecutive elements
    % tough examples to check code:
    %   [4,5,7,9,11,12,13,14,13,12,8,6,4,4]
    %   [4,5,7,9,11,12,13,14,13,10,8,6,4,4]
    %   [4,3,4]   [4,5,4]   [4,5,4,4]
    diff_unity=[0,diff(iarr),0];
    diff_unity(abs(diff_unity)~=1)=0;   % contains 0,1,-1
    del=diff(diff_unity);
    incr=sign(diff(iarr));
    if ~all(incr)>=0 || ~all(incr)<=0
        iminus2=find((del==-2));   % where increasing series turns into decreasing series
        del(iminus2)=del(iminus2)+1;
        del(iminus2+1)=del(iminus2+1)-1;
        iplus2=find((del==2));    % where decreasing series turns into increasing series
        del(iplus2)=del(iplus2)-1;
        del(iplus2+1)=del(iplus2+1)+1;
    end
    if isa(del,'double')    % cumsum doesn't work for integer type (at least for R2012a and earlier releases)
        parity=cumsum(del);
    else
        parity=cast(cumsum(double(del)),class(del));
    end
    mbeg=find(parity==del);
    mend=find(parity==0);
elseif numel(iarr)==1
    mbeg=1; mend=1;
elseif isempty(iarr)
    mbeg=[]; mend=[];
end
