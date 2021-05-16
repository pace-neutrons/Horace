function wout = func_eval (win, func_handle, pars, varargin)
% Evaluate a function at the plotting bin centres of sqw object or array of sqw object
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

[func_handle, pars, opts] = parse_args(win, func_handle, pars, varargin{:});

% Input sqw objects must have equal no. of dimensions in image or the input
% function cannot have the correct number of arguments for all sqws
% This block stops a "Too many input arguments." error being thrown later on
if numel(win) > 1
    input_dims = arrayfun(@(x) dimensions(x), win);
    if any(input_dims(1) ~= input_dims)
        error(...
            'SQW:func_eval:unequal_dims', ...
            ['Input sqw objects must have equal image dimensions.\n' ...
             'Found dimensions [%s].'], ...
            num2str(input_dims) ...
        );
    end
end

wout = copy(win);
% This has not been implemented but should
% for i=1:numel(wout)
%     if isa(wout(i),'sqw')
%         if wout(i).data.pix.is_filebacked()
%             opts.filebacked = true;
%             break
%         end
%     end
% end

% Check if any objects are zero dimensional before evaluating function
if any(arrayfun(@(x) isempty(x.data_.pax), win))
    error( ...
        'SQW:func_eval:zero_dim_object', ...
        'func_eval not supported for zero dimensional objects.' ...
    );
end

% Evaluate function for each element of the array of sqw objects
for i = 1:numel(win)    % use numel so no assumptions made about shape of input array
    sqw_type=has_pixels(win(i));   % determine if sqw or dnd type
    ndim=length(win(i).data_.pax);
    if sqw_type || ~opts.all        % only evaluate at the bins actually containing data
        ok=(win(i).data_.npix~=0);   % should be faster than isfinite(1./win.data_.npix), as we know that npix is zero or finite
    else
        ok=true(size(win(i).data_.npix));
    end
    % Get bin centres
    pcent=cell(1,ndim);
    for n=1:ndim
        pcent{n} = 0.5 * (win(i).data_.p{n}(1:end-1) + win(i).data_.p{n}(2:end));
    end
    if ndim>1
        pcent=ndgridcell(pcent);%  make a mesh; cell array input and output
    end
    for n=1:ndim
        pcent{n}=pcent{n}(:);   % convert into column vectors
        pcent{n}=pcent{n}(ok);  % pick out only those bins at which to evaluate function
    end

    % Evaluate function
    wout(i).data_.s(ok) = func_handle(pcent{:},pars{:});
    wout(i).data_.e = zeros(size(win(i).data_.e));

    % If sqw object, fill every pixel with the value of its corresponding bin
    if sqw_type
        if ~opts.filebacked
            s = repelem(wout(i).data_.s(:), win(i).data_.npix(:));
            wout(i).data_.pix.signal = s;
            wout(i).data_.pix.variance = zeros(size(s));
        else
            write_sqw_with_out_of_mem_pix(wout(i), opts.outfile{i});
        end
    elseif opts.all
        % in this case, must set npix>0 to be plotted
        wout(i).data_.npix=ones(size(wout(i).data_.npix));
    end

    % Save to file if outfile argument is given
    if ~isempty(opts.outfile) && ~isempty(opts.outfile{i}) && ~opts.filebacked
        save(wout(i), opts.outfile{i});
    end
end  % end loop over input objects

if opts.filebacked
    % Return file names so we're not leaking file-backed objects
    if numel(opts.outfile) > 1
        wout = opts.outfile;
    else
        wout = opts.outfile{1};
    end
end

end  % function


% -----------------------------------------------------------------------------
function [func_handle, pars, opts] = parse_args(win, func_handle, pars, varargin)
    [~, ~, all_flag, args] = parse_char_options(varargin, {'-all'});

    parser = inputParser();
    parser.addRequired('func_handle', @(x) isa(x, 'function_handle'));
    parser.addRequired('pars');
    parser.addParameter('outfile', {}, @(x) iscellstr(x) || ischar(x) || isstring(x));
    parser.addParameter('all', all_flag, @islognumscalar);
    parser.addParameter('filebacked', false, @islognumscalar);
    parser.parse(func_handle, pars, args{:});
    opts = parser.Results;

    if ~iscell(opts.pars)
        opts.pars = {opts.pars};
    end
    if ~iscell(opts.outfile)
        opts.outfile = {opts.outfile};
    end

    outfiles_empty = all(cellfun(@(x) isempty(x), opts.outfile));
    if ~outfiles_empty && (numel(win) ~= numel(opts.outfile))
        error( ...
            'HORACE:SQW:invalid_arguments', ...
            ['Number of outfiles specified must match number of input objects.\n' ...
             'Found %i outfile(s), but %i sqw object(s).'], ...
            numel(opts.outfile), numel(win) ...
        );
    end
    if outfiles_empty && opts.filebacked
        opts.outfile = gen_unique_file_paths( ...
            numel(win), 'horace_func_eval', tmp_dir(), 'sqw' ...
        );
    end

    func_handle = opts.func_handle;
    pars = opts.pars;
end


function write_sqw_with_out_of_mem_pix(sqw_obj, outfile)
    % Write the given SQW object to the given file.
    % The pixels of the SQW object will be derived from the image signal array
    % and npix array, saving in chunks so they do not need to be held in memory.
    %
    ldr = sqw_formats_factory.instance().get_pref_access(sqw_obj);
    ldr = ldr.init(sqw_obj, outfile);
    ldr.put_sqw('-nopix');
    ldr = write_out_of_mem_pix(sqw_obj.data_.pix, sqw_obj.data_.npix, sqw_obj.data_.s, ldr);
    ldr = ldr.validate_pixel_positions();
    ldr = ldr.put_footers();
    ldr.delete();
end


function loader = write_out_of_mem_pix(pix, npix, img_signal, loader)
    % Smear the given image signal values over a file-backed PixelData object
    % Set each pixel's signal to the value of the average signal of the bin
    % that pixel belongs to. Set all variances to zero.
    %
    pix.move_to_first_page();
    [npix_chunks, idxs] = split_vector_fixed_sum(npix(:), pix.base_page_size);
    page_number = 1;
    while true
        npix_chunk = npix_chunks{page_number};
        idx = idxs(:, page_number);

        pix.signal = repelem(img_signal(idx(1):idx(2)), npix_chunk);
        pix.variance = 0;
        loader = loader.put_bytes(pix.data);

        if pix.has_more()
            % Do not save cached changes to pixels.
            % We avoid copying pixels by just editing the signal/variance of
            % the current page of the input pixels, then saving that page to
            % the output file. We don't want to retain changes made to the
            % input PixelData object, so we discard edits to the cache when we
            % load the next page of pixels.
            pix.advance('nosave', true);
            page_number = page_number + 1;
        else
            % Make sure we discard the changes made to the final page's cache
            pix.move_to_page(1, 'nosave', true);
            break;
        end
    end
end
