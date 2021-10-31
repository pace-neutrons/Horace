classdef IX_experiment
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
        fields_to_save_ = {'filename','filepath','efix','emode','cu',...
            'cv','psi','omega','dpsi','gl','gs','en','uoffset',...
            'u_to_rlu','ulen','ulabel'};
    end   
    methods
        function flds = indepFields(~)
            flds = IX_experiment.fields_to_save_;
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
            
            if nargin==1
                input = varargin{1};
                if isa(input,'IX_experiment')
                    obj = input ;
                    return
                elseif isstruct(input )
                    
                    for i=1:numel(IX_experiment.fields_to_save_)
                        fld = IX_experiment.fields_to_save_{i};
                        obj.(fld) = input.(fld);
                    end
                else
                    error('HERBERT:IX_experiment:invalid_argument',...
                        'Unrecognized single input argument of class %s',...
                        class(input));
                end
            else
                obj = obj.init(varargin{:});
            end
        end
        
        function obj = init(obj,filename, filepath, efix,emode,cu,cv,psi,omega,dpsi,gl,gs,en,uoffset,u_to_rlu,ulen,ulabel)
            %IX_EXPERIMENT Construct an instance of this class
            %   Detailed explanation goes here
            obj.filename = filename;
            obj.filepath = filepath;
            obj.efix = efix;
            obj.emode = emode;
            obj.cu = cu;
            obj.cv = cv;
            obj.psi = psi;
            obj.omega = omega;
            obj.dpsi = dpsi;
            obj.gl = gl;
            obj.gs = gs;
            obj.en = en;
            obj.uoffset =  uoffset;
            obj.u_to_rlu = u_to_rlu;
            obj.ulen = ulen;
            obj.ulabel = ulabel;
            if isempty(obj)
                error('HERBERT:IX_experiment:invalid_argument',...
                    'initialized IX_experiment can not be empty')
            end
        end
    end
end

