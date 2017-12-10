function [ok,mess]=equal_to_tol(w1,w2,varargin)
% Check if two sqw objects are equal to a given tolerance
%
%   >> ok = equal_to_tol (a, b)
%   >> ok = equal_to_tol (a, b, tol)
%   >> ok = equal_to_tol (..., keyword1, val1, keyword2, val2,...)
%   >> [ok, mess] = equal_to_tol (...)
%
% Class specific version of the generic equal_to_tol that by default
%   (1) assumes NaN are equivalent (see option 'nan_equal'), and
%   (2) ignores the order of pixels within a bin as the order is irrelevant
%       (change the default with option 'reorder')
%
% In addition, it is possible to check the contents of just a random
% fraction of non-empty bins (see option 'fraction') in order to speed up
% the comparison of large objects.
%
% Input:
% ------
%   w1,w2   Test objects (scalar objects, or arrays of objects with same sizes)
%
%   tol     Tolerance criterion for numeric arrays (Default: [0,0] i.e. equality)
%           It has the form: [abs_tol, rel_tol] where
%               abs_tol     absolute tolerance (>=0; if =0 equality required)
%               rel_tol     relative tolerance (>=0; if =0 equality required)
%           If either criterion is satified then equality within tolerance
%           is accepted.
%             Examples:
%               [1e-4, 1e-6]    absolute 1e-4 or relative 1e-6 required
%               [1e-4, 0]       absolute 1e-4 required
%               [0, 1e-6]       relative 1e-6 required
%               [0, 0]          equality required
%               0               equivalent to [0,0]
%
%           For backwards compatibility, a scalar tolerance can be given
%           where the sign determines absolute or relative tolerance
%               +ve : absolute tolerance  abserr = abs(a-b)
%               -ve : relative tolerance  relerr = abs(a-b)/max(abs(a),abs(b))
%             Examples:
%               1e-4            absolute tolerance, equivalent to [1e-4, 0]
%               -1e-6           relative tolerance, equivalent to [0, 1e-6]
%           [To apply an absolute as well as a relative tolerance with a
%            scalar negative value, set the value of the legacy keyword
%           'min_denominator' (see below)]
%
% Valid keywords are:
%  'nan_equal'      Treat NaNs as equal (true or false; default=true)
%
%  'ignore_str'     Ignore the length and content of strings or cell arrays
%                  of strings (true or false; default=false)
%
%  'reorder'        Ignore the order of pixels within each bin
%                  (true or false; default=true)
%                   Only applies if sqw-type object
%
%  'fraction'       Compare pixels in only a fraction of the non-empty bins
%                  (0<= fracton <= 1; default=1 i.e. test all bins)
%                   Only applies if sqw-type object
%
%  	The reorder and fraction options are available because the order of the
%   pixels within the pix array for a given bin is unimportant. Reordering
%   takes time, however, so the option to test on a few bins is given.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


if isa(w1,'sqw') && isa(w2,'sqw')
    % Check array sizes match
    if ~isequal(size(w1),size(w2))
        ok=false; mess='Sizes of sqw object arrays being compared are not equal'; return
    end
    % Check that corresponding objects in the array have the same type
    for i=1:numel(w1)
        if is_sqw_type(w1(i))~=is_sqw_type(w2(i))
            elmtstr=''; if numel(w1)>1, elmtstr=['(element ',num2str(i),')']; end
            ok=false;
            mess=['Objects being compared are not both sqw-type or both dnd-type ',elmtstr];
            return
        end
    end
    % Perform comparison
    sz = size(w1);
    for i=1:numel(w1)
        name_a = variable_name (inputname(1),false,sz,i,'input_1');
        name_b = variable_name (inputname(2),false,sz,i,'input_2');
        [ok,mess]=equal_to_tol_internal(w1(i),w2(i),name_a,name_b,varargin{:});
        if ~ok, return, end
    end
else
    ok=false; mess='One of the objects to be compared is not an sqw object'; return
end


%----------------------------------------------------------------------------------------
function [ok,mess]=equal_to_tol_internal(w1,w2,name_a,name_b,varargin)
% Compare scalar sqw objects of same type (sqw-type or dnd-type)

horace_info_level=get(hor_config,'log_level');

% Check for presence of reorder and/or fraction option(s) (only relevant if sqw-type)
opt=struct('reorder',true,'fraction',1);
flagnames={};
cntl.keys_at_end=false;
[args,opt,~,~,ok,mess]=parse_arguments(varargin,opt,flagnames,cntl);
if ~ok
    error(mess);
end
if ~islognumscalar(opt.reorder)
    error('''reorder'' must be a logical scalar (or 0 or 1)')
end
if ~isnumeric(opt.fraction) || opt.fraction<0 || opt.fraction>1
    error('''fraction'' must lie in the range 0 to 1 inclusive')
end

% Perform comparison
if (~opt.reorder && opt.fraction==1) || ~is_sqw_type(w1)
    % Test strict equality of all pixels; pass structures to get to the generic equal_to_tol
    [ok,mess]=equal_to_tol(struct(w1),struct(w2),args{:},'name_a',name_a,'name_b',name_b);
    
else
    % Test pixels in a fraction of non-empty bins, accounting for reordering of pixels
    % if required
    
    % Test all fields except pix array
    tmp1=struct(w1); tmp1.data.pix=0;
    tmp2=struct(w2); tmp2.data.pix=0;
    [ok,mess]=equal_to_tol(tmp1,tmp2,args{:},'name_a',name_a,'name_b',name_b);
    if ~ok, return, end
    
    % Check a subset of the bins with reordering
    npix=w1.data.npix(:);
    nend=cumsum(npix);  % we already know that w1.data.npix and w2.data.npix are equal
    nbeg=nend-npix+1;
    
    if opt.fraction>0 && any(npix==0)
        % Testing of bins requested and there is least one bin with more than one pixel
        % Get indices of bins to test
        ix=find(npix>0);
        if opt.fraction==1
            % All bins to be tested
            ibin=1:numel(npix);
        else
            % Test only a fraction of the non-empty bins
            ind=randperm(numel(ix));
            ind=ind(1:ceil(opt.fraction*numel(ix)));
            ibin=sort(ix(ind))';
        end
        if horace_info_level>=1
            disp(['                       Number of bins = ',num2str(numel(npix))])
            disp(['             Number of non-empty bins = ',num2str(numel(ix))])
            disp(['Number of bins that will be reordered = ',num2str(numel(ibin))])
            disp(' ')
        end
        % Now test contents for equality
        pix1=w1.data.pix;
        pix2=w2.data.pix;
        if opt.reorder
            for i=ibin
                s1=sortrows(pix1(:,nbeg(i):nend(i))')';
                s2=sortrows(pix2(:,nbeg(i):nend(i))')';
                [ok,mess]=equal_to_tol(s1,s2,args{:},'name_a',name_a,'name_b',name_b);
            end
        else
            for i=ibin
                s1=pix1(:,nbeg(i):nend(i));
                s2=pix2(:,nbeg(i):nend(i));
                [ok,mess]=equal_to_tol(s1,s2,args{:},'name_a',name_a,'name_b',name_b);
            end
        end
    end
    
end
