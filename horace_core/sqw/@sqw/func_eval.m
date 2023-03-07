function wout = func_eval (win, func_handle, pars, varargin)
% Evaluate a function at the plotting bin centres of sqw object or array
% of sqw objects
% Syntax:
%   >> wout = func_eval (win, func_handle, pars)
%   >> wout = func_eval (win, func_handle, pars, ['all'])
%   >> wout = func_eval (win, func_handle, pars, 'outfile', 'output.sqw')
%
% If function is called on sqw-type object (i.e. has pixels), the pixels'
% signal is also modified and evaluated
%
% Input:
% ======
%   win         Dataset or array of datasets; the function will be evaluated
%              at the bin centres along the plot axes
%
%   func_handle Handle to the function to be evaluated at the bin centres
%               Must have form:
%                   y = my_function (x1,x2,... ,xn,pars)
%
%               or, more generally:
%                   y = my_function (x1,x2,... ,xn,pars,c1,c2,...)
%
%               - x1,x2,.xn Arrays of x coordinates along each of the n dimensions
%               - pars      Parameters needed by the function
%               - c1,c2,... Any further arguments needed by the function e.g.
%                          they could be the filenames of lookup tables for
%                          resolution effects)
%
%               e.g. y=gauss2d(x1,x2,[ht,x0,sig])
%                    y=gauss4d(x1,x2,x3,x4,[ht,x1_0,x2_0,x3_0,x4_0,sig1,sig2,sig3,sig4])
%
%   pars        Arguments needed by the function.
%                - Most commonly just a numeric array of parameters
%                - If a more general set of parameters is needed by the function, then
%                  wrap as a cell array {pars, c1, c2, ...}
%
% Keyword Arguments:
%   outfile     If present, the output of func_eval will be written to the file
%               of the given name/path.
%               If numel(win) > 1, outfile must be omitted or a cell array of
%               file paths with equal number of elements as win.
%
% Additional allowed options:
%   'all'      Requests that the calculated function be returned over
%              the whole of the domain of the input dataset. If not given, then
%              the function will be returned only at those points of the dataset
%              that contain data.
%               Applies only to input with no pixel information - this option is ignored if
%              the input is a full sqw object.
%
% Output:
% =======
%   wout        Output objects or array of objects
%
% e.g.
%   >> wout = func_eval (w, @gauss4d, [ht,x1_0,x2_0,x3_0,x4_0,sig1,sig2,sig3,sig4])
%
%   where the function gauss appears on the matlab path
%           function y = gauss4d (x1, x2, x3, x4, pars)
%           y = (pars(1)/(sig*sqrt(2*pi))) * ...

% NOTE:
%   If 'all' then npix=ones(size of image) to ensure that the plotting is performed
%   Thus lose the npix information.

% Modified 15/10/2008 by R.A. Ewings:
% Modified the old d4d function to work with sqw objects of arbitrary
% dimensionality.
%
% Modified 09/11/2008 by T.G.Perring:
%  - Use nggridcell to make generic for dimensions greater than one
%  - Reinstate 'all' option
%  - Make output an sqw object with all pixels set equal to gid value. This is one
%    choice; another equally valid one is to say that the output should be dnd object,
%    i.e. lose pixel information. The latter is a little counter to the spirit that if that is
%    what was intended, then should have made a d1d,d2d,.. or whatever object before calling
%    func_eval
%       >>  wout = func_eval(dnd(win), func_handle, pars)
%    (note, if revert to latter, if array input then all objects must have same dimensionality)
%

[func_handle, pars, opts] = parse_funceval_args(win, func_handle, pars, varargin{:});

% Input sqw objects must have equal no. of dimensions in image or the input
% function cannot have the correct number of arguments for all sqws
% This block stops a "Too many input arguments." error being thrown later on
if numel(win) > 1
    input_dims = arrayfun(@(x) dimensions(x), win);
    if any(input_dims(1) ~= input_dims)
        error('HORACE:sqw:invalid_argument', ...
            ['Input sqw objects must have equal image dimensions.\n' ...
            'Found dimensions [%s].'], ...
            num2str(input_dims));
    end
end

