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
            pths = horace_paths;
            this.test_data=fullfile(pths.root,'_test','test_combine');
            this.common_data = pths.test_common;
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
            t2 = d2d(fullfile(this.test_data,'w2d_qq_d2d.sqw'));
            assertTrue(isa(t2,'d2d'))
            skipTest('dnd object needs refactoring according to #796')
            t2 = d2d([0,1,1,0],[1,0,0],[-2,0.05,2],[0,1,0],[-2,0.05,2]);
            assertTrue(isa(t2,'d2d'))
            assertEqual(t2.uoffset,[0;1;1;0]);

        end
        function test_construct_array_from_multifiles(obj)
            file = fullfile(obj.test_data,'w2d_qq_d2d.sqw');
            t2 = d2d({file,file});
            assertTrue(isa(t2,'d2d'))
            assertEqual(size(t2),[1,2]);
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
        function this = test_dnd_from_sqw_array(this)
            % generate test data
            par_file = fullfile(this.common_data,'96dets.par');
            S=ones(10,96);
            ERR=ones(10,96);
            en = 0:2:20;
            rd = gen_nxspe(S,ERR,en,par_file,'',20,1,2);
            sqw_obj1 = rd.calc_sqw([]);
            S=2*ones(10,96);
            ERR=2*ones(10,96);
            rd = gen_nxspe(S,ERR,en,par_file,'',20,1,2);
            sqw_obj2 = rd.calc_sqw([]);
            sqw_obj = [sqw_obj1,sqw_obj2];

            % check dnd array conversion
            dnd_obj = dnd(sqw_obj);
            assertEqual(size(sqw_obj),size(dnd_obj));
            assertEqual(sqw_obj(1).data.s,dnd_obj(1).s);
            assertEqual(sqw_obj(1).data.e,dnd_obj(1).e);
            assertEqual(sqw_obj(2).data.s,dnd_obj(2).s);
            assertEqual(sqw_obj(2).data.e,dnd_obj(2).e);

            % check d4d array conversion
            dnd_obj = d4d(sqw_obj);
            assertEqual(size(sqw_obj),size(dnd_obj));
            assertEqual(sqw_obj(1).data.s,dnd_obj(1).s);
            assertEqual(sqw_obj(1).data.e,dnd_obj(1).e);
            assertEqual(sqw_obj(2).data.s,dnd_obj(2).s);
            assertEqual(sqw_obj(2).data.e,dnd_obj(2).e);

            % check d4d->d2d conversion fails
            f = @()d2d(sqw_obj);
            assertExceptionThrown(f,'HORACE:DnDBase:invalid_argument');
        end


    end
end
