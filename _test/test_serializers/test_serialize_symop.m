classdef test_serialize_symop < TestCase

    methods
        function obj = test_serialize_symop(name)
            if ~exist('name', 'var')
                name = 'test_serialize_symop';
            end
            obj = obj@TestCase(name);
        end

        function test_serialize_identity(~)
            sym = SymopIdentity();

            ser = hlp_serialize(sym);
            rec = hlp_deserialize(ser);
            assertEqual(rec, sym);
        end

        function test_serialize_general(~)
            sym = SymopGeneral([1 0 0
                                0 1 0
                                0 0 1]);

            ser = hlp_serialize(sym);
            rec = hlp_deserialize(ser);
            assertEqual(rec, sym);
        end

        function test_serialize_rotation(~)
            sym = SymopRotation([0 0 1], 90);

            ser = hlp_serialize(sym);
            rec = hlp_deserialize(ser);
            assertEqual(rec, sym);
        end

        function test_serialize_reflection(~)
            sym = SymopReflection([1 0 0], [0 1 0]);

            ser = hlp_serialize(sym);
            rec = hlp_deserialize(ser);
            assertEqual(rec, sym);
        end

        function test_serialize_mixed_array(~)
            sym = [SymopRotation([0 0 1], 90), SymopReflection([1 0 0], [0 1 0])];

            ser = hlp_serialize(sym);
            rec = hlp_deserialize(ser);
            assertEqual(rec, sym);
        end

    end
end
