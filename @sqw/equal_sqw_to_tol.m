function [ok,mess]=equal_sqw_to_tol(w1,w2,tol,reorder)
% Check if two sqw objects are equal to a given tolerance
%
%   >> ok=equal_sqw_to_tol(w1,w2,tol)
%   >> ok=equal_sqw_to_tol(w1,w2,tol,reorder)
%
% Input:
% ------
%   w1      First sqw object for comparison
%   w2      Second sqw object for comparison
%   tol     Acceptable tolerance on numeric quantities: relative or absolute
%          tolerance, whichever is more forgiving i.e.
%               - relative tolerance on v1 and v2 if max(abs(v1),abs(v2))>1
%               - absolute tolerance otherwise
% Optional:
%   reorder If reorder is present, then tests with reordering of the pixels
%           within a bin, checking for a fraction of non empty bins
%           given by the value of reorder (0=< reorder =<1)
%
% Ignores the values of strings in the comparison.
%
% The reorder option is available because the order of the pixels within
% the pix array for a given bin is unimportant. Reordering takes time,
% however, so the option to test on a few bins is given. To test the contents
% of all bins with reordering, specify the value reorder=1.


% Original author: T.G.Perring
%
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)


horace_info_level=get(hor_config,'horace_info_level');

if nargin==3
    [ok,mess]=equal_to_tol(struct(w1),struct(w2),-abs(tol),'min_denominator',1,'ignore_str',1);
else
    tmp1=struct(w1); tmp1.data.pix=0;
    tmp2=struct(w2); tmp2.data.pix=0;
    [ok,mess]=equal_to_tol(tmp1,tmp2,-abs(tol),'min_denominator',1,'ignore_str',1);
    if ~ok, return, end
    npix=w1.data.npix(:);
    nend=cumsum(npix);
    nbeg=nend-npix+1;
    pix1=w1.data.pix;
    pix2=w2.data.pix;
    % Check a subset of the bins with reordering
    if reorder>1 || reorder<0
        error('Check value of ''reorder''')
    elseif reorder==0 || all(npix==0)
        return                  % no bins
    else
        ix=find(npix>0);
        if reorder==1
            ibin=1:numel(npix); % all bins
        else
            ind=randperm(numel(ix));
            ind=ind(1:ceil(reorder*numel(ix)));
            ibin=sort(ix(ind))';
        end
        if horace_info_level>=1
            disp(['                       Number of bins = ',num2str(numel(npix))])
            disp(['             Number of non-empty bins = ',num2str(numel(ix))])
            disp(['Number of bins that will be reordered = ',num2str(numel(ibin))])
            disp(' ')
        end
        for i=ibin
            s1=sortrows(pix1(:,nbeg(i):nend(i))');
            s2=sortrows(pix2(:,nbeg(i):nend(i))');
            [ok,mess]=equal_to_tol(s1,s2,-abs(tol),'min_denominator',1,'ignore_str',1);
        end
    end
    
end
