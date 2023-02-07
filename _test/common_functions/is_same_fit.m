function ok = is_same_fit (fp_test, fp_ref, varargin)
% Determine if two sets of fit parameters are the same within errors
%
%   >> ok = is_same_fit (fp_test, fp2_ref)
%   >> ok = is_same_fit (fp_test, fp2_ref, tol)
%   >> ok = is_same_fit (fp_test, fp2_ref, tol, mask, bmask)
%
% Control comparison type with option 'ref', 'test', or 'both':
%   >> ok = is_same_fit (...,compare)
%
% Parameter values with zero standard deviation are ignored as being fixed
% parameters
%
% Input:
% ------
%   fp_test     Fit parameter structure from multifit to be testsed against
%               the reference dataset below
%
%   fp_ref      Reference fit parameter structure
%
%   tol         Tolerance [sigfac, abstol, reltol] (default: [1,0,0])
%                   sigfac  Agreement within factor of standard deviation
%                          defined by one or both of the fit parameter
%                          structures: sigfac * sqrt(sig1^2 + sig^2)
%                   abstol  Agreement to absolute amount
%                   reltol  Relative tolerance
%               If any of the requirements is met, then the test passes
%
%   mask        Logical mask of which parameters to compare
%                   e.g. [1,1,0,0,1] compare only parameters 1,2,and 5
%
%   bmask       Logical mask of which background parameters to compare
%
%   compare     Option to describe comparison
%                   'test'  sigfac applies to st. dev on parameters in fp_test
%                           abstol applies to parameters in fp_test only
%                           reltol applies to parameters in fp_test only
%
%                   'ref'   sigfac applies to st. dev on parameters in fp_ref
%                           abstol applies to parameters in fp_ref only
%                           reltol applies to parameters in fp_ref only
%
%                   'both'  sigfac applies to st. dev on parameters in fp_test
%                                  and fp_ref in quadrature
%                                  i.e. sigfac * sqrt(sig1^2 + sig2^2)
%                           abstol applies to parameters to in fp_test and fp_ref
%                                  i.e. max(abs(val1),abs(val2))
%                           reltol applies to parameters to in fp_test and fp_ref
%                                  i.e. reltol * max(abs(val1),abs(val2))
%
%               Default is 'ref'. This is because, for example, an erroneous
%               new fit couls have an anomolously huge standard deviation
%               on the parameter values that would mean that 'both' would
%               allow the test to pass, even if the parameter values were
%               wildly wrong.
%
% Output:
% -------
%   OK          True if all parameters are equal within tolerance


% Defaults for optional arguments
narg = numel(varargin);
if narg>0 && ischar(varargin{end})
    if strncmpi(compare,'test',numel(compare))
        compare = 'test';
    elseif strcmpi(compare,'ref',numel(compare))
        compare = 'ref';
    elseif strcmpi(compare,'both',numel(compare))
        compare = 'both';
    else
        error('is_same_fit:invalid_argument',...
            'Unrecognised value for optional parameter ''compare''')
    end
    narg = narg - 1;
else
    compare = 'ref';
end

if narg<1
    tol = [1,0,0];
else
    if isscalar(varargin{1})
        tol = [varargin{1},0,0];    % for legacy use before introduction of abstol and reltol
    else
        tol = varargin {1};
    end
end

if narg<2
    mask = [];
else
    mask = varargin{2};
end

if narg<3
    bmask = [];
else
    mask = varargin{3};
end

% Get parameters and st. dev for the two fit sets
[p, sig, fore_local_test, bp, bsig, back_local_test] = get_fitparams (fp_test);
[p_test,np_test] = make_vec(p);
[bp_test,nbp_test] = make_vec(bp);
p_test_all = [p_test, bp_test];
sig_test_all = [make_vec(sig), make_vec(bsig)];

[p, sig, fore_local_ref, bp, bsig, back_local_ref] = get_fitparams (fp_ref);
[p_ref,np_ref] = make_vec(p);
[bp_ref,nbp_ref] = make_vec(bp);
p_ref_all = [p_ref, bp_ref];
sig_ref_all = [make_vec(sig), make_vec(bsig)];

if ~all(np_test==np_ref)
    error('is_same_fit:invalid_argument',...
        'Different number of foreground parameters in the two fits being compared')
end
if ~all(nbp_test==nbp_ref)
    error('is_same_fit:invalid_argument',...
        'Different number of background parameters in the two fits being compared')
end
if xor(isempty(fore_local_test), isempty(fore_local_ref))
    error('is_same_fit:invalid_argument',...
        'There is no foreground model for one fit, but there is for the other')
elseif fore_local_test~=fore_local_ref
    error('is_same_fit:invalid_argument',...
        'The foreground model is global for one fit, local for the other')
end
if xor(isempty(back_local_test), isempty(back_local_ref))
    error('is_same_fit:invalid_argument',...
        'There is no background model for one fit, but there is for the other')
elseif back_local_test~=back_local_ref
    error('is_same_fit:invalid_argument',...
        'The background model is global for one fit, local for the other')
end

% Tolerance
if strcmp(compare,'test')
    tol_from_err = abs(tol(1)) * sig_test_all;
    tol_from_abs = abs(tol(2));
    tol_from_rel = abs(tol(3)) * abs(p_test_all);
