function  out = delegate_to_dnd_( ...
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
%     overplot_methods = {...
%         'pd','pdoc','pe','peoc','ph','phoc','pl','ploc','pm','pmoc','pp','ppoc',...
%         'pa','paoc','ps','ps2','ps2oc','psoc'};
%     is_op = ismember(method,overplot_methods); % check if the method is overplot method
out = cell(1,nout);
switch(nout)
    case 0
        for i=1:nobj
            feval(method_name,obj(i).data,varargin{:});
        end
    case 1
        out{1}=feval(method_name,obj(1).data,varargin{:});
        if nobj>1
            addh_1 = cell(1,nobj); addh_1{1} = out{1};
            for i=2:nobj
                [addh_1{i}]=feval(method_name,obj(i).data,varargin{:});
            end
            out{1}= [addh_1{:}];
        end
    case 2
        [out{1},out{2}]=feval(method_name,obj(1).data,varargin{:});
        if nobj>1
            addh_1 = cell(1,nobj); addh_1{1} = out{1};
            addh_2 = cell(1,nobj); addh_2{1} = out{2};
            for i=2:nobj
                [addh_1{i},addh_2{i}]=feval(method_name,obj(i).data,varargin{:});
            end
            out{1}= [addh_1{:}];
            out{2}= [addh_2{:}];
        end
    case 3
        [out{1},out{2},out{3}]=feval(method_name,obj(1).data,varargin{:});
        if nobj>1
            addh_1 = cell(1,nobj); addh_1{1} = out{1};
            addh_2 = cell(1,nobj); addh_2{1} = out{2};
            addh_3 = cell(1,nobj); addh_3{1} = out{3};
            for i=2:nobj
                [addh_1{i},addh_2{i},addh_3{i}]=feval(method_name,obj(i).data,varargin{:});
            end
            out{1}= [addh_1{:}];
            out{2}= [addh_2{:}];
            cl_out = class(addh_3{1});
            size_out = size(addh_3{1});
            the_same = cellfun(@(x)(isa(x,cl_out) && all(size(x)==size_out)),addh_3);
            if all(the_same )
                out{3}= [addh_3{:}];
            else
                out{3} = addh_3;
            end
        end
    otherwise
        error(['HORACE:',class(obj),':invalid_argument'], ...
            'unrecognized number %d of output parameters. From 0 to 3 allowed.',nout)
end


