classdef test_mex_nomex < TestCase
    % Series of tests to check work of mex files agains matlab files
    
    properties
        accum_cut_folder;
        curr_folder;
        nPolar=99;
        nAzim =101;
        nDet;
        nEn  = 102;
        efix=100;
        use_mex;
    end
    
    methods
        function this=test_mex_nomex (varargin)
            if nargin>0
                name=varargin{1};
            else
                name = 'test_mex_nomex';
            end
            this = this@TestCase(name);
            
            root_folder = fileparts(which('horace_init.m'));
            this.accum_cut_folder=fullfile(root_folder,'\@sqw/private');
            this.curr_folder = pwd();
            this.nDet=this.nPolar*this.nAzim;
        end
        function setUp(this)
            cd(this.accum_cut_folder);
            this.use_mex = get(hor_config,'use_mex');
        end
        function tearDown(this)
            cd(this.curr_folder);
            set(hor_config,'use_mex',this.use_mex);
        end
        
        function this=test_accum_cut(this)
            fprintf('in folder: %s',pwd());
            assertTrue(true,' nothing to test');
        end
        
        function this=test_calc_proj(this)
            [efx, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det]=calc_fake_data(this);
            %
            mex_present=fileparts(which('calc_projections_c'));
            assertTrue(~isempty(mex_present),'Mex file calc_projections_c is not availible on this computer')
            
            set(hor_config,'use_mex',0,'-buffer');
            [u_to_rlu_matl, ucoords_matl]=calc_projections (efx, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det);
            
            set(hor_config,'use_mex',1,'-buffer');
            [u_to_rlu_c, ucoords_c]=calc_projections (efx, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det);
            
            assertElementsAlmostEqual(u_to_rlu_matl,u_to_rlu_c,'absolute',1.e-8);
            assertElementsAlmostEqual(ucoords_matl,ucoords_c,'absolute',1.e-8);            
            
        end
        function  [efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det]=calc_fake_data(this)
            efix = this.efix;
            emode=1;
            alatt=[1,1,1];
            angdeg=[92,88,73];
            u=[1,0,0];
            v=[1,1,0];
            psi = 20;
            omega = 0;
            dpsi = 0;
            gl=0;
            gs =0;
            
            polar=(0:(this.nPolar-1))*(pi/(this.nPolar-1));
            azim=(0:(this.nAzim-1))*(2*pi/(this.nAzim-1));
            det.phi = reshape(repmat(azim,this.nPolar,1),1,this.nDet);
            det.azim =reshape(repmat(polar,this.nAzim,1)',1,this.nDet);
            data.S   = ones(this.nEn,this.nDet);
            data.ERR = ones(this.nEn,this.nDet);
            data.en =(-efix+(0:(this.nEn))*(1.99999*efix/(this.nEn)))';
        end
        
    end
end