elseif strcmp(compare,'ref')
    tol_from_err = abs(tol(1)) * sig_ref_all;
    tol_from_abs = abs(tol(2));
    tol_from_rel = abs(tol(3)) * abs(p_ref_all);
elseif strcmp(compare,'both')
    tol_from_err = abs(tol(1)) * sqrt(sig_test_all.^2 + sig_ref_all.^2);
    tol_from_abs = abs(tol(2));
    tol_from_rel = abs(tol(3)) * (max(abs(p_test_all), abs(p_ref_all)));
end
tol_max = max(tol_from_err,max(tol_from_abs,tol_from_rel));


% Mask parameters from comparison
% -------------------------------
if ~isempty(mask)
    [mask, nmask] = make_vec(mask);
    if ~isequal(np_test,nmask) && isscalar(nmask) && all(np_test==nmask)
        mask = repmat(mask, 1, numel(np_test));
    else
        error('is_same_fit:invalid_argument',...
            'The foreground parameter mask array is inconsistent with the fit parameters')
    end
else
    mask = true(1,sum(np_test));
end

if ~isempty(bmask)
    [bmask, nbmask] = make_vec(bmask);
    if ~isequal(nbp_test,nbmask) && isscalar(nbmask) && all(nbp_test==nbmask)
        bmask = repmat(bmask, 1, numel(nbp_test));
    else
        error('is_same_fit:invalid_argument',...
            'The foreground parameter mask array is inconsistent with the fit parameters')
    end
else
    bmask = true(1,sum(nbp_test));
end

keep=[logical(mask),logical(bmask)];

fixed = (sig_test_all==0 & sig_ref_all==0);     % assume zero st dev means the parameters were fixed
keep(fixed) = false;

% Perform comparison
bad = keep & (abs(p_test_all-p_ref_all) > tol_max);
ok = ~any(bad);
if ~ok
    % Display the parameters that fail
    disp (' ')
    disp (['tol_sig = ',num2str(tol(1)),'   tol_abs = ',num2str(tol(2)),...
        '    tol_rel = ',num2str(tol(3))])
    nptot = sum(np_test);
    nbptot = sum(nbp_test);
    disp('Parameters that fail test:')
    if nptot>0 && sum(bad(1:nptot))>0
        idataset = replicate_iarray(1:numel(np_test), np_test);
        iparam = sawtooth_iarray(np_test);
        disp (' Foreground')
        disp ([' Dataset param          test value                       ',...
            'reference value            absolute tol'])
        for i=1:numel(iparam)
            if bad(i)
                id = idataset(i);
                ip = iparam(i);
                val_test = p_test_all(i);
                sig_test = sig_test_all(i);
                val_ref = p_ref_all(i);
                sig_ref = sig_ref_all(i);
                tolval = tol_max(i);
                fprintf('%5d %5d %12.4g %s %-12.4g %s %12.4g %s %-12.4g %s %-12.4g %s %-12.4g\n',...
                    id, ip, val_test,'  +/-  ', sig_test,' ', val_ref,'  +/-  ', sig_ref,...
                    '    ', tolval,'    ', abs(val_test - val_ref)/tolval)
            end
        end
    end
    if nbptot>0 && sum(bad(nptot+1:nptot+nbptot))>0
        idataset = replicate_iarray(1:numel(nbp_test), nbp_test);
        iparam = sawtooth_iarray(nbp_test);
        disp (' ')
        disp (' Background')
        disp ([' Dataset param          test value                       ',...
            'reference value            absolute tol'])
        for i=1:numel(iparam)
            j = i + nptot;
            if bad(j)
                id = idataset(i);
                ip = iparam(i);
                val_test = p_test_all(j);
                sig_test = sig_test_all(j);
                val_ref = p_ref_all(j);
                sig_ref = sig_ref_all(j);
                tolval = tol_max(j);
                fprintf('%5d %5d %12.4g %s %-12.4g %s %12.4g %s %-12.4g %s %-12.4g %s %-12.4g\n',...
                    id, ip, val_test,'  +/-  ', sig_test,' ', val_ref,'  +/-  ', sig_ref,...
                    '    ', tolval,'    ', abs(val_test - val_ref)/tolval)
            end
        end
    end
end
end

%---------------------------------------------------------------------------
function [p, sig, fore_local, bp, bsig, back_local] = get_fitparams (fp)

if isfield(fp,'p')
    p=fp.p;
    sig=fp.sig;
    fore_local = iscell(fp.p);
else
    p=[];
    sig=[];
    fore_local = [];
end

if isfield(fp,'bp')
    bp=fp.bp;
    bsig=fp.bsig;
    back_local = iscell(fp.bp);
else
    bp=[];
    bsig=[];
    back_local = [];
end

end

%---------------------------------------------------------------------------
function [p, n] = make_vec(pin)
% If pin is a cell array, turn it into a numeric row vector
% Also return the number of element in each cell
if ~isempty(pin)
    if iscell(pin)
        p = cell2mat(pin);
        n = cellfun(@numel,pin);
    else
        p = pin;
        n = numel(p);
    end
else
    p = [];
    n = 0;
end

end
