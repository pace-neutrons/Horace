classdef test_dnd_metadata_data < TestCase

    properties
        test_data
        common_data;
    end

    methods(Static)
    end

    methods

        function obj = test_dnd_metadata_data(varargin)
            if nargin == 0
                name = 'test_dnd_metadata_data';
            else
                name = varargin{1};
            end

            obj = obj@TestCase(name);
        end
        function test_d2d_metadata_data_construct_reconstruct(~)
            %axis, proj, s,e,npix
            input = {ortho_axes([0,1],[0,1],[0,0.1,1],[0,0.2,2]),...
                ortho_proj('alatt',3,'angdeg',90),...
                ones(11,11),2*ones(11,11),3*ones(11,11)};
            dnd_obj = d2d(input{:});

            assertTrue(isa(dnd_obj,'d2d'));

            dnd_met = dnd_obj.metadata;
            dnd_dat = dnd_obj.nd_data;


            dnd_obj_rec = DnDBase.dnd(dnd_met,dnd_dat);
            assertEqualToTol(dnd_obj,dnd_obj_rec,'-ignore_date' )
        end
        function test_dnd_data_get_set(~)
            input = {ortho_axes([0,1],[0,1],[0,0.1,1],[0,0.2,2]),...
                ortho_proj('alatt',3,'angdeg',90),...
                ones(11,11),2*ones(11,11),3*ones(11,11)};
            dnd_obj = d2d(input{:});

            dnd_dat = dnd_obj.nd_data;

            assertEqual(dnd_dat.dimensions,dnd_obj.dimensions);
            assertEqual(dnd_obj.s,dnd_dat.sig);
            assertEqual(dnd_obj.e,dnd_dat.err);
            assertEqual(dnd_obj.npix,dnd_dat.npix);

            dnd_dat.sig(1) = 100;
            dnd_dat.err(1) = 200;
            dnd_dat.npix(1) = 400;
            %
            dnd_obj.nd_data = dnd_dat;
            %
            assertEqual(dnd_obj.s,dnd_dat.sig);
            assertEqual(dnd_obj.e,dnd_dat.err);
            assertEqual(dnd_obj.npix,dnd_dat.npix);

        end

        function test_d2d_metadata_get_set(~)
            %axis, proj, s,e,npix
            input = {ortho_axes([0,1],[0,1],[0,0.1,1],[0,0.2,2]),...
                ortho_proj('alatt',3,'angdeg',90),...
                ones(11,11),2*ones(11,11),3*ones(11,11)};
            dnd_obj = d2d(input{:});

            assertTrue(isa(dnd_obj,'d2d'));

            dnd_met = dnd_obj.metadata;
            dtt = datetime("now");


            input{1}.label = dnd_obj.label;
            assertEqual(dnd_met.axes,input{1});
            assertEqual(dnd_met.proj,input{2});
            % save or get_metadata operation generates metadata with current
            % date  if it has not been defined earlier
            assertTrue(dnd_met.creation_date_defined);

            assertEqual(dnd_met.creation_date_str, ...
                main_header_cl.convert_datetime_to_str(dtt))

            proj = dnd_met.proj;
            proj.label = {'a','b','c','d'};
            dnd_met.proj = proj;
            assertEqual(dnd_met.axes.label,{'a','b','c','d'})
            dnd_obj.metadata = dnd_met;

            assertEqual(dnd_obj.axes,dnd_met.axes)
            assertEqual(dnd_obj.creation_date,dnd_met.creation_date_str);
            assertTrue(dnd_obj.creation_date_defined);
        end
        %
        function test_dnd_data_serialization(~)
            dd = dnd_data(ones(3,5,10),2*ones(3,5,10),3*ones(3,5,10));
            assertEqual(dd.dimensions,3)
            assertEqual(dd.data_size,[3,5,10]);

            dd_struc = dd.to_struct();

            dd_rec = serializable.from_struct(dd_struc);

            assertEqual(dd,dd_rec);
        end

        function test_dnd_metadata_serialization_no_date(~)
            ab = ortho_axes([0,1],[0,1],[0,0.1,1],[0,0.2,2]);
            pr = ortho_proj([1,1,0],[0,0,1]);
            md = dnd_metadata(ab,pr);

            mds = md.to_struct();

            mdr = serializable.from_struct(mds);

            assertEqual(md,mdr);
        end

        function test_dnd_metadata_serialization_with_date(~)
            ab = ortho_axes([0,1],[0,1],[0,0.1,1],[0,0.2,2]);
            pr = ortho_proj([1,1,0],[0,0,1],'alatt',3,'angdeg',90);
            md = dnd_metadata(ab,pr,datetime(1900,01,01));

            mds = md.to_struct();

            mdr = serializable.from_struct(mds);

            assertEqual(md,mdr);
        end

    end
end
