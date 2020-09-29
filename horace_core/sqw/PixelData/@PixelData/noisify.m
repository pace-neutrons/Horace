function pix_out = noisify(obj, varargin)
% This is a method of the PixelData class.
% It is used to noisify this object's signal and variance arrays, paging as required.
%
% Input:
% -----
% obj         The PixelData instance.
% varargs     Here either 'poisson' or fac (see Herbert noisify for these,
%             to which they are passed on. Additional options to pass max
%             signal are added below.
%
if nargout == 1
    % Only do a copy if a return argument exists, otherwise perform the
    % operation on obj
    pix_out = copy(obj);
else
    pix_out = obj;
end

if ~(nargin==3 && ischar(varargin{1}) && is_stringmatchi(varargin{1},'poisson'))
    % as we are paging, we need to get the overall max signal out of pix_out
    % before applying noisify to the individual pages.
    % But only if we are not using Poisson. For Poisson the max is not used.
    max_sig = 0.0;
    pix_out.move_to_first_page();
    while true
        max_sig_page = max(abs(pix_out.signal(:)));
        max_sig = max(max_sig, max_sig_page);

        if pix_out.has_more()
            pix_out = pix_out.advance();
        else
            break;
        end
    end

    % tell the Herbert noisify that we are providing a max signal value
    % by appending it with its flag to varargin
    varargin{end+1} = 'maximum_value';
    varargin{end+1} = max_sig;
end

% page over pix_out noisifying each page using either Poisson or the max
% value extracted above
pix_out.move_to_first_page();
while true
    % This call is to the Herbert utilities/maths version of noisify, which
    % processes the (signal,error) data pair.
    [pg_result_s, pg_result_e] = noisify(pix_out.signal, pix_out.variance, varargin{:});
    pix_out.signal = pg_result_s;
    pix_out.variance = pg_result_e;

    if pix_out.has_more()
        pix_out = pix_out.advance();
    else
        break;
    end
end
