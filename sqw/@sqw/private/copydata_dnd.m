function dout = copydata_dnd (din, varargin)
% Overwrite the signal and errors from data in another object
%
% Signal and errors from numeric arrays:
%   >> dout = copydata (din, signal)            % errors set to zero
%   >> dout = copydata (din, signal, errors)
%
% Signal and error from an object
%   >> dout = copydata (din, object)
%
% Signal and error from different objects
%   >> dout = copydata (din, object_signal, object_errors)
%
% The input types can be mixed. Numeric arrays are scalar expanded if necessary.
% Set an argument to [] to leave the corresponding output unchanged:
%
%   >> dout = copydata (din, signal)        % signal changed, errors set to zero
%   >> dout = copydata (din, signal, [])    % signal changed, errors unchanged
%   >> dout = copydata (din, [], errors)    % signal unchanged, errors changed
%   
%
% Input:
% ------
%   din     Input dataset structure
%
%   signal  Numeric array with the signal to be copied
%
%   errors  [Optional] numeric array with the standard deviations to be copied
%
% *OR*
%
%   object  Object from which the signal and errors will be copied.
%           The object must have a method with name sigvar_get that satisfies the
%          following syntax:
%               [s,var,msk] = sigvar_get (object)
%             where
%               s       Signal array
%               var     Array of variances
%               msk     Mask array (true for elements that are not masked)
%
%
% Output:
% -------
%   dout    Output dataset structure


% Original author: T.G.Perring
%
% $Revision:: 1750 ($Date:: 2019-04-08 17:55:21 +0100 (Mon, 8 Apr 2019) $)

% numeric scalar
% numeric array with singleton dimenions
% numeric array
% object
% structure
% array of objects


dout = din;

narg = numel(varargin);
if narg==0
    % Case of no work to do
    return
    
elseif narg==1
    % Signal and error from one argument (s, e, msk, assumed to be consistently sized)
    [ok,mess,msk,s,e] = get_data (varargin{1},'se');
    if ~ok, error(mess); end
    if isscalar(s)
        s = s * ones(size(din.s));
        e = e * ones(size(din.s));
        msk = repmat(msk, size(din.s));
    end
    if isempty(s)   % nothing to do
        return
    end
    
elseif narg==2
    [ok,mess,msk_s,s] = get_data (varargin{1},'s');
    if ~ok, error(mess); end
    if isscalar(s)
        s = s * ones(size(din.s));
        msk_s = repmat(msk_s, size(din.s));
    elseif ~isempty(s) && ~isequal(size(s),size(din.s))
        error ('New signal array is incommensurate with existing data')
    end
    
    [ok,mess,msk_e,~,e] = get_data (varargin{2},'e');
    if ~ok, error(mess); end
    if isscalar(e)
        e = e * ones(size(din.s));
        msk_e = repmat(msk_e, size(din.s));
    elseif ~isempty(e) && ~isequal(size(e),size(din.e))
        error ('New error array is incommensurate with existing data')
    end
    
    if ~isempty(s) && ~isempty(e)
        msk = (msk_s & msk_e);
    elseif isempty(s) && ~isempty(e)
        msk = msk_e;
    elseif ~isempty(s) && isempty(e)
        msk = msk_s;
    else
        return  % nothing to do
    end
    
else
    error('Check number of arguments')
end

% Get rid of unwanted dimensions
msk = squeeze(msk);
msk = (msk & (din.npix~=0));

if ~isempty(s)
    s = squeeze(s);
    msk = (msk & ~isnan(s));    % signal NaN is considered masking
end

if ~isempty(e)
    if any(e(:)<0)
        error('One opr more new errors are less than zero')
    end
    e = squeeze(e);
    msk = (msk & ~isnan(e));    % error NaN is considered masking
end

% Mask the new signal with the mask value for sqw and dnd objects
if ~isempty(s)
    s(~msk) = 0;
    dout.s = s;
end
if ~isempty(e)
    e(~msk) = 0;
    dout.e = e;
end
dout.npix(~msk) = 0;


%--------------------------------------------------------------------------
function [ok,mess,msk,s,e] = get_data(val,type)
% Get signal and/or error from input
%
%   [ok,mess,msk,s,e] = get_data(val)
%
% Input:
% ------
%   val         Input argument
%   type        'se','s','e'
%
% Output:
% -------
%   ok          True if all OK
%   mess        Error mssage if not ok
%   msk         Mask array
%   s           Signal
%   e           Error

ok = true;
mess = '';
    
if isobject(val)
    if ismethod(val,'sigvar_get')
        [s,e,msk] = sigvar_get(val);
        if type=='e', s=[]; end
        if type=='s', e=[]; end
    else
        ok = false;
        mess = 'Object does not have method ''sigvar_get''';
        msk = false(0); s=[]; e=[];
    end
elseif isnumeric(val)
    if type=='se'
        s = val;
        e = zeros(size(val));
    elseif type=='s'
        s = val;
        e = [];
    elseif type=='e'
        s = [];
        e = val.^2;
    end
    msk = true(size(val));
elseif isempty(val)
    s = [];
    e = [];
    msk = true(0);
else
    ok = false;
    mess = 'Unrecognised data type from which to extract data';
    msk = false(0); s=[]; e=[];
end
