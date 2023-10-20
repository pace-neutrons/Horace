function wout = noisify(w,varargin)
%=========================================================================
% Adds random noise to the signal(s) of an sqw object or array of sqw
% objects, together with an additional fixed error bar. Sqw objects are
% noisified through their paged PixelData sub-objects. Alternatively
% noisifies a dnd object or array of such objects directly.
%
% Syntax:
%   >> wout = noisify (w)
%           Add noise with Gaussian distribution, with standard deviation
%           = 0.1*(maximum pixel signal value)
%
%   >> wout = noisify (w,factor);
%           Add noise with Gaussian distribution, with standard deviation
%           = factor*(maximum pixel signal value)
%
%   >> wout = noisify (w,'poisson');
%           Add noise with Poisson distribution, where the mean value at
%           a point is the value of pixel signal.
%
%
% Additional developer options are possible in varargin to test this
% functionality. See the PixelData noisify paging method (called below)
% and the Herbert noisify function which implements the noise addition.
%=========================================================================
%
%
% TODO: Re #1320 outfile for filebacked operations should be supported

wout=copy(w);
page_op = PageOp_noisify();
for i=1:numel(w)
    if has_pixels(w(i))   % determine if sqw or dnd type
        page_op = page_op.init(wout(i),varargin{:});
        if ~page_op.noisify_par.is_poisson
            if ~wout(i).pix.is_range_valid('signal')
                % Other options than Poisson require the signal maximum.
                % As we are paging, we need to get the overall max signal out of pix_out
                % before applying noisify to the individual pages.
                is_old_file = wout(i).pix.old_file_format;
                page_op.print_range_warning(wout(i).full_filename,is_old_file);
                wout(i) = wout(i).recompute_bin_data();
            end
            range = wout(i).pix.data_range;
            max_sig = range(2,PixelDataBase.field_index('signal'));
            page_op.noisify_par.ymax = max_sig;
        end
        wout(i) = wout(i).apply_op(page_op);
    else
        % Noisify the dnd data directly with the Herbert noisify.
        [wout(i).data.s,wout(i).data.e]=noisify(w(i).data.s,w(i).data.e,varargin{:});
    end
end
