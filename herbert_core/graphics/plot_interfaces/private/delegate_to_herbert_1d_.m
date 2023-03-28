function  [figureHandle, axesHandle, plotHandle] = delegate_to_herbert_1d_( ...
    obj,nout,method_name,call_class_name,options,varargin)
% invoke appropriate plotting method on dnd object of sqw object or array
% of objects provided as input
%
% Inputs:
% obj         -- a sqw object containing dnd object
% nout        -- number of output, a graphical method requested
% method_name -- name of the plotting method to invoke
% class_name  -- the name of the class to report errors from
% options     -- the global options specific for this kind of plot
%
% varargin    -- array of various parameters, provided for the
%                corresponding plotting method
% Output (if requested)
% figureHandle -- the handle or array of picture handles of the plotted pictures
% axesHandle   -- array of picutres axes handles
% plotHandle   -- array of handles of the overplot methods
%
args=genie_figure_parse_plot_args(options,varargin{:});

nobj = numel(obj);
figureHandle = [];
axesHandle = [];
plotHandle = [];
if nobj == 1
    [figureHandle, axesHandle, plotHandle]=feval(method_name,obj,args{:});
else
    %     overplot_methods = {...
    %         'pd','pdoc','pe','peoc','ph','phoc','pl','ploc','pm','pmoc','pp','ppoc',...
    %         'pa','paoc','ps','ps2','ps2oc','psoc'};
    %     is_op = ismember(method,overplot_methods); % check if the method is overplot method

    switch(nout)
        case 0
            for i=1:nobj
                feval(method_name,obj.data,args{:});
            end
        case 1
            for i=1:nobj
                figureHandle = feval(method_name,obj,args{:});
            end
        case 2
            for i=1:nobj
                [figureHandle,axesHandle]=feval(method_name,obj,args{:});
            end
        case 3
            for i=1:nobj
                [figureHandle,axesHandle,plotHandle]=feval(method_name,obj,args{:});
            end

        otherwise
            error(['HORACE:',call_class_name,':invalid_argument'], ...
                'incorrect number: %d of output parameters. From 0 to 3 outputs allowed.', ...
                nout)
    end

end
