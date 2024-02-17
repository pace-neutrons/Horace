classdef test_replicate< TestCase
    %
    % Validate sqw object replication
    %

    properties
        this_dir;
        w1
        w2
    end

    methods
        function obj=test_replicate(name)
            if ~exist('name','var')
                name = 'test_replicate_sqw';
            end
            obj=obj@TestCase(name);
            obj.this_dir = fileparts(mfilename('fullpath'));
            en = -5:1:80;
            efix = 85;
            alatt = [2.83,2.83,2.83];
            angdeg = [90,90,90];
            k_range = [-1,0.1,1;-1,0.1,1;-1,0.1,1];
            wtmp = dummy_sqw(en,k_range,'',efix,1,...
                alatt,angdeg,[1,0,0],[0,1,0],0,0,0,0,0,[50,50,50,50]);
            function sig = signal(h,k,l,en,p)
                sig = ones(size(h))*p(1);
            end

            sqw_4D_artificial = sqw_eval(wtmp{1},@signal,{1});
            obj.w1 = cut(sqw_4D_artificial,[-1,0.02,1],[-1,1],[-1,1],[-0.5,0.5]);
            obj.w2 = cut(sqw_4D_artificial,[-1,0.02,1],[-1,1],[-1,0.02,1],[-0.5,0.5]);
        end

        % tests
        function test_replicate_sqw_1Dto2D_dnd_warns(obj)
            clWarn = set_temporary_warning('off','HORACE:invalid_argument','HORACE:test_warn');

            s2r = replicate(obj.w1,obj.w2);
            assertTrue(isa(s2r,'d2d'))
            warning('HORACE:test_warn','issue test warning to check correct warning is issued');
            s2rd = replicate(obj.w1,obj.w2.data,'-set_pix');
            assertTrue(isa(s2rd,'d2d'))
            [~,lwid] = lastwarn;
            assertEqual(lwid,'HORACE:invalid_argument')

            assertEqual(s2r ,s2rd )
        end

        function test_replicate_sqw_1Dto2D_sqw_nopix_warns(obj)
            clWarn = set_temporary_warning('off','HORACE:invalid_argument','HORACE:test_warn');

            s2r = replicate(obj.w1,obj.w2);
            assertTrue(isa(s2r,'d2d'))
            w2nop = obj.w2;
            w2nop.pix = PixelDataMemory();
            warning('HORACE:test_warn','issue test warning to check correct warning is issued');
            s2rd = replicate(obj.w1,w2nop,'-set_pix');
            assertTrue(isa(s2rd,'d2d'))
            [~,lwid] = lastwarn;
            assertEqual(lwid,'HORACE:invalid_argument')

            assertEqual(s2r ,s2rd )
        end

        function test_replicate_dnd_1Dto2D_sqw_nopix_warns(obj)
            clWarn = set_temporary_warning('off','HORACE:invalid_argument','HORACE:test_warn');

            s2r = replicate(obj.w1,obj.w2);
            assertTrue(isa(s2r,'d2d'))
            w2nop = obj.w2;
            w2nop.pix = PixelDataMemory();
            warning('HORACE:test_warn','issue test warning to check correct warning is issued');
            s2rd = replicate(obj.w1.data,w2nop,'-set_pix');
            assertTrue(isa(s2rd,'d2d'))
            [~,lwid] = lastwarn;
            assertEqual(lwid,'HORACE:invalid_argument')

            assertEqual(s2r ,s2rd )
        end

        function test_replicate_dnd_1Dto2D_dnd_warns(obj)
            clWarn = set_temporary_warning('off','HORACE:invalid_argument','HORACE:test_warn');

            s2r = replicate(obj.w1,obj.w2);
            assertTrue(isa(s2r,'d2d'))
            warning('HORACE:test_warn','issue test warning to check correct warning is issued');
            s2rd = replicate(obj.w1.data,obj.w2.data,'-set_pix');
            assertTrue(isa(s2rd,'d2d'))
            [~,lwid] = lastwarn;
            assertEqual(lwid,'HORACE:invalid_argument')

            assertEqual(s2r ,s2rd )
        end

        function test_replicate_dnd_1Dto2D_dnd(obj)
            s2r = replicate(obj.w1,obj.w2);
            assertTrue(isa(s2r,'d2d'))
            s2rd = replicate(obj.w1.data,obj.w2.data);
            assertTrue(isa(s2rd,'d2d'))

            assertEqual(s2r ,s2rd )
        end

        function test_replicate_dnd_1Dto2D_eq_sqw(obj)

            s2r = replicate(obj.w1,obj.w2);
            assertTrue(isa(s2r,'d2d'))
            s2rd = replicate(obj.w1.data,obj.w2);
            assertTrue(isa(s2rd,'d2d'))

            assertEqual(s2r ,s2rd )
        end

        function test_replicate_dnd_1Dto2D_with_pix(obj)

            s2r = replicate(obj.w1,obj.w2,'-set_pix');
            assertTrue(isa(s2r,'sqw'))
            s2rd = replicate(obj.w1.data,obj.w2,'-set_pix');
            assertTrue(isa(s2rd,'sqw'))

            assertEqual(s2r ,s2rd )
        end

        function test_replicate_1Dto2D_with_pix(obj)

            d2r = replicate(obj.w1,obj.w2,'-set_pix');

            assertEqual(obj.w2.data.p{1},d2r.data.p{1})
            assertEqual(obj.w2.data.p{2},d2r.data.p{2})

            assertEqualToTol(d2r,obj.w2);
        end

        function test_replicate_1Dto2D(obj)

            d2r = replicate(obj.w1,obj.w2);

            assertTrue(isa(d2r,'d2d'))
            assertEqual(obj.w2.data.p{1},d2r.p{1})
            assertEqual(obj.w2.data.p{2},d2r.p{2})

            % This does not work, but ideally should when sqw data look a
            % bit differenlty
            %assertEqual(d2r,dnd(w2)); % desirable outcome, but currently
            % can not achieve this -- detectors do not cover all q-range
            % homogeneously
        end
    end
end
