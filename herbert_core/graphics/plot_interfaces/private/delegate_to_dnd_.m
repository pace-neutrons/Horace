function  [figureHandle, axesHandle, plotHandle] = delegate_to_dnd_( ...
    obj,nout,method_name,varargin)
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
nobj = numel(obj);
figureHandle = [];
axesHandle = [];
plotHandle = [];
if nobj == 1
    [figureHandle, axesHandle, plotHandle]=feval(method_name,obj.data,varargin{:});
else
    %     overplot_methods = {...
    %         'pd','pdoc','pe','peoc','ph','phoc','pl','ploc','pm','pmoc','pp','ppoc',...
    %         'pa','paoc','ps','ps2','ps2oc','psoc'};
    %     is_op = ismember(method,overplot_methods); % check if the method is overplot method

    switch(nout)
        case 0
            for i=1:nobj
                feval(method_name,obj.data,varargin{:});
            end
        case 1
            for i=1:nobj
                figureHandle = feval(method_name,obj.data,varargin{:});
            end
        case 2
            for i=1:nobj
                [figureHandle,axesHandle]=feval(method_name,obj.data,varargin{:});
            end
        case 3
            for i=1:nobj
                [figureHandle,axesHandle,plotHandle]=feval(method_name,obj.data,varargin{:});
            end

        otherwise
            error(['HORACE:',class(obj),':invalid_argument'], ...
                'unrecognized number %d of output parameters. From 0 to 3 allowed.',nout)
    end

end
