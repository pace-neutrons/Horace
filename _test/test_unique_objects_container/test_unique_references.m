classdef test_unique_references < TestCase
    properties
        mi1;
        li;
        nul_sm1;
    end

    methods
        function obj=test_unique_references(varargin)
            if nargin>0
                name = varargin{1};
            else
                name  = 'test_unique_references';
            end
            obj = obj@TestCase(name);
            % create two different instruments from a couple of instrument
            % creator functions
            obj.mi1 = merlin_instrument(180, 600, 'g');
            obj.li  = let_instrument(5, 240, 80, 20, 1);
            obj.nul_sm1 = IX_null_sample();

        end
        %
        %------------------------------------------------------------------
        function test_basic_doubles_container(~)
            urc = unique_references_container('Doubles', 'double');
            urc.global_container('CLEAR', 'Doubles');
            glc = urc.global_container('value', 'Doubles');
            assertTrue( isa( glc, 'unique_objects_container') );
            assertEqual( glc.n_runs, 0);
            assertTrue( strcmp( urc.global_name, 'Doubles' ) );
            urc = urc.add(0.111);
            urc = urc.add(0.222);
            urc = urc.add(0.333);
            urc = urc.add(0.222);
            
            assertEqual(urc{1}, 0.111);
            assertEqual(urc{2}, 0.222);
            assertEqual(urc{3}, 0.333);
            assertEqual(urc{4}, 0.222);
            assertEqual( urc.n_runs, 4);
            
            urc{1} = 0.555;
            assertEqual(urc{1}, 0.555);    
            [is, ind] = urc.contains(0.555);
            assertTrue(is);
            assertEqual(ind, 4);
            [is, ind] = urc.contains(0.111);
            assertFalse(is);
            assertTrue( isempty(ind) );
            [is, ind] = urc.contains(0.222);
            assertTrue(is);
            assertEqual(ind,2);
            [is, ind] = urc.contains(0.333);
            assertTrue(is);
            assertEqual(ind,3);

            glc = urc.global_container('value', 'Doubles');
            assertTrue( isa( glc, 'unique_objects_container') );
            assertEqual( glc.n_runs, 4);
        end
        
        function test_basic_instruments_container(obj)
            urc = unique_references_container('Instruments', 'IX_inst');
            urc.global_container('CLEAR', 'Instruments');
            glc = urc.global_container('value', 'Instruments');
            assertTrue( isa( glc, 'unique_objects_container') );
            assertEqual( glc.n_runs, 0);
            assertTrue( strcmp( urc.global_name, 'Instruments' ) );
            
            urc = urc.add(obj.mi1);
            urc = urc.add(IX_null_inst());
            urc = urc.add(merlin_instrument(185, 600, 'g'));
            urc = urc.add(IX_null_inst());

            assertEqual(urc.n_runs,4)

            % with nargout==2
            [is,ind] = urc.contains(obj.mi1);
            assertTrue(is);
            assertEqual(ind,1);
            % with nargout==1
            is = urc.contains(obj.mi1);
            assertTrue(is);
            
            [is,ind] = urc.contains(IX_null_inst());
            assertTrue(is);
            assertEqual(ind,2);
            is = urc.contains(IX_null_inst());
            assertTrue(is);
            
            inst = urc{1};
            assertTrue( strcmp(inst.name,'MERLIN') );
            inst = urc{2};
            assertTrue( strcmp(inst.name,'') );
            inst = urc{3};
            assertTrue( strcmp(inst.name,'MERLIN') );
            
            glc = urc.global_container('value', 'Instruments');
            assertTrue( isa( glc, 'unique_objects_container') );
            assertEqual( glc.n_runs, 3);
            assertTrue( strcmp( urc.global_name, 'Instruments' ) );

            inst = IX_null_inst();
            inst.name = 'NULL';
            [is,ind] = urc.contains(inst);
            assertFalse(is);
            assertTrue( isempty(ind) );
            
            urc{4} = inst;
            inst = urc{4};
            assertTrue( strcmp(inst.name,'NULL') );            

            glc = urc.global_container('value', 'Instruments');
            assertTrue( isa( glc, 'unique_objects_container') );
            assertEqual( glc.n_runs, 4);
            assertTrue( strcmp( urc.global_name, 'Instruments' ) );
            
            % test contains for a class name instead of an object value
            [is,ind] = urc.contains('IX_null_inst');
            assertTrue(is);
            assertEqual(ind, [2 4]);
        end

        function test_add_non_unique_objects(obj)

            % make a unique_objects_container (empty)
            urc = unique_references_container('Instruments', 'IX_inst');
            urc.global_container('CLEAR', 'Instruments');
            glc = urc.global_container('value', 'Instruments');
            assertTrue( isa( glc, 'unique_objects_container') );
            assertEqual( glc.n_runs, 0);
            assertTrue( strcmp( urc.global_name, 'Instruments' ) );

            % add 3 identical instruments to the container
            urc{1} = obj.li;
            urc{2} = obj.li;
            urc{3} = obj.li;
            % add 2 more instruments, identical to each other but not the
            % first 3
            urc{4} = obj.mi1;
            urc{5} = obj.mi1;
            % add another instrument same as the first 3
            urc{6} = obj.li;

            % test that we put 6 instruments in the container
            assertEqual( numel(urc.idx), 6);

            % test that there are only 2 uniquely different instruments in
            % the container
            assertEqual( urc.n_unique_objects, 2);


            % test that the first 3 instruments in the container are the
            % same as instrument li
            % also tests that the get method for retrieving the non-unique
            % objects is working
            for i=1:3
                assertEqual(obj.li, urc.get(i) );
                assertEqual(obj.li, urc{i} );
            end

            % test that the next 2 instruments in the container are the
            % same as instrument mi
            for i=4:5
                assertEqual(obj.mi1, urc.get(i) );
                assertEqual(obj.mi1, urc{i} );
            end

            % test that the last instrument in the container is also the
            % same as instrument li
            assertEqual(obj.li, urc.get(6) );
            assertEqual(obj.li, urc{6} );
        end
        
        function test_replace_unique_different_number_throw(~)

            unique_references_container.global_container('CLEAR','CStrings');
            urc = unique_references_container('CStrings','char');
            urc(1) = 'aaaaa';
            urc(2) = 'bbbb';
            urc(3) = 'bbbb';
            function thrower()
                % unique_objects should be set with a
                % unique_objects_container, here it is set to a string
                % which should throw
                urc.unique_objects = 'bbbb';
            end
            assertExceptionThrown(@()thrower, ...
                'HERBERT:unique_references_container:invalid_argument');
            
            uoc = unique_objects_container('baseclass','char');     
            uoc{1} = 'xxxx';
            uoc{2} = 'yyyy';
            uoc{3} = 'zzzz';
            urc.unique_objects = uoc;
            
            uoc = unique_objects_container('baseclass','double');     
            uoc{1} = 0.111;
            uoc{2} = 0.222;
            uoc{3} = 0.333;
            function wrong_baseclass_thrower()
                urc.unique_objects = uoc;
            end
            assertExceptionThrown(@() wrong_baseclass_thrower, ...
                'HERBERT:unique_references_container:invalid_argument');
        end
        
        function test_replace_unique_objects_with_cellarray_throw(~)

            unique_references_container.global_container('CLEAR','CStrings');
            urc = unique_references_container('CStrings','char');
            urc(1) = 'aaaaa';
            urc(2) = 'bbbb';
            urc(3) = 'bbbb';
            function thrower()
                urc.unique_objects = {'AA','AA'};
            end
            assertExceptionThrown(@()thrower, ...
                'HERBERT:unique_references_container:invalid_argument');

        end

        function test_replace_unique_same_number_works(~)

            unique_references_container.global_container('CLEAR','CStrings');
            urc = unique_references_container('CStrings','char');
            urc(1) = 'aaaaa';
            urc(2) = 'bbbb';
            urc(3) = 'bbbb';
            
            uoc2 = unique_objects_container('baseclass','char');
            uoc2(1) = 'dd';
            uoc2(2) = 'cc';
            urc.unique_objects = uoc2;

            assertEqual(urc(1),'dd') 
            assertEqual(urc(2),'cc')
            assertEqual(urc(3),'cc')
        end


        function test_remove_noncomplying_first_kept(obj)

            uoc = unique_objects_container();
            uoc(1) = obj.mi1;
            uoc(2) = 'aaaaa';
            uoc(3) = obj.mi1;
            uoc(4) = 10;
            uoc(5) = obj.li;
            uoc(6) = 20;
            uoc(7) = obj.li;
            uoc(8) = 'aaaaa';

            assertEqual(uoc.n_runs,8);
            assertEqual(uoc.n_unique,5);

            uoc.baseclass = 'IX_inst';
            assertEqual(uoc.n_runs,4)
            assertEqual(uoc.n_unique,2)
            assertEqual(uoc.n_duplicates,[2,2])
        end

        function test_remove_noncomplying_first_removed(obj)

            uoc = unique_objects_container();
            uoc(1) = 'aaaaa';
            uoc(2) = 'aaaaa';
            uoc(3) = obj.mi1;
            uoc(4) = 10;
            uoc(5) = obj.li;
            uoc(6) = 20;
            uoc(7) = obj.li;

            assertEqual(uoc.n_runs,7);
            assertEqual(uoc.n_unique,5);

            uoc.baseclass = 'IX_inst';
            assertEqual(uoc.n_runs,3)
            assertEqual(uoc.n_unique,2)
            assertEqual(uoc.n_duplicates,[1,2])
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
        function test_expand_to_nruns(obj)
            uoc = unique_objects_container('baseclass','IX_inst');
            uoc{1} = obj.mi1;
            assertEqual(uoc.n_runs,1)
            assertEqual(uoc.n_unique,1)

            uoc = uoc.replicate_runs(10);
            assertEqual(uoc.n_runs,10);
            assertEqual(uoc.n_unique,1);
            assertEqual(uoc.n_duplicates,10);

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
        function test_serialization_with_objects(obj)
            uoc = unique_objects_container('baseclass','IX_inst');
            uoc{1} = obj.mi1;
            uoc{2} = IX_null_inst();
            uoc_str = uoc.to_struct();

            uoc_rec = serializable.from_struct(uoc_str);
            assertEqual(uoc,uoc_rec)
        end

        function test_serialization_empty(~)
            uoc = unique_objects_container('baseclass','IX_inst');
            uoc_str = uoc.to_struct();

            uoc_rec = serializable.from_struct(uoc_str);
            assertEqual(uoc,uoc_rec)
        end
    end
end