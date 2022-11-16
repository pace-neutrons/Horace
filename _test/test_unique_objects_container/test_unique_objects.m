classdef test_unique_objects < TestCase
    properties
        mi1;
        nul_sm1;
    end

    methods
        function obj=test_unique_objects(varargin)
            if nargin>0
                name = varargin{1};
            else
                name  = 'test_unique_objects';
            end
            obj = obj@TestCase(name);
            obj.mi1 = merlin_instrument(180, 600, 'g');
            obj.nul_sm1 = IX_null_sample();

        end
        %
        %------------------------------------------------------------------
        function test_add_non_unique_objects(obj)

            % create two different instruments from a couple of instrument
            % creator functions
            li = let_instrument(5, 240, 80, 20, 1);

            % make a unique_objects_container (empty)
            uoc = unique_objects_container();

            % add 3 identical instruments to the container
            uoc = uoc.add(li);
            uoc = uoc.add(li);
            uoc = uoc.add(li);
            % add 2 more instruments, identical to each other but not the
            % first 3
            uoc = uoc.add(obj.mi1);
            uoc = uoc.add(obj.mi1);
            % add another instrument same as the first 3
            uoc = uoc.add(li);

            % test that we put 6 instruments in the container
            assertEqual( numel(uoc.idx), 6);

            % test that there are only 2 uniquely different instruments in
            % the container
            assertEqual( numel(uoc.unique_objects), 2);

            % test that there are 2 correspondingly different hashes in the
            % container for these instruments
            assertEqual( numel(uoc.stored_hashes), 2);


            % test that the first 3 instruments in the container are the
            % same as instrument li
            % also tests that the get method for retrieving the non-unique
            % objects is working
            for i=1:3
                assertEqual( li, uoc.get(i) );
            end

            % test that the next 2 instruments in the container are the
            % same as instrument mi
            for i=4:5
                assertEqual(obj.mi1, uoc.get(i) );
            end

            % test that the last instrument in the container is also the
            % same as instrument li
            assertEqual( li, uoc.get(6) );
        end

        %----------------------------------------------------------------
        function test_add_similar_non_unique_objects(obj)
            %disp('Test: test_add_similar_non_unique_objects');

            mi2 = merlin_instrument(190, 700, 'g');
            assertFalse( isequal(obj.mi1,mi2) );
            uoc = unique_objects_container();
            [uoc,nuix] = uoc.add(obj.mi1);
            assertEqual( nuix, 1);
            [uoc,nuix] = uoc.add(mi2);
            assertEqual( nuix, 2);
            [uoc,nuix] = uoc.add(obj.mi1);
            assertEqual( nuix, 3);
            [uoc,nuix] = uoc.add(mi2);
            assertEqual( nuix, 4);
            [uoc,nuix] = uoc.add(mi2);
            assertEqual( nuix, 5);
            assertEqual( numel(uoc.unique_objects), 2);
            assertEqual( numel(uoc.idx), 5);
            assertEqual( obj.mi1, uoc.get(3) );
            assertEqual( mi2, uoc.get(5) );
        end
        %----------------------------------------------------------------
        function test_add_different_types(obj)
            %disp('Test: test_add_different_types');
            ws = warning('off','HERBERT:unique_objects_container:invalid_argument');
            clOb = onCleanup(@()warning(ws));


            uoc = unique_objects_container();
            uoc = uoc.add(obj.mi1);
            uoc = uoc.add(obj.nul_sm1);
            assertEqual( numel(uoc.unique_objects), 2);
            assertEqual( numel(uoc.idx), 2);
            assertEqual( obj.mi1, uoc.get(1) );
            assertEqual( obj.nul_sm1, uoc.get(2) );
            voc = unique_objects_container('baseclass','IX_inst');
            [voc,nuix] = voc.add(obj.mi1);

            assertTrue( nuix>0 );
            [voc,nuix] = voc.add(obj.nul_sm1);
            [~,lw] = lastwarn;
            assertEqual(lw,'HERBERT:unique_objects_container:invalid_argument')

            assertFalse( nuix>0 );
            assertEqual( numel(voc.unique_objects), 1);
            assertEqual( numel(voc.idx), 1);
        end
        %----------------------------------------------------------------
        function test_change_serializer(obj)
            % Test different serializers
            mi2 = merlin_instrument(190, 700, 'g');
            uoc = unique_objects_container();
            uoc = uoc.add(obj.mi1);
            uoc = uoc.add(mi2);
            voc = unique_objects_container('convert_to_stream_f',@hlp_serialise);
            voc = voc.add(obj.mi1);
            voc = voc.add(mi2);
            ie = isequal( voc.stored_hashes(1,:), uoc.stored_hashes(1,:) );
            assertFalse(ie);
            %{
            Turns out that hashes are not portable between all Matlab
            versions and platforms, so suppressing this bit.
            v1 = uint8(...
                [124   197    72   173   189    40   141    89   154   200    43   138   160    63   243   121] ...
                );
            u1 = uint8(...
                [122    85    30   186    79    64   138   166   121   219   196   239    36   104   116    22]...
                );
            assertEqual( u1, uoc.stored_hashes(1,:) );
            assertEqual( v1, voc.stored_hashes(1,:) );
            %}
        end
        %----------------------------------------------------------------
        function test_constructor_arguments_no_type(obj)

            uoc = unique_objects_container();
            uoc = uoc.add(obj.mi1);
            uoc = uoc.add(obj.nul_sm1);
            assertEqual( numel(uoc.unique_objects), 2);
        end
        function test_constructor_arguments_with_type(obj)
            ws = warning('off','HERBERT:unique_objects_container:invalid_argument');
            clOb = onCleanup(@()warning(ws));

            uoc = unique_objects_container('baseclass','IX_inst');
            uoc = uoc.add(obj.mi1);

            uoc = uoc.add(obj.nul_sm1);
            [~,lw] = lastwarn;
            assertEqual(lw,'HERBERT:unique_objects_container:invalid_argument')
            assertEqual( numel(uoc.unique_objects), 1);
            %{
            Turns out that hashes are not portable between all Matlab
            versions and platforms, so suppressing this bit.

            u1 = uint8(...
                [122    85    30   186    79    64   138   166   121   219   196   239    36   104   116    22]...
                );
            assertEqual( u1, uoc.stored_hashes(1,:) );
            %}
        end
        function test_constructor_arguments_type_serializer(obj)
            ws = warning('off','HERBERT:unique_objects_container:invalid_argument');
            clOb = onCleanup(@()warning(ws));

            uoc = unique_objects_container('baseclass','IX_inst','convert_to_stream_f',@hlp_serialise);

            uoc = uoc.add(obj.mi1);
            uoc = uoc.add(obj.nul_sm1);
            assertEqual( numel(uoc.unique_objects), 1);
            [~,lw] = lastwarn;
            assertEqual(lw,'HERBERT:unique_objects_container:invalid_argument')

            %{
            Turns out that hashes are not portable between all Matlab
            versions and platforms, so suppressing this bit.
            u1 = uint8(...
                [124   197    72   173   189    40   141    89   154   200    43   138   160    63   243   121] ...
                );
            assertEqual( u1, uoc.stored_hashes(1,:) );
            %}
        end

        function test_subscripting_no_type(obj)
            % repeats test_constructor_arguments using subscripting
            uoc = unique_objects_container();
            uoc{1} = obj.mi1;
            uoc{2} = obj.nul_sm1;
            assertEqual( numel(uoc.unique_objects), 2);
        end
        function test_subscripting_type(obj)
            ws = warning('off','HERBERT:unique_objects_container:invalid_argument');
            clOb = onCleanup(@()warning(ws));

            uoc = unique_objects_container('baseclass','IX_inst');
            uoc{1} = obj.mi1;
            uoc{2} = obj.nul_sm1;
            [~,lw] = lastwarn;
            assertEqual(lw,'HERBERT:unique_objects_container:invalid_argument')
            assertEqual( numel(uoc.unique_objects), 1);
            %{
            Turns out that hashes are not portable between all Matlab
            versions and platforms, so suppressing this bit.
            
            u1 = uint8(...
                [122    85    30   186    79    64   138   166   121   219   196   239    36   104   116    22]...
                );
            assertEqual( u1, uoc.stored_hashes(1,:) );
            %}
        end
        function test_subscripting_type_hlp_ser(obj)
            ws = warning('off','HERBERT:unique_objects_container:invalid_argument');
            clOb = onCleanup(@()warning(ws));

            uoc = unique_objects_container('baseclass','IX_inst','convert_to_stream_f',@hlp_serialise);
            uoc{1} = obj.mi1;
            uoc{2} = obj.nul_sm1;
            [~,lw] = lastwarn;
            assertEqual(lw,'HERBERT:unique_objects_container:invalid_argument')
            assertEqual( numel(uoc.unique_objects), 1);
            %{
            Turns out that hashes are not portable between all Matlab
            versions and platforms, so suppressing this bit.            
            u1 = uint8(...
                [124   197    72   173   189    40   141    89   154   200    43   138   160    63   243   121] ...
                );            
            assertEqual( u1, uoc.stored_hashes(1,:) );
            %}
        end
        function test_subscripting_type_hlp_ser_wrong_subscript_plus(obj)
            % additional tests for other subscript functions
            % NB horrible syntax but way to put assignments in anonymous
            % functions is worse! Replacements for assertExceptionThrown
            uoc = unique_objects_container('convert_to_stream_f',@hlp_serialise,'baseclass','IX_inst');
            function set_uoc()
                uoc{2} = obj.mi1;
            end
            ex = assertExceptionThrown(@()set_uoc,'HERBERT:unique_objects_container:invalid_argument');
            assertEqual(ex.message,'index outside legal range')
        end
        function test_subscripting_type_hlp_ser_wrong_subscript_minus(obj)
            uoc = unique_objects_container('convert_to_stream_f',@hlp_serialise,'baseclass','IX_inst');
            function set_uoc()
                uoc{-1} = obj.mi1;
            end
            ex = assertExceptionThrown(@()set_uoc,'HERBERT:unique_objects_container:invalid_argument');
            assertEqual(ex.message,'non-positive index not allowed')

        end
        function test_instr_replacement_with_duplicates_round(obj)
            uoc = unique_objects_container('convert_to_stream_f',@hlp_serialise,'baseclass','IX_inst');
            uoc(1) = obj.mi1;
            uoc(2) = IX_null_inst();
            assertEqual( uoc.n_duplicates,[1,1]);
            assertEqual( uoc.n_runs,2);
            assertEqual( uoc.n_unique,2);
            uoc(3) = obj.mi1;
            assertEqual( uoc.n_runs,3);
            assertEqual(uoc.n_duplicates,[2,1]);
            assertEqual(uoc.n_unique,2);
            uoc(1) = IX_null_inst();
            assertEqual( uoc.n_runs,3);
            assertEqual( uoc.n_duplicates,[1,2]);
            uoc(3) = IX_null_inst();

            assertEqual(uoc.n_runs,3);            
            assertEqual(uoc.n_unique,1);
            assertEqual(uoc.n_duplicates,3);

        end
        
        function test_instr_replacement_with_duplicates_curly(obj)
            uoc = unique_objects_container('convert_to_stream_f',@hlp_serialise,'baseclass','IX_inst');
            uoc{1} = obj.mi1;
            uoc{2} = IX_null_inst();
            assertEqual( uoc.n_duplicates,[1,1]);
            assertEqual( uoc.n_runs,2);
            assertEqual( uoc.n_unique,2);
            uoc{3} = obj.mi1;
            assertEqual( uoc.n_runs,3);
            assertEqual(uoc.n_duplicates,[2,1]);
            assertEqual(uoc.n_unique,2);
            uoc{1} = IX_null_inst();
            assertEqual( uoc.n_runs,3);
            assertEqual( uoc.n_duplicates,[1,2]);
            uoc{3} = IX_null_inst();

            assertEqual(uoc.n_runs,3);            
            assertEqual(uoc.n_unique,1);
            assertEqual(uoc.n_duplicates,3);

        end
    end
end