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
        function test_save_load_two_objects_add_to_experiment(obj)
            %TODO there is a lot of testing of Experiment here and this may
            %be better positioned in test_experiment
            clObC = onCleanup(@()unique_references_container.global_container('CLEAR','GLOBAL_NAME_SAMPLES_CONTAINER'));
            %
            ws = warning('off','HERBERT:unique_references_container:debug_only_argument');
            clOb = onCleanup(@()warning(ws));
            
            unique_references_container.global_container('CLEAR','GLOBAL_NAME_SAMPLES_CONTAINER');

            
            % test initialisation of an Experiment with 1 run - see next
            % test for what happens initialising individual components for
            % an empty Experiment()
            ed = IX_experiment();
            det = IX_detector_array();
            sam1 = IX_samp(4,90);
            ex1 = Experiment(det, obj.li, sam1, ed);
            assertEqual(ex1.samples(1),sam1);

            % test initialisation of an Experiment with 3 runs, and then
            % modify individual components
            ed2 = [ed, ed, ed];
            det2 = [det, det, det];
            inst2 = { obj.li, obj.li, obj.li };
            sam2 = { IX_samp(3,90), IX_samp(3.1, 90), IX_samp(3.2, 90) };
            ex2 = Experiment(det2, inst2, sam2, ed2);
            
            ex2.samples(1) = IX_samp(3,80);
            ex2.samples(2) = IX_samp(3.1,80);
            ex2.samples(3) = IX_samp(3.2,80);
            
            assertEqual(ex2.samples(1),IX_samp(3,80));
            
            % check the state of the global container
            gc = unique_references_container.global_container('value','GLOBAL_NAME_SAMPLES_CONTAINER');
            assertEqual(gc.n_objects,7); % sam1, sam2 and the replacements into ex2

            % test conversion to struct and clearing of all sample objects
            % associated with ex2, and then its restoration and checking
            % that the global container is restored
            ser_str = ex2.to_struct();
            clear('exp2','exp1');
            unique_references_container.global_container('CLEAR','GLOBAL_NAME_SAMPLES_CONTAINER');

            ex2_rec = serializable.from_struct(ser_str);

            gc = unique_references_container.global_container('value','GLOBAL_NAME_SAMPLES_CONTAINER');
            assertEqual(gc.n_objects,3);
            assertEqual(gc.unique_objects{1},ex2_rec.samples(1));
            assertEqual(gc.unique_objects{3},ex2_rec.samples(3));
        end

        %
        function test_save_load_add_to_experiment(obj)
            %TODO there is a lot of testing of Experiment here and this may
            %be better positioned in test_experiment
            
            % depending on how many times this test or others has been run,
            % the global samples container may contain various other
            % samples which may cause problems for the current test. To
            % allow this test to run without those complications, clear the
            % global samples container with the next line. In principle
            % this should not be needed, and it can be left commented.
            %unique_references_container.global_container('CLEAR','GLOBAL_NAME_SAMPLES_CONTAINER');

            % adding a sample to an empty Experiment() will fail as the
            % number of runs is defined by the number of IX_experiments it
            % contains, so Experiment() has no runs and ex.sample{1} = sam
            % will not work. ### TESTING GIT
            sam = IX_samp(4,90);
            ex = Experiment();
            function throw1()
                ex.samples{1} = sam;
            end
            assertExceptionThrown(@throw1, 'HORACE:Experiment:invalid_argument');
            % So ex is here initially defined with a complete
            % complement of contents, and afterwards the first sample can
            % be succesfully modified.
            ed = IX_experiment();
            det = IX_detector_array();
            ex = Experiment(det,obj.li,sam,ed);
            assertEqual(ex.samples(1),sam);
            sam2 = IX_samp(5,80);
            ex.samples{1} = sam2;
            assertEqual(ex.samples(1),sam2);
            
            % Now test save/load
            wkdir = tmp_dir();
            sample_file = fullfile(wkdir,'test_save_load_add_to_experiment.mat');
            save(sample_file,'ex');
            clOb = onCleanup(@()delete(sample_file ));

            ld = load(sample_file);
            assertEqual(ld.ex,ex);
        end
        %
        %------------------------------------------------------------------
        function test_basic_doubles_container(~)
            ws = warning('off','HERBERT:unique_references_container:debug_only_argument');
            clOb = onCleanup(@()warning(ws));
            urc = unique_references_container('GLOBAL_NAME_TEST_BASIC_DOUBLES_CONTAINER_DOUBLES', 'double');
            urc.global_container('CLEAR', 'GLOBAL_NAME_TEST_BASIC_DOUBLES_CONTAINER_DOUBLES');
            glc = urc.global_container('value', 'GLOBAL_NAME_TEST_BASIC_DOUBLES_CONTAINER_DOUBLES');
            assertTrue( isa( glc, 'unique_objects_container') );
            assertEqual( glc.n_objects, 0);
            assertEqual( urc.global_name, 'GLOBAL_NAME_TEST_BASIC_DOUBLES_CONTAINER_DOUBLES' );
            urc = urc.add(0.111);
            urc = urc.add(0.222);
            urc = urc.add(0.333);
            urc = urc.add(0.222);

            assertEqual(urc{1}, 0.111);
            assertEqual(urc{2}, 0.222);
            assertEqual(urc{3}, 0.333);
            assertEqual(urc{4}, 0.222);
            % n_runs and n_objects perform the same function
            % n_objects provides a domain-agnostic interface
            % n_runs provides a SQW-specific domain interface
            assertEqual( urc.n_runs, 4);
            assertEqual( urc.n_objects, 4);

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

            [is,ind]=urc.contains('double');
            assertTrue(is);
            assertEqual(ind,[1 2 3 4]);

            glc = urc.global_container('value', 'GLOBAL_NAME_TEST_BASIC_DOUBLES_CONTAINER_DOUBLES');
            assertTrue( isa( glc, 'unique_objects_container') );
            assertEqual( glc.n_objects, 4);
        end

        function test_save_load(~)
            ws = warning('off','HERBERT:unique_references_container:debug_only_argument');
            clOb = onCleanup(@()warning(ws));
            urc = unique_references_container('GLOBAL_NAME_TEST_BASIC_DOUBLES_CONTAINER_DOUBLES', 'double');
            urc.global_container('CLEAR', 'GLOBAL_NAME_TEST_BASIC_DOUBLES_CONTAINER_DOUBLES');
            glc = urc.global_container('value', 'GLOBAL_NAME_TEST_BASIC_DOUBLES_CONTAINER_DOUBLES');
            urc = urc.add(0.111);
            urc = urc.add(0.222);
            urc = urc.add(0.333);
            urc = urc.add(0.222);
            save('test_unique_references_container_save_load_1.mat','urc');
            zzz = load('test_unique_references_container_save_load_1.mat');
            assertEqual(zzz.urc, urc);
        end

        function test_add_multiple(~)
            ws = warning('off','HERBERT:unique_references_container:debug_only_argument');
            clOb = onCleanup(@()warning(ws));
            urc = unique_references_container('GLOBAL_NAME_TEST_BASIC_DOUBLES_CONTAINER_DOUBLES', 'double');
            urc.global_container('CLEAR', 'GLOBAL_NAME_TEST_BASIC_DOUBLES_CONTAINER_DOUBLES');
            urc = urc.add([0.222 0.333 0.444]);
            urc = urc.add({0.555 0.666});
            uoc = unique_objects_container('baseclass','double');
            uoc{1} = 0.777;
            uoc{2} = 0.888;
            urc = urc.add(uoc);
            assertEqual(urc{5}, 0.666);
            assertEqual(urc(7), 0.888);
            assertEqual(urc.n_objects,7);
        end

        function test_basic_instruments_container(obj)
            ws = warning('off','HERBERT:unique_references_container:debug_only_argument');
            clOb = onCleanup(@()warning(ws));


            urc = unique_references_container('GLOBAL_NAME_INSTRUMENTS_CONTAINER', 'IX_inst');
            urc.global_container('CLEAR', 'GLOBAL_NAME_INSTRUMENTS_CONTAINER');
            glc = urc.global_container('value', 'GLOBAL_NAME_INSTRUMENTS_CONTAINER');
            assertTrue( isa( glc, 'unique_objects_container') );
            assertEqual( glc.n_objects, 0);
            assertEqual( urc.global_name, 'GLOBAL_NAME_INSTRUMENTS_CONTAINER' );

            urc = urc.add(obj.mi1);
            urc = urc.add(IX_null_inst());
            % testing a different merlin instrument from obj.mi1 above
            urc = urc.add(merlin_instrument(185, 600, 'g'));
            % testing the same merlin instrument as obj.mi1 above, using
            % explicit construction
            urc = urc.add(merlin_instrument(180, 600, 'g'));
            urc = urc.add(IX_null_inst());

            assertEqual(urc.n_runs,5)
            assertEqual(urc.n_objects,5)
            assertEqual(urc.n_unique_objects,3);

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
            assertEqual( inst.name,'MERLIN' );
            inst = urc{2};
            assertEqual( inst.name,'' );
            inst = urc{3};
            assertEqual( inst.name,'MERLIN' );

            [is,ind]=urc.contains('IX_inst');
            assertTrue(is);
            assertEqual(ind,[1 2 3 4 5]);

            [is,ind]=urc.contains('IX_null_inst');
            assertTrue(is);
            assertEqual(ind,[2 5]);

            glc = urc.global_container('value', 'GLOBAL_NAME_INSTRUMENTS_CONTAINER');
            assertTrue( isa( glc, 'unique_objects_container') );
            assertEqual( glc.n_objects, 3);
            assertEqual( urc.global_name, 'GLOBAL_NAME_INSTRUMENTS_CONTAINER' );

            inst = IX_null_inst();
            inst.name = 'NULL';
            [is,ind] = urc.contains(inst);
            assertFalse(is);
            assertTrue( isempty(ind) );

            urc{4} = inst;
            inst = urc{4};
            assertEqual( inst.name,'NULL' );

            glc = urc.global_container('value', 'GLOBAL_NAME_INSTRUMENTS_CONTAINER');
            assertTrue( isa( glc, 'unique_objects_container') );
            assertEqual( glc.n_objects, 4);
            assertEqual( urc.global_name, 'GLOBAL_NAME_INSTRUMENTS_CONTAINER' );

            % test contains for a class name instead of an object value
            [is,ind] = urc.contains('IX_null_inst');
            assertTrue(is);
            assertEqual(ind, [2 4 5]);
        end

        function test_add_non_unique_objects(obj)
            ws = warning('off','HERBERT:unique_references_container:debug_only_argument');
            clOb = onCleanup(@()warning(ws));

            % make a unique_objects_container (empty)
            urc = unique_references_container('GLOBAL_NAME_INSTRUMENTS_CONTAINER', 'IX_inst');
            urc.global_container('CLEAR', 'GLOBAL_NAME_INSTRUMENTS_CONTAINER');
            glc = urc.global_container('value', 'GLOBAL_NAME_INSTRUMENTS_CONTAINER');
            assertTrue( isa( glc, 'unique_objects_container') );
            assertEqual( glc.n_objects, 0);
            assertEqual( urc.global_name, 'GLOBAL_NAME_INSTRUMENTS_CONTAINER' );

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
            assertEqual( numel(urc.idx), 6 );

            % test that there are only 2 uniquely different instruments in
            % the container
            assertEqual( urc.n_unique_objects, 2 );


            % test that the first 3 instruments in the container are the
            % same as instrument li
            % also tests that the get method for retrieving the non-unique
            % objects is working
            for i=1:3
                assertEqual( obj.li, urc.get(i) );
                assertEqual( obj.li, urc{i} );
            end

            % test that the next 2 instruments in the container are the
            % same as instrument mi
            for i=4:5
                assertEqual( obj.mi1, urc.get(i) );
                assertEqual( obj.mi1, urc{i} );
            end

            % test that the last instrument in the container is also the
            % same as instrument li
            assertEqual( obj.li, urc.get(6) );
            assertEqual( obj.li, urc{6} );
        end

        function test_replace_unique_different_number_throw(~)
            ws = warning('off','HERBERT:unique_references_container:debug_only_argument');
            clOb = onCleanup(@()warning(ws));

            unique_references_container.global_container('CLEAR','GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_CSTRINGS');
            urc = unique_references_container('GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_CSTRINGS','char');
            urc(1) = 'aaaaa';
            urc(2) = 'bbbb';
            urc(3) = 'bbbb';
            function thrower()
                % unique_objects should be set with a
                % unique_objects_container, here it is set to a string
                % which should throw
                urc.unique_objects = 'bbbb';
            end
            assertExceptionThrown(@thrower, ...
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
            assertExceptionThrown(@wrong_baseclass_thrower, ...
                'HERBERT:unique_references_container:invalid_argument');
        end

        function test_replace_unique_objects_with_cellarray_throw(~)
            ws = warning('off','HERBERT:unique_references_container:debug_only_argument');
            clOb = onCleanup(@()warning(ws));

            unique_references_container.global_container('CLEAR','GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_CSTRINGS');
            urc = unique_references_container('GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_CSTRINGS','char');
            urc(1) = 'aaaaa';
            urc(2) = 'bbbb';
            urc(3) = 'bbbb';
            function thrower()
                urc.unique_objects = {'AA','AA'};
            end
            assertExceptionThrown(@thrower, ...
                'HERBERT:unique_references_container:invalid_argument');

        end

        %{
        % commenting out rather than skipping but still keeping for future
        % reference including the skip
function test_replace_unique_same_number_works(~)
            skipTest(['This does not work for unique_reference_containers ', ...
                      ' as they do not separately store the unique objects.', ...
                      ' Test kept and skipped as a reminder of this.']);
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
        %}

        function test_baseclass_issues(obj)
            ws = warning('off','HERBERT:unique_references_container:debug_only_argument');
            clOb = onCleanup(@()warning(ws));
            ws = warning('off','HERBERT:unique_objects_container:invalid_argument');
            clOb1 = onCleanup(@()warning(ws));

            % legal constructor with no arguments but cannot be used until
            % populated e.g. with loadobj
            urc1 = unique_references_container();
            % so this will throw
            function throw1()
                urc1(1) = obj.mi1;
            end
            assertExceptionThrown( @throw1, ...
                'HERBERT:unique_references_container:incomplete_setup');
            [lwn,lw] = lastwarn;
            assertEqual(lw,'HERBERT:unique_references_container:incomplete_setup');
            assertEqual(lwn, 'baseclass not initialised, using first assigned type');

            % setup container of char
            unique_references_container('CLEAR','GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_CSTRINGS2');
            urc2 = unique_references_container('GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_CSTRINGS2','char');
            urc2(1) = 'aaaaa'; % should work fine

            % fail extending with wrong type
            assertEqual(urc2.n_runs,1);
            assertEqual(urc2.n_objects,1);
            urc2(2) = obj.mi1;
            [lwn,lw] = lastwarn;
            assertEqual(lwn,'not correct stored base class; object was not added');
            assertEqual(urc2.n_runs,1); % warning was issued and object was not added
            assertEqual(urc2.n_objects,1); % warning was issued and object was not added

            % fail inserting with wrong type
            urc2(1) = obj.mi1;
            assertEqual( urc2(1),'aaaaa'); % warning was issued and object was not replaced
        end

        %----------------------------------------------------------------
        function test_add_similar_non_unique_objects(obj)
            ws = warning('off','HERBERT:unique_references_container:debug_only_argument');
            clOb = onCleanup(@()warning(ws));

            mi2 = merlin_instrument(190, 700, 'g');
            assertFalse( isequal(obj.mi1,mi2) );

            unique_references_container.global_container('CLEAR','GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_MERLINS');
            urc = unique_references_container('GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_MERLINS','IX_inst_DGfermi');
            [urc,nuix] = urc.add(obj.mi1);
            assertEqual( nuix, 1 );
            [urc,nuix] = urc.add(mi2);
            assertEqual( nuix, 2 );
            [urc,nuix] = urc.add(obj.mi1);
            assertEqual( nuix, 3 );
            [urc,nuix] = urc.add(mi2);
            assertEqual( nuix, 4 );
            [urc,nuix] = urc.add(mi2);
            assertEqual( nuix, 5 );
            assertEqual( urc.unique_objects.n_unique, 2);
            assertEqual( urc.n_unique_objects, 2);
            assertEqual( numel(urc.idx), 5 );
            assertEqual( obj.mi1, urc(3) );
            assertEqual( mi2, urc.get(5) );

            % repeat using subscript assign rather than add
            unique_references_container.global_container('CLEAR','GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_MERLINS');
            urc = unique_references_container('GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_MERLINS','IX_inst_DGfermi');
            urc{1} = obj.mi1;
            assertEqual( urc.n_runs, 1);
            assertEqual( urc.n_objects, 1);
            urc{2} = mi2;
            assertEqual( urc.n_runs, 2);
            assertEqual( urc.n_objects, 2);
            urc{3} = obj.mi1;
            assertEqual( urc.n_runs, 3);
            assertEqual( urc.n_objects, 3);
            assertEqual( urc.n_unique_objects, 2);
            urc(4) = mi2;
            assertEqual( urc.n_runs, 4);
            assertEqual( urc.n_objects, 4);
            assertEqual( urc.n_unique_objects, 2);
            urc(5) = mi2;
            assertEqual( urc.n_runs, 5);
            assertEqual( urc.n_objects, 5);
            assertEqual((urc.unique_objects.n_unique), 2);
            assertEqual( urc.n_unique_objects, 2);
            assertEqual( numel(urc.idx), 5);
            assertEqual( obj.mi1, urc.get(3) );
            assertEqual( mi2, urc(5) );

            % check for fail outside range
            function throw171()
                urc{7} = obj.mi1;
            end
            assertExceptionThrown( @throw171, ...
                'HERBERT:unique_references_container:invalid_argument');
            function throw1m1()
                urc{0} = obj.mi1;
            end
            assertExceptionThrown( @throw1m1, ...
                'HERBERT:unique_references_container:invalid_argument');
        end
        %----------------------------------------------------------------
        function test_add_different_types(obj)
            ws = warning('off','HERBERT:unique_references_container:debug_only_argument');
            clOb = onCleanup(@()warning(ws));
            ws = warning('off','HERBERT:unique_objects_container:invalid_argument');
            clOb1 = onCleanup(@()warning(ws));

            unique_references_container.global_container('CLEAR','GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_MERLINS');
            urc = unique_references_container('GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_MERLINS','IX_inst_DGfermi');
            % object of correct type added
            urc = urc.add(obj.mi1);
            % object of incorrect type not added, warning issued, size
            % still 1
            assertEqual( urc.n_runs, 1);
            assertEqual( urc.n_objects, 1);
            urc = urc.add(obj.nul_sm1);
            % object not added, size unchanges, warning issued
            assertEqual( urc.n_runs, 1);
            assertEqual( urc.n_objects, 1);
            assertEqual( lastwarn, 'not correct stored base class; object was not added');

            unique_references_container.global_container('CLEAR','GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_NULLSAMPLES');
            urc = unique_references_container('GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_NULLSAMPLES','IX_null_sample');
            % object of correct type added
            [urc, nuix] = urc.add(obj.nul_sm1);
            % object of incorrect type not added, warning issued, size
            % still 1
            assertEqual(nuix, 1);
            assertEqual( urc.n_runs, 1 );
            assertEqual( urc.n_objects, 1 );
            [urc, nuix] = urc.add(obj.mi1);
            assertEqual(lastwarn,'not correct stored base class; object was not added');

            % object of incorrect type not added, warning issued, size
            % still 1, addition index 0 => not added
            assertEqual(nuix, 0);
            assertEqual( urc.n_runs, 1 );
            assertEqual( urc.n_objects, 1 );
            assertEqual( lastwarn, 'not correct stored base class; object was not added');
        end
        %----------------------------------------------------------------
        function test_change_serializer(obj)
            % Test different serializers
            ws = warning('off','HERBERT:unique_references_container:debug_only_argument');
            clOb = onCleanup(@()warning(ws));
            unique_references_container.global_container('CLEAR','GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_MERLINS');
            urc = unique_references_container('GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_MERLINS','IX_inst_DGfermi');
            glc = urc.global_container('value','GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_MERLINS');
            glc.convert_to_stream_f = @hlp_serialise;
            urc.global_container('reset','GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_MERLINS',glc);

            mi2 = merlin_instrument(190, 700, 'g');
            urc = urc.add(obj.mi1);
            urc = urc.add(mi2);
            glc = urc.global_container('value','GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_MERLINS');

            unique_references_container.global_container('CLEAR','GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_MERLINS2');
            vrc = unique_references_container('GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_MERLINS2','IX_inst_DGfermi');
            hlc = vrc.global_container('value','GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_MERLINS2');
            %hlc.convert_to_stream_f = @hlp_serialise;

            vrc = vrc.add(obj.mi1);
            vrc = vrc.add(mi2);
            hlc = vrc.global_container('value','GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_MERLINS2');

            ie = isequal( hlc.stored_hashes(1,:), glc.stored_hashes(1,:) );
            assertFalse(ie);
            ie = isequal( glc.convert_to_stream_f, hlc.convert_to_stream_f);
            assertFalse(ie);
            %{
            Turns out that hashes are not portable between all Matlab
            versions and platforms, so suppressing hash comparisons.
            assertEqual( u1, uoc.stored_hashes(1,:) );
            assertEqual( v1, voc.stored_hashes(1,:) );
            %}
        end
        %----------------------------------------------------------------
        function test_global_container_spans_multiple_containers(obj)
            ws = warning('off','HERBERT:unique_references_container:debug_only_argument');
            clOb = onCleanup(@()warning(ws));

            unique_references_container.global_container('CLEAR','GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_MERLINS');
            urc = unique_references_container('GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_MERLINS','IX_inst_DGfermi');
            vrc = unique_references_container('GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_MERLINS','IX_inst_DGfermi');

            mi1 = merlin_instrument(190, 700, 'g');
            mi2 = merlin_instrument(200, 700, 'g');
            mi3 = merlin_instrument(190, 800, 'g');
            mi4 = merlin_instrument(200, 800, 'g');

            urc = urc.add(mi1);
            urc = urc.add(mi2);
            vrc = urc.add(mi3);
            vrc = urc.add(mi4);

            glc = urc.global_container('value','GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_MERLINS');
            hlc = vrc.global_container('value','GLOBAL_NAME_TEST_UNIQUE_REFERENCES_CONTAINER_MERLINS');
            assertEqual( glc, hlc);
            assertEqual( glc.n_objects, hlc.n_objects );
            assertEqual( glc.n_objects, 4 );
        end
        %----------------------------------------------------------------
        function test_subscripting_type(obj)
            ws = warning('off','HERBERT:unique_references_container:debug_only_argument');
            clOb = onCleanup(@()warning(ws));
            ws = warning('off','HERBERT:unique_objects_container:invalid_argument');
            clOb1 = onCleanup(@()warning(ws));

            unique_references_container.global_container('CLEAR','GLOBAL_NAME_INSTRUMENTS_CONTAINER');
            urc = unique_references_container('GLOBAL_NAME_INSTRUMENTS_CONTAINER','IX_inst');
            urc{1} = obj.mi1;
            urc{2} = obj.nul_sm1;
            [lwn,lw] = lastwarn;
            assertEqual(lw,'HERBERT:unique_references_container:invalid_argument');
            assertEqual(lwn,'not correct stored base class; object was not added');
            assertEqual( urc.n_unique_objects, 1);
            %{
            Turns out that hashes are not portable between all Matlab
            versions and platforms, so suppressing this bit.
            assertEqual( u1, uoc.stored_hashes(1,:) );
            %}
        end
        %----------------------------------------------------------------
        function test_subscripting_type_hlp_ser(obj)
            ws = warning('off','HERBERT:unique_references_container:debug_only_argument');
            clOb = onCleanup(@()warning(ws));
            ws = warning('off','HERBERT:unique_objects_container:invalid_argument');
            clOb1 = onCleanup(@()warning(ws));

            unique_references_container.global_container('CLEAR','GLOBAL_NAME_INSTRUMENTS_CONTAINER');
            urc = unique_references_container('GLOBAL_NAME_INSTRUMENTS_CONTAINER','IX_inst');
            glc = urc.global_container('value','GLOBAL_NAME_INSTRUMENTS_CONTAINER');
            glc.convert_to_stream_f = @hlp_serialize;
            unique_references_container.global_container('reset','GLOBAL_NAME_INSTRUMENTS_CONTAINER',glc);
            glc = urc.global_container('value','GLOBAL_NAME_INSTRUMENTS_CONTAINER');
            assertEqual( glc.convert_to_stream_f, @hlp_serialize);
            urc{1} = obj.mi1;
            urc{2} = obj.nul_sm1;
            [lwn,lw] = lastwarn;
            assertEqual(lw,'HERBERT:unique_references_container:invalid_argument');
            assertEqual(lwn,'not correct stored base class; object was not added');
            assertEqual( urc.n_unique_objects, 1);
            %{
            Turns out that hashes are not portable between all Matlab
            versions and platforms, so suppressing this bit.
            u1 = uint8(...
                [124   197    72   173   189    40   141    89   154   200    43   138   160    63   243   121] ...
                );
            assertEqual( u1, uoc.stored_hashes(1,:) );
            %}
        end
        %----------------------------------------------------------------
        function test_subscripting_type_hlp_ser_wrong_subscript_plus(obj)
            % additional tests for other subscript functions
            ws = warning('off','HERBERT:unique_references_container:debug_only_argument');
            clOb = onCleanup(@()warning(ws));
            unique_references_container.global_container('CLEAR','GLOBAL_NAME_INSTRUMENTS_CONTAINER');
            urc = unique_references_container('GLOBAL_NAME_INSTRUMENTS_CONTAINER','IX_inst');
            function set_urc()
                urc{2} = obj.mi1;
            end
            ex = assertExceptionThrown(@()set_urc,'HERBERT:unique_references_container:invalid_argument');
            assertEqual(ex.message,'subscript 2 out of range 1..0')
        end
        %----------------------------------------------------------------
        function test_subscripting_type_hlp_ser_wrong_subscript_minus(obj)
            % additional tests for other subscript functions
            ws = warning('off','HERBERT:unique_references_container:debug_only_argument');
            clOb = onCleanup(@()warning(ws));
            unique_references_container.global_container('CLEAR','GLOBAL_NAME_INSTRUMENTS_CONTAINER');
            urc = unique_references_container('GLOBAL_NAME_INSTRUMENTS_CONTAINER','IX_inst');
            function set_urc()
                urc{2} = obj.mi1;
            end
            ex = assertExceptionThrown(@set_urc,'HERBERT:unique_references_container:invalid_argument');
            assertEqual(ex.message,'subscript 2 out of range 1..0')

        end
        %-----------------------------------------------------------------
        function test_expand_to_nruns(obj)
            ws = warning('off','HERBERT:unique_references_container:debug_only_argument');
            clOb = onCleanup(@()warning(ws));
            unique_references_container.global_container('CLEAR','GLOBAL_NAME_INSTRUMENTS_CONTAINER');
            urc = unique_references_container('GLOBAL_NAME_INSTRUMENTS_CONTAINER','IX_inst');
            urc{1} = obj.mi1;
            assertEqual(urc.n_runs,1)
            assertEqual(urc.n_objects,1)
            assertEqual(urc.n_unique_objects,1)

            urc = urc.replicate_runs(10);
            assertEqual(urc.n_runs,10);
            assertEqual(urc.n_objects,10);
            assertEqual(urc.n_unique_objects,1);
        end
        %-----------------------------------------------------------------
        function test_serialization_empty(obj)
            ws = warning('off','HERBERT:unique_references_container:debug_only_argument');
            clOb = onCleanup(@()warning(ws));
            unique_references_container.global_container('CLEAR','GLOBAL_NAME_INSTRUMENTS_CONTAINER');
            urc = unique_references_container('GLOBAL_NAME_INSTRUMENTS_CONTAINER','IX_inst');
            urc_str = urc.to_struct();

            urc_rec = serializable.from_struct(urc_str);
            assertEqual(urc,urc_rec)

            urc{1} = obj.mi1;
            urc{2} = obj.mi1;
            urc_str = urc.to_struct();

            urc_rec = serializable.from_struct(urc_str);
            assertEqual(urc,urc_rec);
        end
        %-----------------------------------------------------------------
        function test_property_reset_issues(obj)
            urc = unique_references_container('Joby','double');
            urc = urc.add([3,4,5]);
            function throw()
                urc.stored_baseclass = 'IX_inst';
            end
            assertExceptionThrown(@throw, 'HERBERT:unique_references_container:invalid_argument');
            urc.stored_baseclass = 'double';
            urc2 = unique_references_container('Joby2','');
            function throw2()
                urc2.add([3,4,5]);
            end
            assertExceptionThrown(@throw2, 'HERBERT:unique_references_container:incomplete_setup');
            urc3 = unique_references_container('Joby3','double');
            urc3 = urc3.add([6 7 8]);
            urc4 = unique_references_container('Biby','IX_inst');
        end
    end
end