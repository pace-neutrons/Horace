classdef test_dnd< TestCase
    %
    % Validate fast sqw reader used in combining sqw
    
    
    properties
        test_data
    end
    
    methods
        
        %The above can now be read into the test routine directly.
        function this=test_dnd(name)
            this=this@TestCase(name);
            this.test_data=fullfile(fileparts(which('horace_init.m')),'_test/test_combine');
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
        
    end
end


