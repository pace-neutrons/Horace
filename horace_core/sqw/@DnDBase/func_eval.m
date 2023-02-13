function wout = func_eval (win, func_handle, pars, varargin)
% Evaluate a function at the plotting bin centres of dnd object or array
% of dnd objects
%
if numel(varargin)==1 && isstruct(varargin{1})
    % the function is called within a sqw object and the input have been
    % already processed by parse_funceval_args
    opts = varargin{1};
else
    [func_handle, pars, opts] = parse_eval_args(win, func_handle, pars, varargin{:});
    if numel(win) > 1
        input_dims = arrayfun(@(x) dimensions(x), win);
        if any(input_dims(1) ~= input_dims)
            error('HORACE:DnDBase:invalid_argument', ...
                ['Input dnd objects must have equal image dimensions.\n' ...
                'Found dimensions [%s].'], ...
                num2str(input_dims));
        end
    end
    if any(arrayfun(@(x) isempty(x.pax), win))
        error( 'HORACE:DnDBase:invalid_argument', ...
            'func_eval not supported for zero dimensional objects.' ...
            );
    end
end
wout = win;
for i = 1:numel(win)    % use numel so no assumptions made about shape of input array
    ndim=win(i).dimensions();
    if ~opts.all        % only evaluate at the bins actually containing data
        ok=(win(i).npix~=0);  % should be faster than isfinite(1./win.data_.npix), as we know that npix is zero or finite
    else
        ok=true(size(win(i).npix));
    end
    % Get bin centres
    pcent=cell(1,ndim);
    for n=1:ndim
        pcent{n} = 0.5 * (win(i).p{n}(1:end-1) + win(i).p{n}(2:end));
    end
    if ndim>1
        pcent=ndgridcell(pcent);%  make a mesh; cell array input and output
    end
    for n=1:ndim
        pcent{n}=pcent{n}(:);   % convert into column vectors
        if ~opts.all
            % pick out only those bins at which to evaluate function
            pcent{n}=pcent{n}(ok);
        end
    end

    % Evaluate function
    wout(i).s(ok) = func_handle(pcent{:},pars{:});
    wout(i).e = zeros(size(win(i).e));
    if opts.all
        wout(i).npix = ones(size(wout(i).npix));
    end
end