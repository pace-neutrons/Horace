classdef test_rundata_isvalid < TestCase
    properties
        log_level;
    end

    methods
        function obj=test_rundata_isvalid(name)
            obj = obj@TestCase(name);
        end

        function obj=setUp(obj)
            obj.log_level = get(hor_config,'log_level');
            set(hor_config,'log_level',-1,'-buffer');
        end

        function obj=tearDown(obj)
            set(hor_config,'log_level',obj.log_level,'-buffer');
        end

        function obj=test_SERR(obj)
            rd = rundata();
            rd.S = ones(3,5);
            assertFalse(rd.isvalid);
            base_mess = 'ill defined Signal: size(Signal) ~= size(ERR)';
            assertTrue(strncmp(rd.reason_for_invalid,base_mess,numel(base_mess)));
            rd.ERR=ones(4,7);
            assertTrue(strncmp(base_mess,rd.reason_for_invalid,numel(base_mess)));

            rd.ERR=zeros(3,5);
            assertFalse(rd.isvalid);
            base_mess = 'ill defined en: size(en) ~= size(S,1)+1';
            assertTrue(strncmp(base_mess,rd.reason_for_invalid,numel(base_mess)));

        end

        function obj = test_Sen(obj)
            rd=rundata();
            rd.en = ones(5,1);
            assertFalse(rd.isvalid);
            rd.en = ones(1,5);
            rd=rd.check_combo_arg();
            assertFalse(rd.isvalid);
            base_mess = 'Energy transfer is defined but signal,error and/or data file are not';
            assertEqual(rd.reason_for_invalid,base_mess);
            assertEqual(size(rd.en),[5,1]);

            rd.S = ones(4,6);
            assertFalse(rd.isvalid)
            % S is ill-defined
            base_mess = 'ill defined Signal: size(Signal) ~= size(ERR)';
            assertTrue(strncmp(base_mess,rd.reason_for_invalid,numel(base_mess)));

            rd.ERR = ones(4,6);
            assertFalse(rd.isvalid);
            assertEqual(rd.reason_for_invalid,'load_par undefined')

            rd.det_par = ones(6,6);
            assertTrue(rd.isvalid);
        end

        function obj = test_enEfix(obj)
            rd=rundata();
            rd.efix = 6;
            assertFalse(rd.isvalid);
            rd=rd.check_combo_arg();
            assertFalse(rd.isvalid)
            base_mess_S = 'Run is undefined. Need to define missing fields: en; n_detectors; S; ERR; det_par';
            assertTrue(strncmp(rd.reason_for_invalid,base_mess_S,numel(base_mess_S)));

            rd.en=(1:10)';
            rd=rd.check_combo_arg();
            assertFalse(rd.isvalid);
            base_mess = 'Emode=1 and efix incompatible with max energy transfer, efix: 6.000000 max(dE): 9.500000';
            assertTrue(strncmp(base_mess,rd.reason_for_invalid,numel(base_mess)));


            rd.en=(1:6)';
            assertFalse(rd.isvalid);
            rd=rd.check_combo_arg();
            assertFalse(rd.isvalid);
            base_mess = 'Energy transfer is defined but signal,error and/or data file are not';
            assertTrue(strncmp(rd.reason_for_invalid,base_mess,numel(base_mess)));

        end

        function obj = test_det_par(obj)
            rd=rundata();
            rd.det_par = ones(6,3);
            assertTrue(rd.isvalid);

            %rd.det_par =
            %[ok,mess]=isvalid(rd);
            %assertFalse(ok);
            f = @()get_hor_format(ones(5,3),'');
            assertExceptionThrown(f,'HERBERT:get_hor_format:invalid_argument');
            %assertEqual(mess,'det_par field has to be a [6xndet] array, but has: 5 columns');

            rd.det_par = ones(6,10);
            rd.S       = ones(3,9);
            assertFalse(rd.isvalid);
            base_mess = 'ill defined Signal: size(Signal) ~= size(ERR)';
            assertTrue(strncmp(base_mess,rd.reason_for_invalid,numel(base_mess)));

            rd.S       = ones(3,10);
            rd.ERR     = zeros(3,10);
            rd.en      = 1:4;
            assertTrue(rd.isvalid);
        end

        function obj = test_set_lattice(obj)
            rd=rundata();
            assertFalse(rd.isvalid);

            rd.lattice = oriented_lattice();
            assertFalse(rd.isvalid);

            assertEqual(rd.lattice,oriented_lattice);
        end

        function obj = test_3vectors(obj)
            rd=rundata();

            rd = set_lattice_field(rd,'u',[1,2,3]);
            rd = set_lattice_field(rd,'v',[3;4;5]);
            rd = set_lattice_field(rd,'alatt',1:3);
            rd = set_lattice_field(rd,'angdeg',(2:4)');
            rd = set_lattice_field(rd,'psi',0);
            assertTrue(rd.lattice.isvalid);

            assertFalse(rd.isvalid);
            rd=rd.check_combo_arg();
            assertFalse(rd.isvalid);
            assertTrue(strncmp(rd.reason_for_invalid,'Run is undefined',16));
        end

        function obj = test_1vectors(obj)
            rd=rundata();

            rd.lattice.alatt = 3;
            rd.lattice.angdeg = 90;
            rd.lattice.gl=0;
            rd.lattice.gs=1;
            rd.lattice.psi=1;
            rd.lattice.omega=10;
            rd.lattice.dpsi=-10;
            assertTrue(rd.lattice.isvalid);

            assertFalse(rd.isvalid);
            rd=rd.check_combo_arg();
            assertFalse(rd.isvalid);
            assertTrue(strncmp(rd.reason_for_invalid,'Run is undefined',16));
        end

        function obj = test_degrees(obj)
            rd=rundata();
            rd.lattice.alatt=3.2;          % lattice,
            rd.lattice.angdeg=[45,90,50];  % angles
            rd.lattice.psi=10;             % and psi are three variables
            % becessary to make lattice valid
            assertTrue(rd.lattice.isvalid);
            assertFalse(rd.isvalid);
            assertTrue(strncmp(rd.reason_for_invalid, ...
                'Run is undefined',16));

            rd = rd.check_combo_arg();
            assertTrue(strncmp(rd.reason_for_invalid, ...
                'Run is undefined',16));
        end
    end
end
