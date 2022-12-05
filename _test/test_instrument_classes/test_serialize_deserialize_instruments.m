classdef test_serialize_deserialize_instruments< TestCase
    %
    % Validate fast sqw reader used in combining sqw
    %
    %
    properties
        working_dir;
    end
    methods(Static)
        function clean_file(fid)
            fname = fopen(fid);
            fclose(fid);
            delete(fname);
        end
    end

    methods

        %The above can now be read into the test routine directly.
        function this=test_serialize_deserialize_instruments(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this=this@TestCase(name);

            this.working_dir = tmp_dir;

        end
        % tests
        %
        function test_single_instrument_conversion(~)
            %---  Instrument
            inst = maps_instrument_obj_for_tests(300,700,'S');

            siz = inst.serial_size();
            bytes = inst.serialize();
            assertEqual(siz,numel(bytes))

            [inst_rec,nbytes] = serializable.deserialize(bytes);
            assertEqual(nbytes,numel(bytes));
            assertEqual(inst_rec,inst)

        end
        function test_two_instrument_conversion(~)
            % 2 instruments
            inst_s = [maps_instrument_obj_for_tests(300,700,'S'),...
                maps_instrument_obj_for_tests(200,300,'A')];

            siz = inst_s.serial_size();
            bytes = inst_s.serialize();
            assertEqual(siz,numel(bytes))

            [inst_rec,nbytes] = serializable.deserialize(bytes);
            assertEqual(nbytes,numel(bytes));
            assertEqual(inst_rec,inst_s)
        end
        function test_sample(~)

            %---  Sample
            samp = IX_sample ([1,0,0],[0,1,0],'cuboid',[2,3,4]);

            siz = samp.serial_size();
            bytes = samp.serialize();
            assertEqual(siz,numel(bytes))

            [sam_rec,nbytes] = serializable.deserialize(bytes);
            assertEqual(nbytes,numel(bytes));
            assertEqual(sam_rec,samp)
        end
        function test_two_samples(~)

            %---  Samples
            samp = [IX_sample([1,0,0],[0,1,0],'cuboid',[2,3,4]),...
                IX_sample([1,0,0], [0,1,0], 'cuboid', [2,3,4], 'eta', 4134)];

            siz = samp.serial_size();
            bytes = samp.serialize();
            assertEqual(siz,numel(bytes))

            [sam_rec,nbytes] = serializable.deserialize(bytes);
            assertEqual(nbytes,numel(bytes));
            assertEqual(sam_rec,samp)
        end

        %
    end
end

