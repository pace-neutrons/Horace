function [mbeg,mend]=iarray_contiguous_ranges(a)
% Find the first and last indicies of contiguous ranges in an integer array
%
%   >> [mbeg,mend]=iarray_contiguous_ranges(a)
%
% Works if sorted high-to-low as well as low-to-high.
% Ranges here include ranges of length unity.
% If the array is not sorted, then a choice has to be made
%   e.g. the array [10,11,12,11,10] could be considered [(10:12),11,10] or [10,11,(12:-1:10)]

% T.G.Perring, 2 August 2010

if numel(a)>1
    a=a(:)';    % make row
    % Find ranges of consecutive elements
    if all(sign(diff(a))>=0)        % sorted increasing
        diff_unity=[false,diff(a)==1,false];
        ibeg=find(diff(diff_unity)==1);   % those elements that start a series of consecutive elements
        iend=find(diff(diff_unity)==-1);  % those elements that end a series of consecutive elements
    elseif all(sign(diff(a))<=0)    % sorted decreasing
        diff_unity=[false,diff(a)==-1,false];
        ibeg=find(diff(diff_unity)==1);   % those elements that start a series of consecutive elements
        iend=find(diff(diff_unity)==-1);  % those elements that end a series of consecutive elements
    else
        % tough examples to check code:
        %   [4,5,7,9,11,12,13,14,13,12,8,6,4,4]
        %   [4,5,7,9,11,12,13,14,13,10,8,6,4,4]
        diff_unity=[0,diff(a),0];
        diff_unity(abs(diff_unity)~=1)=0;   % contains 0,1,-1
        del=diff(diff_unity);
        iminus2=find((del==-2));   % where increasing series turns into decreasing series
        del(iminus2)=del(iminus2)+1;
        del(iminus2+1)=del(iminus2+1)-1;
        iplus2=find((del==2));    % where decreasing series turns into increasing series
        del(iplus2)=del(iplus2)-1;
        del(iplus2+1)=del(iplus2+1)+1;
        ind=find(del~=0);
        ind=reshape(ind(:),[2,numel(ind)/2])';
        ibeg=ind(:,1)';
        iend=ind(:,2)';
    end
    % Now arrange to get ranges of single numbers too
    el_beg=([abs(diff(a))~=1,true])&([true,abs(diff(a))~=1]);    % those elements that are not part of a contiguous series
    el_end=el_beg;
    el_beg(ibeg)=true;  % add also those elements that start a contiguous range
    el_end(iend)=true;
    mbeg=find(el_beg);
    mend=find(el_end);
elseif numel(a)==1
    mbeg=1; mend=1;
elseif isempty(a)
    mbeg=[]; mend=[];
end
