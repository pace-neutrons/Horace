function [obj,remains] = init_(obj,varargin)
% process inputs for aProjection class constructor, set up input parameters
% which are present within input arguments and return values, which
% do not belong to the input values

opt_par = {'alatt','angdeg','label','offset','lab1','lab2','lab3','lab4'};
lab_par = {'lab1','lab2','lab3','lab4'};
[result,remains,prop_present] = process_inputs_(opt_par,varargin{:});
if prop_present
    for i=1:numel(opt_par)
        fn = opt_par{i};
        if ~isempty(result.(fn))
            is_labpar = ismember(lab_par,fn);
            if any(is_labpar)
               obj.label{is_labpar} = result.(fn);
            else
                obj.(fn) = result.(fn);
            end
        end
    end
end

function [res,remain,prop_present]= process_inputs_(opt_par,varargin)
% parse inputs and return structure containing processed input
% Output:
% res    -- the structure, containing the values of the requested properties
%           or their default values
% remain -- the cellarray containing the inputs, not treated as inputs
%           for the class
% prop_present -- true if any property, may be defined in varargin have
%           non-default value. False otherwise.

par = inputParser();
for i=1:numel(opt_par)
    addParameter(par,opt_par{i},[]); % validation will be performed on setters
end
par.KeepUnmatched = true;
try
    parse(par,varargin{:});
catch ME
    if strcmp(ME.identifier,'MATLAB:InputParser:ParamMissingValue')
        throw(MException('HORACE:aProjection:invalid_argument',...
            sprintf('This constructor accepts only key,value pairs of aProjection properties:\n %s',ME.message)));
    else
        rethrow(ME);
    end
end
res = par.Results;
if numel(par.UsingDefaults)==numel(opt_par)
    prop_present = false;
else
    prop_present = true;
end
remain = par.Unmatched;
unmatched = struct2cell(remain);
if isempty(unmatched)
    remain = {};
else
    fn = fieldnames(remain);
    unmatched = [fn(:),unmatched(:)]';
    remain = reshape(unmatched,1,numel(unmatched));
end