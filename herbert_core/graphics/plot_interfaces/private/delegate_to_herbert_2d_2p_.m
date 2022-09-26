function  [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_2d_2p_( ...
    obj,nout,method_name,call_class_name,opt,varargin)
% invoke appropriate plotting method on dnd object of sqw object or array
% of objects provided as input
%
% Inputs:
% obj         -- a sqw object containing dnd object
% nout        -- number of output, a graphical method requested
% method_name -- name of the plotting method to invoke
% varargin    -- array of various parameters, provided for the
%                corresponding plotting method
% Output (if requested)
% figureHandle -- the handle or array of picture handles of the plotted pictures
% axesHandle   -- array of picutres axes handles
% plotHandle   -- array of handles of the overplot methods
%
[args,ok,mess,nw]=genie_figure_parse_plot_args2(opt,obj,varargin{:});
if ~ok
    error(['HORACE:',call_class_name,':invalid_argument'],mess);
end

nobj = numel(obj);
figureHandle = [];
axesHandle = [];
plotHandle = [];
if nobj == 1
    if nw==2
        [figureHandle, axesHandle, plotHandle] = feval(method_name,IX_dataset_2d(obj), IX_dataset_2d(varargin{1}), args{:});
    else
        [figureHandle, axesHandle, plotHandle] = feval(method_name,IX_dataset_2d(obj), args{:});
    end
else
    %     overplot_methods = {...
    %         'pd','pdoc','pe','peoc','ph','phoc','pl','ploc','pm','pmoc','pp','ppoc',...
    %         'pa','paoc','ps','ps2','ps2oc','psoc'};
    %     is_op = ismember(method,overplot_methods); % check if the method is overplot method

    switch(nout)
        case 0
            for i=1:nobj
                if nw==2
                    feval(method_name,IX_dataset_2d(obj), IX_dataset_2d(varargin{1}), args{:});
                else
                    feval(method_name,IX_dataset_2d(obj), args{:});
                end


            end
        case 1
            for i=1:nobj
                if nw==2
                    figureHandle = feval(method_name,IX_dataset_2d(obj), IX_dataset_2d(varargin{1}), args{:});
                else
                    figureHandle = feval(method_name,IX_dataset_2d(obj), args{:});
                end
            end
        case 2
            for i=1:nobj
                if nw==2
                    [figureHandle, axesHandle] = feval(method_name,IX_dataset_2d(obj), IX_dataset_2d(varargin{1}), args{:});
                else
                    [figureHandle, axesHandle] = feval(method_name,IX_dataset_2d(obj), args{:});
                end
            end
        case 3
            for i=1:nobj
                if nw==2
                    [figureHandle, axesHandle, plotHandle] = feval(method_name,IX_dataset_2d(obj), IX_dataset_2d(varargin{1}), args{:});
                else
                    [figureHandle, axesHandle, plotHandle] = feval(method_name,IX_dataset_2d(obj), args{:});
                end
            end
        otherwise
            error(['HORACE:',call_class_name,':invalid_argument'], ...
                'unrecognized number %d of output parameters. From 0 to 3 allowed.',nout)
    end
end
