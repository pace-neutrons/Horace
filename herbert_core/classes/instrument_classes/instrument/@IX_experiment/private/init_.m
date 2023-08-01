function obj = init_(obj,varargin)
% INIT_ construcnt non-empty instance of this class
% Usage:
%   obj = init(obj,filename, filepath, efix,emode,cu,cv,psi,...
%               omega,dpsi,gl,gs,en,uoffset,u_to_rlu,ulen,...
%               ulabel,run_id)

% the list of the fieldnames, which may appear in constructor
% in the order they may appear in the constructor.
if nargin == 2
    input = varargin{1};
    if isa(input,'IX_experiment')
        obj = input ;
        return
    elseif isstruct(input)
        % constructor
        % The constructor parameters names in the order, then can
        % appear in constructor
        obj = IX_experiment.loadobj(input);
    else
        error('HERBERT:IX_experiment:invalid_argument',...
            'Unrecognised single input argument of class %s',...
            class(input));
    end
elseif nargin > 2
    %
    flds = obj.saveableFields();
    % select possible costruction using goniometer itself and goniometer
    % parameters
    is_gon = cellfun(@(x)isa(x,'goniometer'),varargin);
    if any(is_gon) % then goniometer parameters should not be provided independently
        gon_num = find(is_gon);
        % if goniometer parameter is provided as a key
        is_gon_key = cellfun(@(x)(istext(x)&&strncmp(x,'goniometer',max(3,numel(x)))),varargin);
        if any(is_gon_key)
            gon_key_num = find(is_gon_key);
            if numel(gon_num)>1 || gon_key_num+1 ~=gon_num
                error('HERBERT:IX_experiment:invalid_argument',...
                    ['Goniometer key (input N:%d) and Goniometer value (input N:%d) are inconsistent\n' ...
                    'goniometer key inconsistent with goniometer value or two goniometers provided'],...
                    gon_key_num,gon_num);
            end
            flds = [flds(:);'goniometer'];
        else % goniometer as positional parameter
            % remove goniometer properties from the list of the input parameters
            flds = [flds(1:gon_num-1)';'goniometer';'uoffset'];
        end
    end
    [obj,remains] = set_positional_and_key_val_arguments(obj,...
        flds,false,varargin{:});
    if ~isempty(remains)
        error('HERBERT:IX_experiment:invalid_argument',...
            'Non-recognized extra-arguments provided as input for constructor for IX_experiemt: %s', ...
            disp2str(remains));
    end
else
    error('HERBERT:IX_experiment:invalid_argument',...
        'unrecognised number of input arguments: %d',nargin);
end
if isempty(obj)
    error('HERBERT:IX_experiment:invalid_argument',...
        'initialized IX_experiment can not be empty')
end
