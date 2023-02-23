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

if ~uses_poisson_distribution
    % Other options than poisson require the signal maximum.
    % As we are paging, we need to get the overall max signal out of pix_out
    % before applying noisify to the individual pages.
    max_sig = 0;

    for i = 1:pix_out.n_pages
        pix_out.page_num = i;
        max_sig_page = max(abs(pix_out.signal));
        max_sig = max(max_sig, max_sig_page);
    end

    % tell the Herbert noisify that we are providing a max signal value
    % by appending it with its flag to varargin
    varargin{end+1} = 'maximum_value';
    varargin{end+1} = max_sig;
end

% page over pix_out noisifying each page using either Poisson or the max
% value extracted above
pix_out = pix_out.get_new_handle();
s_ind = obj.check_pixel_fields('signal');
v_ind = obj.check_pixel_fields('variance');

for i = 1:pix_out.n_pages
    [obj, data] = load_page(i);
    [data(s_ind,:), data(v_ind, :)] = noisify( ...
        pix_out.signal, pix_out.variance, varargin{:});
    pix_out.format_dump_data(data);
end
pix_out = pix_out.finalise(fid);

pix_out = pix_out.recalc_data_range({'signal', 'variance'});

end
