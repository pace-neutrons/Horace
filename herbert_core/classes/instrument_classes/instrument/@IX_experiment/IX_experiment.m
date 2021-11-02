classdef IX_experiment < serializable
    %IX_EXPERIMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        filename=''
        filepath='';
        efix = []
        emode=[]
        cu=[];
        cv=[];
        psi=[];
        omega=[];
        dpsi=[];
        gl=[];
        gs=[];
        en=[];
        uoffset=[];
        u_to_rlu=[];
        ulen=[];
        ulabel=[];
    end
    properties(Constant,Access=private)
        % the arguments have to be provided in the order the inputs for
        % constructor have to be provided
        fields_to_save_ = {'filename','filepath','efix','emode','cu',...
            'cv','psi','omega','dpsi','gl','gs','en','uoffset',...
            'u_to_rlu','ulen','ulabel'};
    end
    methods
        function flds = indepFields(~)
            flds = IX_experiment.fields_to_save_;
        end
        function ver  = classVersion(~)
            % return the version of the IX-experiment class
            ver = 1;
        end
        
        %
        function is = isempty(obj)
            is = false(size(obj));
            for i=1:numel(obj)
                for j=3:numel(IX_experiment.fields_to_save_)
                    if isempty(obj(i).(IX_experiment.fields_to_save_{j}))
                        is(i) = true;
                        break;
                    end
                end
            end
        end
        function obj = IX_experiment(varargin)
            if nargin==0
                return
            end
            obj = obj.init(varargin{:});
        end
        
        function obj = init(obj,varargin)
            % Usage:
            %   obj = init(obj,filename, filepath, efix,emode,cu,cv,psi,omega,dpsi,gl,gs,en,uoffset,u_to_rlu,ulen,ulabel)
            %
            %   IX_EXPERIMENT Construct an instance of this class
            if nargin == 2
                input = varargin{1};
                if isa(input,'IX_experiment')
                    obj = input ;
                    return
                elseif isstruct(input)
                    flds = obj.indepFields();                    
                    for i=1:numel(flds)
                        fld = flds{i};
                        obj.(fld) = input.(fld);
                    end
                else
                    error('HERBERT:IX_experiment:invalid_argument',...
                        'Unrecognized single input argument of class %s',...
                        class(input));
                end
            elseif nargin == 17
                flds = obj.indepFields();
                for i=1:numel(varargin)
                    fldn = flds{i};
                    obj.(fldn) = varargin{i};
                end
            else
                error('HERBERT:IX_experiment:invalid_argument',...
                    'unrecognized number of input arguments: %d',nargin);
            end
            if isempty(obj)
                error('HERBERT:IX_experiment:invalid_argument',...
                    'initialized IX_experiment can not be empty')
            end
        end
    end
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj = IX_experiment();
            obj = loadobj@serializable(S,obj);
        end
    end
    
end
