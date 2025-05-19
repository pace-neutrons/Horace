classdef test_unique_references < TestCase
    properties
        mi1;
        li;
        nul_sm1;

        % Place for useful contents of the current unique_obj_store.
        clStore
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
            % Store current contents of the unique_store for future usage
            % and clear store to have defined initial state for the tests.
            %
        end
        function setUp(obj)
            % These tests rely on defined initial store state
            obj.clStore = set_temporary_global_obj_state();            
        end
        function tearDown(obj)
            %unique_obj_store.instance('clear');
            obj.clStore = [];            
        end
        %------------------------------------------------------------------
        function test_save_restore_global_state_with_replacement(~)
            % Tests that instances in the GLC are still stored in mem and only cleared on
            % unique_references_container's save/load. This expands on the
            % basic test below by overwriting elements after initialisation

            clSt  = test_unique_references.set_multifit_issue_state_clearer();

            urc = unique_references_container('char');
            % initialize urc with 3 duplicate 'aaa' values
            urc(1) = 'aaa';
            urc(2) = 'aaa';
            urc(3) = 'aaa';
            % overwrite these elements with 'bbb' values
            urc(1) = 'bbb';
            urc(2) = 'bbb';
            urc(3) = 'bbb';

            % extract implementing unique-objects for testing
            glc = unique_obj_store.instance().get_objects('char');
            % although urc no longer has 'aaa' values, they are retained in
            % glc as there is no garbage collection. We expect the
            % following tests to fail when garbage collection is
            % implemented.
            assertTrue(isa(glc,'unique_only_obj_container'))
            assertEqual(glc.n_unique,glc.n_objects)
            %Re #1816 this tests operation with ref_counting and replacing deleted.
            %assertEqual(glc.n_objects,1)
            %assertEqual(glc.unique_objects,{'bbb'})
            %Re #1816 tests refcounting without deleteon.
            assertEqual(glc.n_objects,2)
            assertEqual(glc.unique_objects,{'aaa','bbb'})

            % we store urc in a struct, clear glc of all content and then
            % reload urc from the structure as urr
            savestr = urc.to_struct();
            % need to keep structures for comparison as urc is invalidated
            % in the next row
            unique_obj_store.instance().clear('char');
            urr = serializable.from_struct(savestr);

            % glr the reconstructed unique-objects is refreshed and no
            % longer contains the values which might be garbag-collected
            glr = unique_obj_store.instance().get_objects('char');
            % there are no longer any 'aaa' values in the global container
            assertTrue(isa(glr,'unique_only_obj_container'))
            assertEqual(glr.n_objects,1)
            assertEqual(glr.n_unique,1)
            assertEqual(glr.unique_objects,{'bbb'})

            % check that the to_struct values for old and new urc and urr
            % are the same ie retained values are equal and values for
            % garbage collection are not referred to by either urc and urr
            savestr_cp = urr.to_struct();
            assertEqual(savestr,savestr_cp);
            clear clSt; % clear state first to keep warning off on deletion
        end

        function test_save_restore_global_state_two_urcs(~)
            % Test that 2 unique containers have the required contributions
            % to the common global container and that is preserved when the
            % global container is cleared and reconstituted
            clSt  = test_unique_references.set_multifit_issue_state_clearer();

            % initialise two unique containers with some unique and some
            % shared objects
            urc1 = unique_references_container('char');
            urc1(1) = 'aaa';
            urc1(2) = 'aaa';
            urc1(3) = 'aaa';
            urc1(4) = 'bbb';
            urc2 = unique_references_container('char');
            urc2(1) = 'ccc';
            urc2(2) = 'ccc';
            urc2(3) = 'ccc';
            urc2(4) = 'bbb';

            % extract the common global container and check correctness of
            % its contents
            glc = unique_obj_store.instance().get_objects('char');
            assertTrue(isa(glc,'unique_only_obj_container'))
            assertEqual(glc.n_objects,3)
            assertEqual(glc.n_unique,3)
            assertEqual(glc.unique_objects,{'aaa','bbb','ccc'})

            % convert both containers to structs, clear the global
            % container, and reconstruct the 2 contaners (and hence the
            % global container) from the structs
            savestr1_or = urc1.to_struct();
            savestr2_or = urc2.to_struct();
            % need to keep structures for comparion as urc1 and urc2 is
            % invalidated in the next row
            unique_obj_store.instance().clear('char');

            urr1 = serializable.from_struct(savestr1_or);
            urr2 = serializable.from_struct(savestr2_or);

            % extract again the global container and check it still has the
            % right contents
            glr = unique_obj_store.instance().get_objects('char');
            assertTrue(isa(glr,'unique_only_obj_container'))
            assertEqual(glr.n_objects,3)
            assertEqual(glr.n_unique,3)
            assertEqual(glr.unique_objects,{'aaa','bbb','ccc'})

            % assert that the struct versions of the containers are the
            % same before and after the global clear
            savestr_copy1 = urr1.to_struct();
            savestr_copy2 = urr2.to_struct();
            assertEqual(savestr1_or,savestr_copy1);
            assertEqual(savestr2_or,savestr_copy2);
            clear clSt; % clear state first to keep warning off on deletion
        end

        function test_save_restore_global_state(~)
            % test unique container has the correct behaviour for its
            % global storage - basic test. the test above also tests
            % correctness of all this when overwriting elements.
            clSt  = test_unique_references.set_multifit_issue_state_clearer();

            % initialise container with some unique and some duplicate
            % items
            urc = unique_references_container('char');
            urc(1) = 'aaa';
            urc(2) = 'aaa';
            urc(3) = 'aaa';
            urc(4) = 'bbb';

            % extract the global container and check that its contents are
            % correct
            glc = unique_obj_store.instance().get_objects('char');
            assertTrue(isa(glc,'unique_only_obj_container'))
            assertEqual(glc.n_objects,2)
            assertEqual(glc.n_unique,2)
            assertEqual(glc.unique_objects,{'aaa','bbb'})

            % store the container as a struct, clear the global container
            % and restore a copy of the original container
            savestr = urc.to_struct();
            % need to keep structures for comparion as urc is
            % invalidated in the next row
            unique_obj_store.instance().clear('char');
            urr = serializable.from_struct(savestr);

            % extract the global container again and make sure it still has
            % the required contents
            glr = unique_obj_store.instance().get_objects('char');
            assertTrue(isa(glr,'unique_only_obj_container'))
            assertEqual(glr.n_objects,2)
            assertEqual(glr.n_unique,2)
            assertEqual(glr.unique_objects,{'aaa','bbb'})

            % check the old and new containers are identical by comparison
            % of struct conversios
            savestr_cp = urr.to_struct();
            assertEqual(savestr,savestr_cp);
            clear clSt; % clear state first to keep warning off on deletion
        end
    end
    methods(Static)
        function clSt  = set_multifit_issue_state_clearer(~)
            function urc_clearer(old_val)
                unique_obj_store.instance().set_objects(old_val);
            end
            old_store = unique_obj_store.instance().get_objects('char');
            unique_obj_store.instance().clear('char');
            clSt  = onCleanup(@()urc_clearer(old_store));
        end
    end
    methods
        function test_unique_reference_non_pollute_ws(obj)
            function clearer()
                unique_obj_store.instance().clear('IX_inst');
                unique_obj_store.instance().clear('IX_samp');
                unique_obj_store.instance().clear('IX_detector_array');
            end
            clOb = onCleanup(@()clearer);


            sqw1 = sqw.generate_cube_sqw(4);
            sqw1.experiment_info.instruments=obj.mi1;
            assertTrue(isa(sqw1.experiment_info.instruments(1),'IX_inst_DGfermi'))
            assertTrue(sqw1.experiment_info.instruments(1).hash_defined)

            sqw2 = sqw.generate_cube_sqw(5);
            sqw2.experiment_info.instruments =obj.li;
            assertTrue(isa(sqw2.experiment_info.instruments(1),'IX_inst_DGdisk'))
            assertTrue(sqw1.experiment_info.instruments(1).hash_defined)

            glc = unique_obj_store.instance().get_objects('IX_inst');

            assertEqual(glc.n_objects,3);
            contents = glc.unique_objects();
            classnames = cellfun(@class,contents,'UniformOutput',false);
            assertTrue(ismember('IX_inst_DGfermi',classnames));
            assertTrue(ismember('IX_inst_DGdisk',classnames));

            tf = fullfile(tmp_dir,'test_unique_ref_pollution.mat');
            clOb_file = onCleanup(@()delete(tf));

            save(tf,'sqw2');
            unique_obj_store.instance().clear('IX_inst');

            glc = unique_obj_store.instance().get_objects('IX_inst');
            assertEqual(glc.n_objects,0);

            lobj = load(tf);
            assertTrue(isa(lobj.sqw2.experiment_info.instruments(1),'IX_inst_DGdisk'))
            glc = unique_obj_store.instance().get_objects('IX_inst');

            assertTrue(lobj.sqw2.experiment_info.instruments(1).hash_defined)
            assertEqual(glc.n_objects,1);
            contents = glc.unique_objects();
            classnames = cellfun(@class,contents,'UniformOutput',false);

            is_disk = ismember(classnames,'IX_inst_DGdisk');
            assertTrue(any(is_disk));

            assertFalse(ismember('IX_inst_DGfermi',classnames));
        end

        function test_save_load_two_objects_adds_to_experiments(obj)
            %TODO there is a lot of testing of Experiment here and this may
            %be better positioned in test_experiment
            function clearer()
                unique_obj_store.instance().clear('IX_samp');
                unique_obj_store.instance().clear('IX_detector_array');
                unique_obj_store.instance().clear('IX_inst');
            end
            clOb = onCleanup(@()clearer);

            %
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
            gc = unique_obj_store.instance().get_objects('IX_samp');
            %Re #1816 this tests operation with ref_counting and replacing deleted.
            %assertEqual(gc.n_objects,4); % sam2, sam3 and sam4 have been replacemed in ex2
            assertEqual(gc.n_objects,7)

            % test conversion to struct and clearing of all sample objects
            % associated with ex2, and then its restoration and checking
            % that the global container is restored
            ser_str = ex2.to_struct();
            clear('exp2','exp1');
            unique_obj_store.instance().clear('IX_samp');

            ex2_rec = IX_samp.from_struct(ser_str);

            gc = unique_obj_store.instance().get_objects('IX_samp');
            assertEqual(gc.n_objects,3);
            assertEqual(gc.n_unique,3);
            assertEqual(gc.unique_objects{1},ex2_rec.samples(1));
            assertEqual(gc.unique_objects{3},ex2_rec.samples(3));
            assertTrue(gc.unique_objects{1}.hash_defined)
            assertTrue(gc.unique_objects{3}.hash_defined)
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
            function clearer()
                unique_obj_store.instance().clear('IX_samp');
                unique_obj_store.instance().clear('IX_inst');
                unique_obj_store.instance().clear('IX_detector_array');
            end
            clOb = onCleanup(@()clearer);

            % adding a sample to an empty Experiment() will fail as the
            % number of runs is defined by the number of IX_experiments it
            % contains, so Experiment() has no runs and ex.sample{1} = sam
            % will not work.
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
            clfl = onCleanup(@()delete(sample_file));

            ld = load(sample_file);
            assertEqual(ld.ex,ex);
        end
        %
        %------------------------------------------------------------------
        function test_basic_doubles_container(~)
            function clearer()
                unique_obj_store.instance().clear('double');
            end
            clOb = onCleanup(@()clearer);
            urc = unique_references_container('double');

            glc = unique_obj_store.instance().get_objects('double');
            assertEqual( glc.n_objects, 0);

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
            [ind,hash,obj] = urc.find_in_container(0.555);
            assertFalse(isempty(ind));
            assertEqual(ind, 1);
            assertEqual(obj,0.555);
            [ind,hash,obj] = urc.find_in_container(0.111);
            assertTrue( isempty(ind) );
            assertEqual(obj,0.111);
            [ind,hash,obj] = urc.find_in_container(0.222);
            assertFalse(isempty(ind));
            assertEqual(ind,2);
            assertEqual(obj,0.222);
            [ind,hash,obj] = urc.find_in_container(0.333);
            assertFalse(isempty(ind));
            assertEqual(ind,3);
            assertEqual(obj,0.333);

            % [is,ind]=urc.contains('double');
            % assertTrue(is);
            % assertEqual(ind,[1 2 3 4]);

            glc = unique_obj_store.instance().get_objects('double');
            % Re #1816 checks reference counting
            %assertEqual( glc.n_objects, 3);
            %assertEqual( glc.n_unique, 3);
            %assertEqual( glc.n_duplicates,[1,2,1]);
            %assertEqual( glc.unique_objects, {0.555,0.222,0.333});
            % Re #1617 this checks container without removing unused
            assertEqual( glc.n_objects, 4);
            assertEqual( glc.n_unique, 4);
            assertEqual( glc.n_duplicates,[1,2,1,1]);
            assertEqual( glc.unique_objects, {0.1110,0.2220,0.3330,0.5550});

        end

        function test_save_load(~)
            function clearer()
                unique_obj_store.instance().clear('double');
            end
            clOb = onCleanup(@()clearer);
            urc = unique_references_container('double');

            urc = urc.add(0.111);
            urc = urc.add(0.222);
            urc = urc.add(0.333);
            urc = urc.add(0.222);
            clOb_file = onCleanup(@()delete('test_unique_references_container_save_load_1.mat'));
            save('test_unique_references_container_save_load_1.mat','urc');
            zzz = load('test_unique_references_container_save_load_1.mat');
            assertEqual(zzz.urc, urc);
        end

        function test_add_multiple(~)
            function clearer()
                unique_obj_store.instance().clear('double');
            end
            clOb = onCleanup(@()clearer);
            urc = unique_references_container('double');

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
            function clearer()
                unique_obj_store.instance().clear('IX_inst');
            end
            clOb = onCleanup(@()clearer);
            urc = unique_references_container('IX_inst');

            urc = urc.add(obj.mi1);
            urc = urc.add(IX_null_inst());
            % testing a different merlin instrument from obj.mi1 above
            urc = urc.add(merlin_instrument(185, 600, 'g'));
            % testing the same merlin instrument as obj.mi1 above, using
            % explicit construction
            urc = urc.add(merlin_instrument(180, 600, 'g'));

            assertEqual(urc.n_runs,4)
            assertEqual(urc.n_objects,4)
            assertEqual(urc.n_unique,3);

            [ind,~,mi1] = urc.find_in_container(obj.mi1);
            assertTrue(~isempty(ind));
            assertEqual(ind,1);

            [ind,hash,nui] = urc.find_in_container(IX_null_inst());
            assertTrue(~isempty(ind));
            assertEqual(ind,2);

            inst = urc{1};
            assertEqual( inst.name,'MERLIN' );
            inst = urc{2};
            assertEqual( inst.name,'' );
            inst = urc{3};
            assertEqual( inst.name,'MERLIN' );

            inst = IX_null_inst();
            inst.name = 'NULL';
            assertFalse(inst.hash_defined);
            [ind,hash,inst] = urc.find_in_container(inst);
            assertTrue( isempty(ind) );
            assertTrue(inst.hash_defined)
            assertEqual(inst.hash_value,hash);

            urc{2} = inst;
            inst = urc{2};
            assertEqual( inst.name,'NULL' );

            [ind,hash,inst] = urc.find_in_container(inst);
            assertFalse(isempty(ind) );
            assertEqual(ind,2);
            [ind,hash,inst] = urc.find_in_container(IX_null_inst());
            assertTrue(isempty(ind) );

            urc = urc.add(IX_null_inst());
            assertEqual(urc.n_runs,5)
            assertEqual(urc.n_objects,5)
            assertEqual(urc.n_unique,4);

            [ind,hash,inst] = urc.find_in_container(IX_null_inst());
            assertFalse(isempty(ind) );
            assertEqual(ind,5);

            %-----
            glc = unique_obj_store.instance().get_objects('IX_inst');
            assertTrue( isa( glc, 'unique_only_obj_container') );
            %Re #1816 this test for operation with ref_counting and replacing deleted.
            assertEqual( glc.n_objects, 4);
            assertEqual( glc.n_unique, 4);
            %assertEqual( glc.n_duplicates,[2,1,1,1]);
            %Re #1816 this tests code without replacement
            assertEqual( glc.n_duplicates,[2,2,1,1]);

        end
        function xest_searh_with_conditions(~)
            %TODO: do we want to allow search over other conditions but
            % particular class instance? This would be different search
            % from search over hashes. Not difficult to implement but I do
            % not understand purpose.
            %
            % this piece of code is the extract of such search, previously
            % implemented in the test above.
            % test contains for a class name instead of an object value
            % It could be easy to add a condition to container search.
            [is,ind] = urc.contains('IX_null_inst');
            assertTrue(is);
            assertEqual(ind, [2 4 5]);

            [is,ind]=urc.contains('IX_inst');
            assertTrue(is);
            assertEqual(ind,[1 2 3 4 5]);

            [is,ind]=urc.contains('IX_null_inst');
            assertTrue(is);
            assertEqual(ind,[2 5]);
        end

        function test_add_non_unique(obj)
            function clearer()
                unique_obj_store.instance().clear('IX_inst');
            end
            clOb = onCleanup(@()clearer);
            urc = unique_references_container('IX_inst');


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
            assertEqual( urc.n_unique, 2 );


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

        function test_replace_unique_different_type_throw(~)
            function clearer()
                unique_obj_store.instance().clear('char');
            end
            clOb = onCleanup(@()clearer);
            urc = unique_references_container('char');

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
        end
        function test_replace_unique_proper_type_works(~)
            function clearer()
                unique_obj_store.instance().clear('char');
            end
            clOb = onCleanup(@()clearer);
            urc = unique_references_container('char');

            uoc = unique_objects_container('baseclass','char');
            uoc{1} = 'xxxx';
            uoc{2} = 'yyyy';
            uoc{3} = 'zzzz';
            urc.unique_objects = uoc;

            assertEqual(urc.n_objects,3)
            assertEqual(urc.n_unique,3)
        end
        function test_replace_unique_wrong_type_container_throws(~)
            function clearer()
                unique_obj_store.instance().clear('char');
            end
            clOb = onCleanup(@()clearer);
            urc = unique_references_container('char');
            urc(1) = 'ava';

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
        function test_replace_unique_objects_with_correct_cellarray_works(~)
            function clearer()
                unique_obj_store.instance().clear('char');
            end
            clOb = onCleanup(@()clearer);

            urc = unique_references_container('char');
            urc(1) = 'aaaaa';
            urc(2) = 'bbbb';
            urc(3) = 'bbbb';

            function thrower()
                urc.unique_objects = {'AA','BB'};
            end
            assertExceptionThrown(@thrower, ...
                'HERBERT:unique_only_obj_container:not_implemented');

            % assertEqual(urc(1),'AA')
            % assertEqual(urc(2),'BB')
            % assertEqual(urc(3),'BB')
        end


        function test_replace_unique_objects_with_wrong_cellarray_throw(~)
            function clearer()
                unique_obj_store.instance().clear('char');
            end
            clOb = onCleanup(@()clearer);

            urc = unique_references_container('char');
            urc(1) = 'aaaaa';
            urc(2) = 'bbbb';
            urc(3) = 'bbbb';
            function thrower()
                urc.unique_objects = {'AA','AA'};
            end
            assertExceptionThrown(@thrower, ...
                'HERBERT:unique_only_obj_container:not_implemented');
        end

        function test_replace_unique_same_number_works(~)
            % replace unique objects in the container
            function clearer()
                unique_obj_store.instance().clear('char');
            end
            clOb = onCleanup(@()clearer);

            urc = unique_references_container('char');
            urc(1) = 'aaaaa';
            urc(2) = 'bbbb';
            urc(3) = 'bbbb';
            assertEqual(urc.n_objects,3)
            assertEqual(urc.n_unique,2)

            uoc2 = unique_objects_container('char');
            uoc2(1) = 'dd';
            uoc2(2) = 'cc';
            urc.unique_objects = uoc2;

            assertEqual(urc(1),'dd')
            assertEqual(urc(2),'cc')
            assertEqual(urc.n_objects,2)
            assertEqual(urc.n_unique,2)
        end

        function test_baseclass_issues_incomplete_setup_works(obj)
            function clearer()
                unique_obj_store.instance().clear('IX_inst_DGfermi');
            end
            clOb = onCleanup(@()clearer);
            clWarn = set_temporary_warning('off','HERBERT:ObjContainerBase:incomplete_setup');

            % legal constructor with no arguments but cannot be used until
            % populated e.g. with loadobj
            urc1 = unique_references_container();
            % As containter is undefined, this witll work
            urc1(1) = obj.mi1;
            [~,lw] = lastwarn;
            assertEqual(lw,'HERBERT:ObjContainerBase:incomplete_setup')

            assertEqual(urc1.baseclass,'IX_inst_DGfermi')
            assertEqual(urc1.n_objects,1)
            assertEqual(urc1.n_unique,1)
        end

        function test_baseclass_issues_different_input(obj)
            % setup container of char
            function clearer()
                unique_obj_store.instance().clear('char');
            end
            clOb = onCleanup(@()clearer);
            urc2 = unique_references_container('char');
            urc2(1) = 'aaaaa'; % should work fine
            cl2b = set_temporary_warning('off','HERBERT:unique_references_container:invalid_argument');

            % fail extending with wrong type
            assertEqual(urc2.n_runs,1);
            assertEqual(urc2.n_objects,1);

            function thrower()
                urc2(2) = obj.mi1;
            end
            ex = assertExceptionThrown(@thrower,'HERBERT:ObjContainerBase:invalid_argument');
            assertEqual(ex.message, ...
                'Assigning object of class: "IX_inst_DGfermi" to container with baseclass: "char" is prohibited');
            assertEqual(urc2.n_runs,1); % warning was issued and object was not added
            assertEqual(urc2.n_objects,1); % warning was issued and object was not added
            lastwarn('');

            % fail inserting with wrong type
            function thrower2()
                urc2(1) = obj.mi1;
            end
            ex = assertExceptionThrown(@thrower2,'HERBERT:ObjContainerBase:invalid_argument');
            assertEqual(ex.message, ...
                'Assigning object of class: "IX_inst_DGfermi" to container with baseclass: "char" is prohibited');
            assertEqual( urc2(1),'aaaaa'); % warning was issued and object was not replaced
            assertEqual(urc2.n_runs,1); % warning was issued and object was not added
            assertEqual(urc2.n_objects,1); % warning was issued and object was not added
        end

        %----------------------------------------------------------------
        function test_add_similar_non_unique_objects_using_add(obj)
            function clearer()
                unique_obj_store.instance().clear('IX_inst_DGfermi');
            end
            clOb = onCleanup(@()clearer);
            urc = unique_references_container('IX_inst_DGfermi');

            mi2 = merlin_instrument(190, 700, 'g');
            assertFalse( isequal(obj.mi1,mi2) );
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
            assertEqual( urc.n_unique, 2);
            assertEqual( numel(urc.idx), 5 );
            assertEqual( obj.mi1, urc(3) );
            assertEqual( mi2, urc.get(5) );
        end
        function test_add_similar_non_unique_objects_using_subscript(obj)
            function clearer()
                unique_obj_store.instance().clear('IX_inst_DGfermi');
            end
            clOb = onCleanup(@()clearer);
            urc = unique_references_container('IX_inst_DGfermi');
            urc{1} = obj.mi1;
            assertEqual( urc.n_runs, 1);
            assertEqual( urc.n_objects, 1);
            mi2 = merlin_instrument(190, 700, 'g');

            urc{2} = mi2;
            assertEqual( urc.n_runs, 2);
            assertEqual( urc.n_objects, 2);
            urc{3} = obj.mi1;
            assertEqual( urc.n_runs, 3);
            assertEqual( urc.n_objects, 3);
            assertEqual( urc.n_unique, 2);
            urc(4) = mi2;
            assertEqual( urc.n_runs, 4);
            assertEqual( urc.n_objects, 4);
            assertEqual( urc.n_unique, 2);
            urc(5) = mi2;
            assertEqual( urc.n_runs, 5);
            assertEqual( urc.n_objects, 5);
            assertEqual((urc.unique_objects.n_unique), 2);
            assertEqual( urc.n_unique, 2);
            assertEqual( numel(urc.idx), 5);
            assertEqual( obj.mi1, urc.get(3) );
            assertEqual( mi2, urc(5) );
        end
        %
        function test_add_similar_non_unique_objects_using_subs_fail_out_range(obj)
            function clearer()
                unique_obj_store.instance().clear('IX_inst_DGfermi');
            end
            clOb = onCleanup(@()clearer);
            urc = unique_references_container('IX_inst_DGfermi');

            % check for fail outside range
            function throw171()
                urc{7} = obj.mi1;
            end
            assertExceptionThrown( @throw171, ...
                'HERBERT:ObjContainersBase:invalid_argument');
            function throw1m1()
                urc{0} = obj.mi1;
            end
            assertExceptionThrown( @throw1m1, ...
                'HERBERT:ObjContainersBase:invalid_argument');
        end
        %----------------------------------------------------------------
        function test_add_different_types_sample(obj)
            function clearer()
                unique_obj_store.instance().clear('IX_inst_DGfermi');
            end
            clOb = onCleanup(@()clearer);


            urc = unique_objects_container('IX_inst_DGfermi');
            % object of correct type added
            urc = urc.add(obj.mi1);
            % object of incorrect type not added, warning issued, size
            % still 1
            assertEqual( urc.n_runs, 1);
            assertEqual( urc.n_objects, 1);
            function thrower()
                urc = urc.add(obj.nul_sm1);
            end
            assertExceptionThrown(@thrower, ...
                'HERBERT:ObjContainerBase:invalid_argument');

            % object not added, size unchanges, warning issued
            assertEqual( urc.n_runs, 1);
            assertEqual( urc.n_objects, 1);
        end
        function test_add_different_types_instrument(obj)
            function clearer()
                unique_obj_store.instance().clear('IX_null_sample');
            end
            clOb = onCleanup(@()clearer);

            urc = unique_references_container('IX_null_sample');
            % object of correct type added
            [urc, nuix] = urc.add(obj.nul_sm1);
            % object of incorrect type not added, warning issued, size
            % still 1
            assertEqual(nuix, 1);
            assertEqual( urc.n_runs, 1 );
            assertEqual( urc.n_objects, 1 );
            function thrower()
                [urc, nuix] = urc.add(obj.mi1);
            end
            assertExceptionThrown(@thrower, ...
                'HERBERT:ObjContainerBase:invalid_argument');

            % object of incorrect type not added, warning issued, size
            % still 1, addition index 0 => not added
            assertEqual( urc.n_runs, 1 );
            assertEqual( urc.n_objects, 1 );
        end
        %----------------------------------------------------------------
        function test_global_container_spans_multiple_containers(~)
            function clearer()
                unique_obj_store.instance().clear('IX_inst_DGfermi');
            end
            clOb = onCleanup(@()clearer);
            unique_obj_store.instance().clear('IX_inst_DGfermi');

            urc = unique_references_container('IX_inst_DGfermi');
            vrc = unique_references_container('IX_inst_DGfermi');

            mi1 = merlin_instrument(190, 700, 'g');
            mi2 = merlin_instrument(200, 700, 'g');
            mi3 = merlin_instrument(190, 800, 'g');
            mi4 = merlin_instrument(200, 800, 'g');

            urc = urc.add(mi1);
            urc = urc.add(mi2);
            assertEqual(urc.n_objects,2);
            assertEqual(urc.n_unique,2);
            vrc = vrc.add(mi3);
            vrc = vrc.add(mi4);
            assertEqual(vrc.n_objects,2);
            assertEqual(vrc.n_unique,2);

            assertFalse(urc.unique_objects==vrc.unique_objects);

            glc = unique_obj_store.instance().get_objects('IX_inst_DGfermi');
            hlc = unique_obj_store.instance().get_objects('IX_inst_DGfermi');
            assertEqual( glc, hlc);
            assertEqual( glc.n_objects, hlc.n_objects );
            assertEqual( glc.n_objects, 4 );
        end
        %----------------------------------------------------------------
        function test_subscripting_type(obj)
            function clearer()
                unique_obj_store.instance().clear('IX_inst');
            end
            clOb = onCleanup(@()clearer);

            urc = unique_references_container('IX_inst');
            urc{1} = obj.mi1;
            function thrower()
                urc{2} = obj.nul_sm1;
            end
            ex = assertExceptionThrown(@thrower,'HERBERT:ObjContainerBase:invalid_argument');
            assertEqual(ex.message, ...
                'Assigning object of class: "IX_null_sample" to container with baseclass: "IX_inst" is prohibited');
            assertEqual( urc.n_unique, 1);
        end
        %----------------------------------------------------------------
        function test_subscripting_type_hlp_ser_wrong_subscript_minus(obj)
            % additional tests for other subscript functions
            function clearer()
                unique_obj_store.instance().clear('IX_inst');
            end
            clOb = onCleanup(@()clearer);

            urc = unique_references_container('IX_inst');
            function set_urc()
                urc{2} = obj.mi1;
            end
            ex = assertExceptionThrown(@set_urc,'HERBERT:ObjContainersBase:invalid_argument');
            assertEqual(ex.message, ...
                'Some or all input indices: [2..2] are outside allowed range [1:1] for container: unique_references_container')

        end
        %-----------------------------------------------------------------
        function test_expand_to_nruns(obj)
            function clearer()
                unique_obj_store.instance().clear('IX_inst');
            end
            clOb = onCleanup(@()clearer);

            urc = unique_references_container('IX_inst');
            urc{1} = obj.mi1;
            assertEqual(urc.n_runs,1)
            assertEqual(urc.n_objects,1)
            assertEqual(urc.n_unique,1)

            urc = urc.replicate_runs(10);
            assertEqual(urc.n_runs,10);
            assertEqual(urc.n_objects,10);
            assertEqual(urc.n_unique,1);
            %------
            stor = unique_obj_store.instance().get_objects('IX_inst');
            assertEqual(stor.n_objects,1)
            assertEqual(stor.n_unique,1)
            assertEqual(stor.unique_objects{1},obj.mi1)
            assertEqual(stor.n_duplicates,10);

        end
        %-----------------------------------------------------------------
        function test_serialzation_with_values(obj)
            function clearer()
                unique_obj_store.instance().clear('IX_inst');
            end
            clOb = onCleanup(@()clearer);

            urc = unique_references_container('IX_inst');

            urc{1} = obj.mi1;
            urc{2} = obj.mi1;
            urc_str = urc.to_struct();

            urc_rec = serializable.from_struct(urc_str);
            assertEqual(urc,urc_rec);
            %-----
            stor = unique_obj_store.instance().get_objects('IX_inst');
            assertEqual(stor.n_objects,1)
            assertEqual(stor.n_unique,1)
            assertEqual(stor.unique_objects{1},obj.mi1)
            assertEqual(stor.n_duplicates,4);
        end
        function test_serialization_empty(~)
            function clearer()
                unique_obj_store.instance().clear('IX_inst');
            end
            clOb = onCleanup(@()clearer);

            unique_obj_store.instance().clear('IX_inst');
            urc = unique_references_container('IX_inst');
            urc_str = urc.to_struct();

            urc_rec = serializable.from_struct(urc_str);
            assertEqual(urc,urc_rec)
        end
        %
        function test_put_to_get_from_unique_obj_container(~)
            function clearer()
                unique_obj_store.instance().clear('char');
            end
            clOb = onCleanup(@()clearer);

            urc = unique_references_container('char');
            urc(1) = 'amama';
            urc(2) = 'blabal';
            urc(3) = 'blabal';
            urc(4) = 'amama';
            assertEqual(urc.n_objects,4)
            assertEqual(urc.n_unique,2)

            %-----
            stor = unique_obj_store.instance().get_objects('char');
            assertEqual(stor.n_objects,2)
            assertEqual(stor.n_unique,2)
            assertEqual(stor.unique_objects{1},'amama')
            assertEqual(stor.unique_objects{2},'blabal')
            assertEqual(stor.n_duplicates,[2,2]);


            uoc = urc.unique_objects;
            assertEqual(uoc.n_objects,4);
            assertEqual(uoc.n_unique,2);

            ur2 = unique_references_container('char');
            ur2.unique_objects = uoc;

            assertEqual(urc,ur2)
            %-----
            stor = unique_obj_store.instance().get_objects('char');
            assertEqual(stor.n_objects,2)
            assertEqual(stor.n_unique,2)
            assertEqual(stor.unique_objects{1},'amama')
            assertEqual(stor.unique_objects{2},'blabal')
            assertEqual(stor.n_duplicates,[4,4]);

        end
        %-----------------------------------------------------------------
        function test_property_reset_can_not_change_type(~)
            function clearer()
                unique_obj_store.instance().clear('double');
            end
            clOb = onCleanup(@()clearer);


            urc = unique_references_container('double');
            urc = urc.add([3,4,5]);
            function throw()
                urc.baseclass = 'IX_inst';
            end
            assertExceptionThrown(@throw, 'HERBERT:ObjContainerBase:invalid_argument');
        end
        %-----------------------------------------------------------------
        function test_use_properties_two_references(~)
            % add two the same objects from two different unique references
            % containers and change object in one of them
            function clearer()
                unique_obj_store.instance().clear('thingy_tester');
            end
            clOb = onCleanup(@()clearer);

            urc1 = unique_references_container('thingy_tester');
            urc2 = unique_references_container('thingy_tester');
            urc1{1} = thingy_tester(111);
            urc2{1} = thingy_tester(111);
            assertEqual(urc1{1}, thingy_tester(111));
            assertEqual(urc2{1}, thingy_tester(111));
            assertEqual(urc1{1}.data, 111);
            assertEqual(urc2{1}.data, 111);
            %-----
            stor = unique_obj_store.instance().get_objects('thingy_tester');
            assertEqual(stor.n_objects,1)
            assertEqual(stor.n_unique,1)
            assertEqual(stor.unique_objects{1},thingy_tester(111))
            %-----
            urc1{1}.data = 222;
            assertEqual(urc1{1}, thingy_tester(222));
            assertEqual(urc2{1}, thingy_tester(111));

            %-----
            stor = unique_obj_store.instance().get_objects('thingy_tester');
            assertEqual(stor.n_objects,2)
            assertEqual(stor.n_unique,2)
            assertEqual(stor.unique_objects{1},thingy_tester(111))
            assertEqual(stor.unique_objects{2},thingy_tester(222))
            %Re #1816 this tests operation with ref_counting and replacing deleted.
            %assertEqual(stor.n_duplicates,[1,1]);
            %Re #1816 tests refcounting without deleteon.
            assertEqual(stor.n_duplicates,[2,1]);
        end

        function test_use_properties_one_reference(~)
            function clearer()
                unique_obj_store.instance().clear('thingy_tester');
            end
            clOb = onCleanup(@()clearer);

            urc = unique_references_container('thingy_tester');
            urc{1} = thingy_tester(111);
            assertEqual(urc{1}, thingy_tester(111));
            assertEqual(urc{1}.data, 111);
            urc{1}.data = 222;
            function throw1()
                assertEqual(urc{1}, thingy_tester(222));
                assertEqual(urc{1}.data, 222);
                urc{2}.data = 666;
            end
            me = assertExceptionThrown(@throw1, 'HERBERT:ObjContainersBase:invalid_argument');
            assertEqual(me.message, ...
                'Some or all input indices: [2..2] are outside allowed range [1:1] for container: unique_references_container');
            stor = unique_obj_store.instance().get_objects('thingy_tester');
            assertEqual(stor.n_unique,stor.n_unique)
            %Re #1816 this tests operation with ref_counting and replacing deleted.
            %assertEqual(stor.n_objects,1)
            %assertEqual(stor.unique_objects{1},thingy_tester(222))
            %Re #1816 tests refcounting without deleteon.
            assertEqual(stor.n_objects,2)
            assertEqual(stor.unique_objects{1},thingy_tester(111))            
            assertEqual(stor.unique_objects{2},thingy_tester(222))
        end
        %-----------------------------------------------------------------
        function test_two_urc_one_fully_replaced_through_index(~)
            function clearer()
                unique_obj_store.instance().clear('char');
            end
            clOb = onCleanup(@()clearer);

            orobj = {'1','2','3','4','5','6'};
            urc1 = unique_references_container('char');
            urc1 = urc1.add(orobj);

            urc2 = unique_references_container('char');
            urc2 = urc2.add(orobj(4:6));


            nobj = {'3','2','1'};
            for i=1:3
                urc1{i} = nobj{i};
            end
            uobj = urc1.unique_objects;
            assertEqual(uobj.unique_objects,{'3','2','1','4','5','6'});
            assertEqual(urc1(1:6),'321456');

            % objects in other container are not affected
            uobj = urc2.unique_objects;
            assertEqual(uobj.unique_objects,orobj(4:6));
            assertEqual(urc2(1:3),'456')


            %-----
            stor = unique_obj_store.instance().get_objects('char');
            assertEqual(stor.n_objects,6)
            assertEqual(stor.get_at_direct_idx(1:6),'123456');
            %Re #1816 this tests operation with ref_counting and replacing deleted.
            % assertEqual(stor.unique_objects,{'6','2','3','4','5','1'})
            % assertEqual(stor.get_at_direct_idx(1:6),'123456');
            % assertEqual(stor.n_duplicates,[1,  1,  1,  2,  2,  2]);
            %Re #1816 tests refcounting without deleteon.
            assertEqual(stor.unique_objects,{'1','2','3','4','5','6'})
            assertEqual(stor.n_duplicates,[2,  2,  2,  2,  2,  2]);

        end



        function test_two_urc_partially_replaced_through_index(~)
            function clearer()
                unique_obj_store.instance().clear('char');
            end
            clOb = onCleanup(@()clearer);

            orobj = {'1','2','3','4','5','6'};
            urc1 = unique_references_container('char');
            urc1 = urc1.add(orobj);

            urc2 = unique_references_container('char');
            urc2 = urc2.add(orobj(1:3));

            assertEqual(urc1.n_unique,6);
            assertEqual(urc1.n_objects,6);
            assertEqual(urc1.idx,[1,2,3,4,5,6]);
            assertEqual(urc2.n_unique,3);
            assertEqual(urc2.n_objects,3);
            assertEqual(urc2.idx,[1,2,3]);

            nobj = {'5','4','3'};
            for i=1:3
                urc1{i} = nobj{i};
            end
            uobj = urc1.unique_objects;
            assertEqual(uobj.unique_objects,{'5','4','3','6'});
            assertEqual(urc1(1:6),'543456');

            uobj = urc2.unique_objects;
            assertEqual(uobj.unique_objects,orobj(1:3));

            %-----
            stor = unique_obj_store.instance().get_objects('char');
            assertEqual(stor.n_objects,6)
            assertEqual(stor.unique_objects,orobj)
            %                            {'1','2','3','4','5','6'};

            %Re #1816 this tests operation with ref_counting and replacing deleted.
            %assertEqual(stor.n_duplicates,[1,  1,  2,  2,  2,  1]);
            %Re #1816 tests refcounting without deleteon.
            assertEqual(stor.n_duplicates,[2, 2,  3,  2,  2,  1]);
        end



        function test_two_urc_fully_expanded_through_index(~)
            function clearer()
                unique_obj_store.instance().clear('char');
            end
            clOb = onCleanup(@()clearer);

            orobj = {'1','2','3','4','5'};
            urc1 = unique_references_container('char');
            urc1 = urc1.add(orobj);

            urc2 = unique_references_container('char');
            urc2 = urc2.add(orobj);

            assertEqual(urc1.n_unique,5);
            assertEqual(urc1.n_objects,5);
            assertEqual(urc1.idx,[1,2,3,4,5]);
            assertEqual(urc2.n_unique,5);
            assertEqual(urc2.n_objects,5);
            assertEqual(urc2.idx,[1,2,3,4,5]);

            nobj = {'6','7','8','9','10'};
            for i=1:urc1.n_objects
                urc1{i} = nobj{i};
            end
            uobj = urc1.unique_objects;
            assertEqual(uobj.unique_objects,nobj);

            uobj = urc2.unique_objects;
            assertEqual(uobj.unique_objects,orobj);

            %-----
            stor = unique_obj_store.instance().get_objects('char');
            assertEqual(stor.n_objects,stor.n_unique);
            assertEqual(stor.n_unique,10)
            assertEqual(stor.unique_objects,[orobj(:);nobj(:)]')
            %Re #1816 this tests operation with ref_counting and replacing deleted.
            %assertEqual(stor.n_duplicates,ones(1,10));
            %Re #1816 tests refcounting without deleteon.
            assertEqual(stor.n_duplicates,[2,2,2,2,2,1,1,1,1,1]);
        end

        function test_one_urc_fully_replaced_through_index(~)
            function clearer()
                unique_obj_store.instance().clear('char');
            end
            clOb = onCleanup(@()clearer);

            urc1 = unique_references_container('char');
            urc1 = urc1.add({'1','2','3','4','5'});

            assertEqual(urc1.n_unique,5);
            assertEqual(urc1.n_objects,5);
            assertEqual(urc1.idx,[1,2,3,4,5]);

            nobj = {'6','7','8','9','10'};
            for i=1:urc1.n_objects
                urc1{i} = nobj{i};
            end
            uobj = urc1.unique_objects;
            assertEqual(uobj.unique_objects,nobj);

            %-----
            stor = unique_obj_store.instance().get_objects('char');
            assertEqual(stor.n_objects,stor.n_unique);
            %Re #1816 this tests operation with ref_counting and replacing deleted.
            %assertEqual(stor.n_objects,5)
            %assertEqual(stor.unique_objects(1:5),{'6','7','8','9','10'})
            %assertEqual(stor.n_duplicates,[1,1,1,1,1]);
            %Re #1816 tests refcounting without deleteon.
            assertEqual(stor.n_objects,10)
            assertEqual(stor.unique_objects,{'1','2','3','4','5','6','7','8','9','10'})
            assertEqual(stor.n_duplicates,ones(1,10));

        end
        %------------------------------------------------------------------
        function test_two_urc_work_fine(~)
            function clearer()
                unique_obj_store.instance().clear('double');
            end
            clOb = onCleanup(@()clearer);

            urc1 = unique_references_container('double');
            urc1 = urc1.add([2,3,6,7,3]);
            urc2 = unique_references_container('double');
            urc2 = urc2.add([8,9,3,2,2]);

            assertEqual(urc1.n_unique,4);
            assertEqual(urc1.n_objects,5);
            assertEqual(urc1.idx,[1,2,3,4,2]);

            assertEqual(urc2.n_unique,4);
            assertEqual(urc2.n_objects,5);
            assertEqual(urc2.idx,[5,6,2,1,1]);

            % each corresponding unique objects container
            % contains its own objects only
            uoc1 = urc1.unique_objects;
            assertEqual(uoc1.n_objects,5)
            assertEqual(uoc1.n_unique,4)
            assertEqual(uoc1.baseclass,'double')
            assertEqual(uoc1.idx,[1 2 3 4 2])
            assertEqual(uoc1.unique_objects,{2,3,6,7});
            assertEqual(uoc1.n_duplicates,[1 2 1 1])

            uoc2 = urc2.unique_objects;
            assertEqual(uoc2.n_objects,5)
            assertEqual(uoc2.n_unique,4)
            assertEqual(uoc2.baseclass,'double')
            assertEqual(uoc2.idx,[1 2 3 4 4])
            assertEqual(uoc2.unique_objects,{8,9,3,2});
            assertEqual(uoc2.n_duplicates,[1 1 1 2])

            %-----
            stor = unique_obj_store.instance().get_objects('double');
            assertEqual(stor.n_objects,6)
            assertEqual(stor.n_unique,6)
            assertEqual(stor.unique_objects(1:6),{2,3,6,7,8,9})
            assertEqual(stor.n_duplicates,[3,3,1,1,1,1]);

        end

        function test_one_urc_works(~)
            unique_obj_store.instance().clear('double');
            function clearer()
                unique_obj_store.instance().clear('double');
            end
            clOb = onCleanup(@()clearer);
            urc1 = unique_references_container('double');

            urc1 = urc1.add([1,2]);
            urc1 = urc1.add([1,2,3,5]);
            urc1 = urc1.add([1,2]);

            assertEqual(urc1.n_unique,4);
            assertEqual(urc1.n_objects,8);
            assertEqual(urc1.idx,[1,2,1,2,3,4,1,2]);

            assertEqual(urc1(1),1);
            assertEqual(urc1(2),2);
            assertEqual(urc1(3),1);
            assertEqual(urc1(4),2);
            assertEqual(urc1(5),3);
            assertEqual(urc1(6),5);
            assertEqual(urc1(7),1);
            assertEqual(urc1(8),2);
            assertEqual(urc1(1:3),[1,2,1]);

            uobj = urc1.expose_unique_objects();
            assertTrue(iscell(uobj));
            assertEqual(uobj,{1,2,3,5});

            uoc1 = urc1.unique_objects;
            assertEqual(uoc1.n_objects,8)

            assertEqual(uoc1.n_unique,4)
            assertEqual(uoc1.baseclass,'double')
            assertEqual(uoc1.idx,[1 2 1 2 3 4 1 2])
            assertEqual(uoc1.unique_objects,{1,2, 3, 5});
            assertEqual(uoc1.n_duplicates,[3 3 1 1])

        end

        function test_one_empty_urc(~)
            urc1 = unique_references_container('double');

            assertEqual(urc1.baseclass,'double');
            assertEqual(urc1.n_unique,0);
            assertEqual(urc1.n_objects,0);
            assertTrue(isempty(urc1.idx));
        end
    end
end
