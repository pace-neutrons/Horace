classdef IX_experiment
    %IX_EXPERIMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        filename
        filepath
        efix
        emode
        cu
        cv
        psi
        omega
        dpsi
        gl
        gs
        en
        uoffset
        u_to_rlu
        ulen
        ulabel
    end
    
    methods
        function obj = IX_experiment(filename, filepath, efix,emode,cu,cv,psi,omega,dpsi,gl,gs,en,uoffset,u_to_rlu,ulen,ulabel)
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
        end
    end
end

