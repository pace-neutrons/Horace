function [ok,mess]=equal_to_tol(w1,w2,varargin)
% Check if two sqw objects are equal to a given tolerance
%
%   >> ok=equal_sqw_to_tol(w1,w2)
%   >> ok=equal_sqw_to_tol(w1,w2,tol)
%   >> ok=equal_to_tol(...,keyword1,val1,keyword2,val2,...)
%   >> [ok,mess]=equal_to_tol(...)
%
% Class specific version of the generic equal_to_tol that adds an extra
% option to allow the test to pass with resorting of pixels within a bin.
%
% Input:
% ------
%   w1      First sqw object for comparison
%   w2      Second sqw object for comparison
%   tol     tolerance (default: equality required)
%               +ve number: absolute tolerance  abserr = abs(a-b)
%               -ve number: relative tolerance  relerr = abs(a-b)/max(abs(a),abs(b))
%
% Valid keywords (which if present require a value to be given) are:
%  'nan_equal'       Treat NaNs as equal (true or false; default=true)
%  'min_denominator' Minimum denominator for relative tolerance calculation (>=0; default=0)
%                   When the denominator in a relative tolerance is less than this value, the
%                   denominator is replaced by this value. Use this when the numbers being
%                   compared could be close to zero.
%  'ignore_str'      Ignore the length and content of strings or cell arrays of strings
%                   (true or false; default=false)
%
%  'reorder'        If reorder is present, then tests with reordering of the pixels
%                  within a bin, checking only a fraction of non-empty bins
%                  given by the value of reorder (0=< reorder =<1)
%                   - test all bins with pixel reordering: ...,'reorder',1,...
%                   - do no testing of pixels:             ...,'reorder',0,...
%
%                   The reorder option is available because the order of the pixels within
%                  the pix array for a given bin is unimportant. Reordering takes time,
%                  however, so the option to test on a few bins is given.


% Original author: T.G.Perring
%
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)


horace_info_level=get(hor_config,'horace_info_level');

if isa(w1,'sqw') && isa(w2,'sqw') && (is_sqw_type(w1)==is_sqw_type(w2))
    opt=struct('reorder',1);
    [args,opt,present,filled,ok,mess]=parse_args_simple(varargin,opt);
    if ~ok
        error(mess);
    end
    
    if ~present.reorder || ~is_sqw_type(w1)
        % Test strict equality; pass structures to get to the generic equal_to_tol
        [ok,mess]=equal_to_tol(struct(w1),struct(w2),args{:});
        
    else
        % Test pixels in a fraction of non-empty bins, accounting for reordering of pixels
        
        % Test all except pix array
        tmp1=struct(w1); tmp1.data.pix=0;
        tmp2=struct(w2); tmp2.data.pix=0;
        [ok,mess]=equal_to_tol(tmp1,tmp2,args{:});
        if ~ok, return, end
        
        % Check a subset of the bins with reordering
        npix=w1.data.npix(:);
        nend=cumsum(npix);
        nbeg=nend-npix+1;
        
        if opt.reorder>1 || opt.reorder<0
            error('Check value of ''reorder''')
        elseif opt.reorder==0 || all(npix==0)
            return                  % no bins
        else
            pix1=w1.data.pix;
            pix2=w2.data.pix;
            ix=find(npix>0);
            if opt.reorder==1
                ibin=1:numel(npix); % all bins
            else
                ind=randperm(numel(ix));
                ind=ind(1:ceil(opt.reorder*numel(ix)));
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
                [ok,mess]=equal_to_tol(s1,s2,args{:});
            end
        end
        
        % Fail if the comparison failed the test and no output arguments
        if nargout==0
            error(mess)
        end
        
    end
    
else
    % One of the two objects is not an sqw object
    error('One of the objects to be compared is not an sqw object, or they are not both sqw-type or both dnd-type')
end
