function pix_out = noisify(obj, varargin)
%=========================================================================
% This is a method of the PixelData class.
% It is called from the noisify(sqw_object,[options]) function to allow
% the noisify functionality to be applied on a per-page basis to the
% sqw object's pixel data.
% See noisify(sqw_object,...) for details of the input and the
% Herbert noisify function for details of how the input is used.
% This noisify adds random noise to the object's signal array, and a fixed
% error bar to the variance array, paging as required. The options in
% varargin specify how that is done; see the above functions for details.
% For options where the signal absolute maximum is used in the noise
% scaling, a paged pre-scan of the signal provides the maximum over all
% pages.
%
% Input:
% -----
% obj         The PixelData instance.
% varargs     Options for random number distribution and noise magnitude
%             scaling.
%
% Output:
% ------
% pix_out     If specified, returns a "noisified" copy of the input data
%             Otherwise it is a reference to the input object, which is
%             "noisified" in place.
%=========================================================================

% Output specification determines object copying behaviour.
% Only perform the operation on a copy if a return argument exists,
% otherwise perform the operation on obj itself.
if nargout == 1
    pix_out = copy(obj);
else
    pix_out = obj;
end

uses_poisson_distribution = (   ...
       nargin==3 ...                            % only 3 args for poisson
    && ischar(varargin{1}) ...                  % arg is string
    && is_stringmatchi(varargin{1},'poisson')); % string is poisson

if ~(uses_poisson_distribution)
    % Other options than poisson require the signal maximum.
    max_sig = max(abs(pix_out.signal(:)));

    % tell the Herbert noisify that we are providing a max signal value
    % by appending it with its flag to varargin
    varargin{end+1} = 'maximum_value';
    varargin{end+1} = max_sig;
end

% page over pix_out noisifying each page using either Poisson or the max
% value extracted above
[pg_result_s, pg_result_e] = noisify( ...
    pix_out.signal, pix_out.variance, varargin{:});
pix_out.signal = pg_result_s;
pix_out.variance = pg_result_e;

end