wout = cell(1,numel(win));
%

% Check if any objects are zero dimensional before evaluating function
if any(arrayfun(@(x) (x.dimensions()==0), win))
    error( ...
        'HORACE:sqw:invalid_argument', ...
        'func_eval not supported for zero dimensional objects.' ...
        );
end
if numel(opts.outfile) < numel(win)
    out_tmp_file = gen_unique_file_paths( ...
        numel(win), 'horace_func_eval', tmp_dir(), 'tmp');
    opts.outfile = out_tmp_file;
    empty_outfile = true;
else
    empty_outfile = false;
end

% Evaluate function for each element of the array of sqw objects
for i = 1:numel(win)    % use numel so no assumptions made about shape of input array
    sqw_type=has_pixels(win(i));   % determine if sqw or dnd type
    if sqw_type
        opts.all = false;
    end
    wout_i = win(i);
    wout_i.data = func_eval(win(i).data,func_handle, pars,opts);
    %

    % If sqw object, fill every pixel with the value of its corresponding bin
    if sqw_type
        if ~wout_i.pix.is_filebacked
            s = repelem(wout_i.data.s(:), wout_i.data.npix(:));
            wout_i.pix.signal = s;
            wout_i.pix.variance = zeros(size(s));
        else
            out_file = opts.outfile{i};
            wout_i = write_sqw_with_out_of_mem_pix(wout_i,out_file);
        end
    elseif opts.all
        % in this case, must set npix>0 to be plotted
        wout_i.data.npix=ones(size(wout_i.data.npix));
    end

    % Save to file if outfile argument is given
    if ~empty_outfile && ~opts.filebacked
        save(wout_i, opts.outfile{i});
    end
    if opts.filebacked
        % Return file names so we're not leaking file-backed objects
        out_file = opts.outfile{i};
        if ~wout_i.pix.is_filebacked
            save(wout_i, out_file);
        end
        wout{i} = out_file;
    else
        wout{i} = wout_i;
    end
end  % end loop over input objects
% form desired output
if numel(wout) == 1
    wout = wout{1};
else
    is_sqw = cellfun(@(x)isa(x,'sqw'),wout);
    if all(is_sqw)
        wout = [wout{:}];
        wout = reshape(wout,size(win));
    end
end

% -----------------------------------------------------------------------------
function sqw_obj = write_sqw_with_out_of_mem_pix(sqw_obj, outfile)
% Write the given SQW object to the given file.
% The pixels of the SQW object will be derived from the image signal array
% and npix array, saving in chunks so they do not need to be held in memory.
%
sqw_obj.full_filename = outfile;
ldr = sqw_formats_factory.instance().get_pref_access(sqw_obj);
ldr = ldr.init(sqw_obj, outfile);
ldr = ldr.put_sqw('-nopix');
ldr = write_out_of_mem_pix(sqw_obj.pix, sqw_obj.data.npix, sqw_obj.data.s, ldr);
sqw_obj = sqw(ldr);
ldr.delete();



function facc = write_out_of_mem_pix(pix, npix, img_signal, facc)
% Smear the given image signal values over a file-backed PixelData object
% Set each pixel's signal to the value of the average signal of the bin
% that pixel belongs to. Set all variances to zero.
%

[npix_chunks, idxs] = split_vector_fixed_sum(npix(:), pix.DEFAULT_PAGE_SIZE);
n_pages = pix.num_pages;
data_range = PixelDataBase.EMPTY_RANGE;
pix_pos = 1;
pix_out = PixelDataMemory();
for i=1:n_pages
    pix.page_num = i;
    npix_chunk = npix_chunks{i};
    idx = idxs(:, i);
    pix_out.data = pix.data;

    pix_out.signal = repelem(img_signal(idx(1):idx(2)), npix_chunk);
    pix_out.variance = 0;
    data_range = [min(data_range(1,:),pix_out.data_range(1,:));...
        max(data_range(2,:),pix_out.data_range(2,:))];

    facc= facc.put_raw_pix(pix_out.data,pix_pos);
    pix_pos = pix_pos + pix.page_size;

end
pix.data_range = data_range;
facc = facc.put_pix_metadata(pix);
