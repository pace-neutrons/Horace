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

pix_out = obj;
s_ind = obj.check_pixel_fields('signal');
v_ind = obj.check_pixel_fields('variance');


uses_poisson_distribution = (   ...
    nargin==3 ...                            % only 3 args for poisson
    && ischar(varargin{1}) ...                  % arg is string
    && is_stringmatchi(varargin{1},'poisson')); % string is poisson

if ~uses_poisson_distribution
    if ~pix_out.is_range_valid('signal')
        % Other options than poisson require the signal maximum.
        % As we are paging, we need to get the overall max signal out of pix_out
        % before applying noisify to the individual pages.
        max_sig = -inf;
        for i = 1:pix_out.num_pages
            pix_out.page_num = i;
            max_sig_page = max(abs(pix_out.signal));
            max_sig = max(max_sig, max_sig_page);
        end
    else
        range = pix_out.data_range;
        max_sig = range(2,s_ind);
    end
    % tell the Herbert noisify that we are providing a max signal value
    % by appending it with its flag to varargin
    varargin{end+1} = 'maximum_value';
    varargin{end+1} = max_sig;
end

% page over pix_out noisifying each page using either Poisson or the max
% value extracted above

% If we're being called from tests
if isempty(pix_out.file_handle_)
    pix_out = pix_out.get_new_handle();
end

pix_out.data_range = PixelDataBase.EMPTY_RANGE;

% TODO: #975 loop have to be moved level up calculating image in single
% loop too
num_pages = pix_out.num_pages;
for i = 1:num_pages
    pix_out.page_num = i;
    data = pix_out.data;
    [data(s_ind,:), data(v_ind, :)] = noisify(data(s_ind,:), data(v_ind,:), varargin{:});
    pix_out.data_range = ...
        pix_out.pix_minmax_ranges(data, pix_out.data_range);
    pix_out.format_dump_data(data);
end

pix_out = pix_out.finalise();

end
