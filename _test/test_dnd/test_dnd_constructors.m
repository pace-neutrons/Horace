classdef test_dnd_constructors< TestCase
    %
    % Validate fast sqw reader used in combining sqw
    
    
    properties
        test_data
        common_data
    end
    
    methods
        
        %The above can now be read into the test routine directly.
        function this=test_dnd_constructors(name)
            if ~exist('name','var')
                name = 'test_dnd_constructors';
            end
            this=this@TestCase(name);
            this.test_data=fullfile(fileparts(which('horace_init.m')),'_test/test_combine');
            this.common_data = fullfile(fileparts(which('horace_init.m')),'_test/common_data');
        end
        
        % tests
        function this = test_constructor(this)
            %Create empty object suitable for simulations:
            %  >> w = d2d (proj, p1_bin, p2_bin, p3_bin, p4_bin)
            %  >> w = d2d (lattice, proj,...)
            %
            %**Or** (old syntax, still available for legacy purposes)
            %  >> w = d2d (u1,p1,u2,p2)    % u1,u2 vectors define projection axes in rlu,
            %                                p1,p2 give start,step and finish for the axes
            %  >> w = d2d (u0,...)         % u0 is offset of origin of dataset,
            %  >> w = d2d (lattice,...)    % Give lattice parameters [a,b,c,alf,bet,gam]
            %  >> w = d2d (lattice,u0,...) % Give u0 and lattice parameters
            
            
            
            t2 = d2d();
            assertTrue(isa(t2,'d2d'))
            t2 = d2d([0,0,0,0],[1,0,0],[-2,0.05,2],[0,1,0],[-2,0.05,2]);
            assertTrue(isa(t2,'d2d'))
            t2 = d2d(fullfile(this.test_data,'w2d_qq_d2d.sqw'));
            assertTrue(isa(t2,'d2d'))
        end
        function this = test_dnd_from_sqw(this)
            par_file = fullfile(this.common_data,'96dets.par');
            S=ones(10,96);
            ERR=ones(10,96);
            en = 0:2:20;
            rd = gen_nxspe(S,ERR,en,par_file,'',20,1,2);
            sqw_obj = rd.calc_sqw([]);
            
            dnd_obj = dnd(sqw_obj);
            assertEqual(sqw_obj.data.s,dnd_obj.s);
            assertEqual(sqw_obj.data.e,dnd_obj.e);
        end
        function this = test_old_sqw(this)
            this_path = fileparts(which(mfilename));
            test_file = fullfile(this_path,'old_sqw_test.mat');
            ld = load(test_file);
            old_sqw = ld.QE_35_10;
            old_dnd = dnd(old_sqw);
            assertEqual(old_sqw(1).data.s,old_dnd(1).s);
            assertEqual(old_sqw(1).data.e,old_dnd(1).e);
            assertEqual(old_sqw(2).data.s,old_dnd(2).s);
            assertEqual(old_sqw(2).data.e,old_dnd(2).e);
            assertEqual(old_sqw(3).data.s,old_dnd(3).s);
            assertEqual(old_sqw(3).data.e,old_dnd(3).e);           
        end
        
    end
end


