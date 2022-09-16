function obj = init_(obj,varargin)
% initialize Experiment object using various possible forms of inputs,
% provided to Experiment constructor.

argi = varargin;
if isempty(argi)
    return;
end

S = argi{1};
narg = numel(argi);
if narg  == 1
    if isa(S,'Experiment')
        obj = S;
        return;
    elseif isstruct(S)
        if isfield(S,'efix') && isfield(S,'emode')
            obj = build_from_old_headers_(obj,{S});
        elseif isempty(fieldnames(S))
            obj = Experiment(); % empty object
        else
            obj =Experiment.from_struct(S);
        end
    elseif iscell(S)
        obj = build_from_old_headers_(obj,S);
    else
        error('HORACE:Experiment:invalid_argument',...
            'unrecognised Experiment constructor type: %s',class(varargin{1}));
    end
else
    % define the order of possible positional parameters
    positinal_param_names_list = {'detector_arrays','instruments','samples',...
        'expdata'};
    % switch expdata to first position to set the number of runs for
    % subsequent initialization of instruments etc
    positinal_param_names_list = {positinal_param_names_list{4} positinal_param_names_list{1:3}};
    argi = {argi{4} argi{1:3}};
    % define validators, which specify if the positional
    % parameter is indeed on its appropriate place.
    [obj,remains] = set_positional_and_key_val_arguments(obj,...
        positinal_param_names_list,argi{:});
    if ~isempty(remains)
        error('HORACE:Experiment:invalid_argument',...
            'Extra input parameters %s for Experiment constructor',...
            evalc('disp(remains)'));
    end
end

