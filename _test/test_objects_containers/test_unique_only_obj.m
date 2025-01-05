classdef test_unique_only_obj < TestCase
    properties
        mi1;
        li;
        nul_sm1;
    end

    methods
        function obj=test_unique_only_obj(varargin)
            if nargin>0
                name = varargin{1};
            else
                name  = 'test_unique_only_obj';
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
        % function test_find_in_container_object(obj)
        %     uoc = unique_objects_container('IX_inst');
        %     uoc = uoc.add(obj.mi1);
        %     uoc = uoc.add(IX_null_inst());
        %     uoc = uoc.add(merlin_instrument(185, 600, 'g'));
        %     uoc = uoc.add(IX_null_inst());
        %
        %     assertEqual(uoc.n_objects,4)
        %
        %     [ind,hash,mi1] = uoc.find_in_container(obj.mi1);
        %     assertTrue(~isempty(ind));
        %     assertEqual(ind,1);
        %     assertTrue(mi1.hash_defined);
        %     assertEqual(mi1.hash_value,hash);
        % end
        %
        % function test_add_non_unique_objects(obj)
        %
        %     % make a unique_objects_container (empty)
        %     uoc = unique_objects_container();
        %
        %     % add 3 identical instruments to the container
        %     uoc = uoc.add(obj.li);
        %     uoc = uoc.add(obj.li);
        %     uoc = uoc.add(obj.li);
        %     % add 2 more instruments, identical to each other but not the
        %     % first 3
        %     uoc = uoc.add(obj.mi1);
        %     uoc = uoc.add(obj.mi1);
        %     % add another instrument same as the first 3
        %     uoc = uoc.add(obj.li);
        %
        %     % test that we put 6 instruments in the container
        %     assertEqual( numel(uoc.idx), 6);
        %
        %     % test that there are only 2 uniquely different instruments in
        %     % the container
        %     assertEqual( numel(uoc.unique_objects), 2);
        %
        %     % test that there are 2 correspondingly different hashes in the
        %     % container for these instruments
        %     assertEqual( numel(uoc.stored_hashes), 2);
        %
        %
        %     % test that the first 3 instruments in the container are the
        %     % same as instrument li
        %     % also tests that the get method for retrieving the non-unique
        %     % objects is working
        %     for i=1:3
        %         assertEqual(obj.li, uoc.get(i) );
        %     end
        %
        %     % test that the next 2 instruments in the container are the
        %     % same as instrument mi
        %     for i=4:5
        %         assertEqual(obj.mi1, uoc.get(i) );
        %     end
        %
        %     % test that the last instrument in the container is also the
        %     % same as instrument li
        %     assertEqual(obj.li, uoc.get(6) );
        % end
        % function test_replace_unique_different_number_throw(~)
        %     clWar = set_temporary_warning('off','HERBERT:ObjContainerBase:incomplete_setup');
        %     uoc = unique_objects_container();
        %     uoc(1) = 'aaaaa';
        %     uoc(2) = 'bbbb';
        %     uoc(3) = 'bbbb';
        %     function thrower()
        %         uoc.unique_objects = 'bbbb';
        %     end
        %     assertExceptionThrown(@thrower, ...
        %         'HERBERT:unique_objects_container:invalid_argument');
        %
        % end
        % function test_replace_with_nonunique_same_number_throw(~)
        %     clWarn = set_temporary_warning('off','HERBERT:ObjContainerBase:incomplete_setup');
        %     uoc = unique_objects_container();
        %     uoc(1) = 'aaaaa';
        %     uoc(2) = 'bbbb';
        %     uoc(3) = 'bbbb';
        %     function thrower()
        %         uoc.unique_objects = {'AA','AA'};
        %     end
        %     assertExceptionThrown(@thrower, ...
        %         'HERBERT:unique_objects_container:invalid_argument');
        %
        % end
        %
        % function test_save_load(~)
        %     clWarn = set_temporary_warning('off','HERBERT:ObjContainerBase:incomplete_setup');
        %     uoc = unique_objects_container();
        %     uoc(1) = 'aaaaa';
        %     uoc(2) = 'bbbb';
        %     uoc(3) = 'bbbb';
        %     assertTrue(uoc.do_check_combo_arg);
        %     cl0b_file = onCleanup(@()delete('unique_objects_container_test_save_load_1.mat'));
        %     save('unique_objects_container_test_save_load_1.mat','uoc');
        %     zzz = load('unique_objects_container_test_save_load_1.mat');
        %     assertEqual(zzz.uoc{3},'bbbb');
        % end
        %
        % function test_replace_unique_same_number_works(~)
        %     clWarn = set_temporary_warning('off','HERBERT:ObjContainerBase:incomplete_setup');
        %     uoc = unique_objects_container();
        %     uoc(1) = 'aaaaa';
        %     uoc(2) = 'bbbb';
        %     uoc(3) = 'bbbb';
        %     % just replaced unique objects. It is a feature of serializable
        %     % interface. You may want to do it after getting all unique
        %     % objects from the container and modifying them.
        %     uoc.unique_objects = {'dd','cc'};
        %
        %     assertEqual(uoc(1),'dd')
        %     assertEqual(uoc(2),'cc')
        %     assertEqual(uoc(3),'cc')
        % end
        % %----------------------------------------------------------------
        % function test_add_similar_non_unique_objects(obj)
        %     %disp('Test: test_add_similar_non_unique_objects');
        %
        %     mi2 = merlin_instrument(190, 700, 'g');
        %     assertFalse( isequal(obj.mi1,mi2) );
        %
        %     uoc = unique_objects_container();
        %     [uoc,nuix] = uoc.add(obj.mi1);
        %     assertEqual( nuix, 1);
        %     [uoc,nuix] = uoc.add(mi2);
        %     assertEqual( nuix, 2);
        %     [uoc,nuix] = uoc.add(obj.mi1);
        %     assertEqual( nuix, 3);
        %     [uoc,nuix] = uoc.add(mi2);
        %     assertEqual( nuix, 4);
        %     [uoc,nuix] = uoc.add(mi2);
        %     assertEqual( nuix, 5);
        %     assertEqual( numel(uoc.unique_objects), 2);
        %     assertEqual( numel(uoc.idx), 5);
        %     assertEqual( obj.mi1, uoc.get(3) );
        %     assertEqual( mi2, uoc.get(5) );
        % end
        % %----------------------------------------------------------------
        % function test_add_different_types(obj)
        %
        %     uoc = unique_objects_container();
        %     uoc = uoc.add(obj.mi1);
        %     uoc = uoc.add(obj.nul_sm1);
        %     assertEqual( numel(uoc.unique_objects), 2);
        %     assertEqual( numel(uoc.idx), 2);
        %     assertEqual( obj.mi1, uoc.get(1) );
        %     assertEqual( obj.nul_sm1, uoc.get(2) );
        %     voc = unique_objects_container('baseclass','IX_inst');
        %     [voc,nuix] = voc.add(obj.mi1);
        %
        %     assertTrue( nuix>0 );
        %     function thrower()
        %         [voc,nuix] = voc.add(obj.nul_sm1);
        %     end
        %     assertExceptionThrown(@thrower,'HERBERT:unique_objects_container:invalid_argument');
        %
        %     assertEqual( numel(voc.unique_objects), 1);
        %     assertEqual( numel(voc.idx), 1);
        % end
        % %----------------------------------------------------------------
        % function test_constructor_arguments_no_type(obj)
        %
        %     uoc = unique_objects_container();
        %     uoc = uoc.add(obj.mi1);
        %     uoc = uoc.add(obj.nul_sm1);
        %     assertEqual( numel(uoc.unique_objects), 2);
        % end
        % function test_constructor_arguments_with_type(obj)
        %
        %     uoc = unique_objects_container('baseclass','IX_inst');
        %     uoc = uoc.add(obj.mi1);
        %     function thrower()
        %         uoc = uoc.add(obj.nul_sm1);
        %     end
        %     assertExceptionThrown(@thrower,'HERBERT:unique_objects_container:invalid_argument');
        %     assertEqual( numel(uoc.unique_objects), 1);
        % end
        %
        % function test_subscripting_no_type(obj)
        %     clWarn = set_temporary_warning('off','HERBERT:ObjContainerBase:incomplete_setup');
        %     % repeats test_constructor_arguments using subscripting
        %     uoc = unique_objects_container();
        %     uoc{1} = obj.mi1; % first asignment have defined the container type
        %     function thrower()
        %         uoc{2} = obj.nul_sm1;   % this one should throw
        %     end
        %     me = assertExceptionThrown(@thrower,'HERBERT:ObjContainerBase:invalid_argument');
        %     assertEqual(me.message, ...
        %         'Assigning object of class: "IX_null_sample" to container with baseclass: "IX_inst_DGfermi" is prohibited');
        %     assertEqual( numel(uoc.unique_objects), 1);
        %
        % end
        %
        % function test_expand_to_nruns(obj)
        %     uoc = unique_objects_container('baseclass','IX_inst');
        %     uoc{1} = obj.mi1;
        %     assertEqual(uoc.n_objects,1)
        %     assertEqual(uoc.n_unique,1)
        %
        %     uoc = uoc.replicate_runs(10);
        %     assertEqual(uoc.n_objects,10);
        %     assertEqual(uoc.n_unique,1);
        %     assertEqual(uoc.n_duplicates,10);
        %
        % end
        % function test_instr_replacement_with_duplicates_round(obj)
        %     uoc = unique_objects_container('baseclass','IX_inst');
        %     uoc(1) = obj.mi1;
        %     uoc(2) = IX_null_inst();
        %     assertEqual( uoc.n_duplicates,[1,1]);
        %     assertEqual( uoc.n_objects,2);
        %     assertEqual( uoc.n_unique,2);
        %     uoc(3) = obj.mi1;
        %     assertEqual( uoc.n_objects,3);
        %     assertEqual(uoc.n_duplicates,[2,1]);
        %     assertEqual(uoc.n_unique,2);
        %     uoc(1) = IX_null_inst();
        %     assertEqual( uoc.n_objects,3);
        %     assertEqual( uoc.n_duplicates,[1,2]);
        %     uoc(3) = IX_null_inst();
        %
        %     assertEqual(uoc.n_objects,3);
        %     assertEqual(uoc.n_unique,1);
        %     assertEqual(uoc.n_duplicates,3);
        % end
        %
        % function test_instr_replacement_with_duplicates_curly(obj)
        %     uoc = unique_objects_container('baseclass','IX_inst');
        %     uoc{1} = obj.mi1;
        %     uoc{2} = IX_null_inst();
        %     assertEqual( uoc.n_duplicates,[1,1]);
        %     assertEqual( uoc.n_objects,2);
        %     assertEqual( uoc.n_unique,2);
        %     uoc{3} = obj.mi1;
        %     assertEqual( uoc.n_objects,3);
        %     assertEqual(uoc.n_duplicates,[2,1]);
        %     assertEqual(uoc.n_unique,2);
        %     uoc{1} = IX_null_inst();
        %     assertEqual( uoc.n_objects,3);
        %     assertEqual( uoc.n_duplicates,[1,2]);
        %     uoc{3} = IX_null_inst();
        %
        %     assertEqual(uoc.n_objects,3);
        %     assertEqual(uoc.n_unique,1);
        %     assertEqual(uoc.n_duplicates,3);
        % end
        % function test_serialization_with_objects(obj)
        %     uoc = unique_objects_container('baseclass','IX_inst');
        %     uoc{1} = obj.mi1;
        %     uoc{2} = IX_null_inst();
        %     uoc_str = uoc.to_struct();
        %
        %     uoc_rec = serializable.from_struct(uoc_str);
        %     assertEqual(uoc,uoc_rec)
        % end
        %
        % function test_serialization_empty(~)
        %     uoc = unique_objects_container('baseclass','IX_inst');
        %     uoc_str = uoc.to_struct();
        %
        %     uoc_rec = serializable.from_struct(uoc_str);
        %     assertEqual(uoc,uoc_rec)
        % end
        % %-----------------------------------------------------------------
        % function test_use_properties(~)
        %     urc = unique_objects_container('thingy_tester');
        %     urc{1} = thingy_tester(111);
        %     assertEqual(urc{1}, thingy_tester(111));
        %     assertEqual(urc{1}.data, 111);
        %     urc{1}.data = 222;
        %     function throw1()
        %         assertEqual(urc{1}, thingy_tester(222));
        %         assertEqual(urc{1}.data, 222);
        %         urc{2}.data = 666;
        %     end
        %     me = assertExceptionThrown(@throw1, 'HERBERT:ObjContainersBase:invalid_argument');
        %     assertEqual(me.message, ...
        %         'Some or all input indices: [2..2] are outside allowed range [1:1] for this container');
        % end
        % %-----------------------------------------------------------------
        %
        % function test_hashing_preserved_over_save_and_load(obj)
        %     uoc = unique_objects_container('IX_inst');
        %     uoc{1} = obj.mi1;
        %     uoc{2} = IX_null_inst();
        %     for i=1:2
        %         tobj = uoc{i};
        %         [~,~,is_calculated] = build_hash(tobj);
        %         assertFalse(is_calculated); % hash restored
        %     end
        %
        %     test_data = 'store2020_1.mat';
        %     clOb = onCleanup(@()delete(test_data));
        %     save(test_data,'uoc');
        %     zzz = load('store2020_1.mat');
        %     assertEqual(uoc.stored_hashes, zzz.uoc.stored_hashes);
        %     for i=1:2
        %         tobj =zzz.uoc{i};
        %         [~,~,is_calculated] = build_hash(tobj);
        %         assertFalse(is_calculated); % hash restored
        %     end
        % end
        % %
        % function test_hashing_preserved_over_to_from_struct(obj)
        %     uoc = unique_objects_container('IX_inst');
        %     uoc{1} = obj.mi1;
        %     uoc{2} = IX_null_inst();
        %     for i=1:2
        %         tobj = uoc{i};
        %         [~,~,is_calculated] = build_hash(tobj);
        %         assertFalse(is_calculated); % hash restored
        %     end
        %
        %     Suoc   = uoc.to_struct();
        %     uocr = serializable.from_struct(Suoc);
        %     for i=1:2
        %         tobj = uoc{i};
        %         [~,~,is_calculated] = build_hash(tobj);
        %         assertFalse(is_calculated); % hash restored
        %     end
        %     assertEqual(uoc.stored_hashes, uocr.stored_hashes);
        % end
        %------------------------------------------------------------------
        function test_add_new_after_replace_takes_free(~)
            % replace unique object located at specified global index
            oc = unique_only_obj_container_tester('double');
            oc = oc.add(1:5);
            oc = oc.add(5);
            assertEqual(oc.n_duplicates,[1,1,1,1,2]);

            [oc,gidx] = oc.replace(2,3);
            assertEqual(gidx,3);
            assertEqual(oc.n_objects,4)
            assertEqual(oc.idx,[1,2,0,4,3])
            assertEqual(oc.unique_objects,{1,2,5,4});
            assertEqual(oc.n_duplicates,[1,1,2,1]);            

            [oc,gidx] = oc.add(100);
            assertEqual(gidx,3);
            assertEqual(oc.n_objects,5)
            assertEqual(oc.idx,[1,2,5,4,3])
            assertEqual(oc.unique_objects,{1,2,5,4,100});
            assertEqual(oc.n_duplicates,[1,1,2,1,1]);            

        end
        
        function test_replace_existing_no_duplicates(~)
            % replace unique object located at specified global index
            oc = unique_only_obj_container_tester('double');
            oc = oc.add(1:5);
            oc = oc.add(5);
            assertEqual(oc.n_duplicates,[1,1,1,1,2]);

            [oc,gidx] = oc.replace(2,3);

            assertEqual(gidx,3);
            assertEqual(oc.n_objects,4)
            assertEqual(oc.idx,[1,2,0,4,3])

            assertEqual(oc.unique_objects,{1,2,5,4});
            assertEqual(oc.n_duplicates,[1,1,2,1]);
        end

        function test_replace_existing_with_duplicates(~)
            % replace unique object located at specified global index
            oc = unique_only_obj_container('double');
            oc = oc.add(1:5);
            oc = oc.add(4:5);
            assertEqual(oc.n_duplicates,[1,1,1,2,2]);

            [oc,gidx] = oc.replace(4,5);

            assertEqual(gidx,4);
            assertEqual(oc.n_objects,5)
            assertEqual(oc.idx,[1,2,3,4,5])

            assertEqual(oc.unique_objects,{1,2,3,4,5});
            assertEqual(oc.n_duplicates,[1,1,1,3,1]);
        end

        function test_replace_with_duplicates_works(~)
            % replace unique object located at specified global index
            oc = unique_only_obj_container('double');
            oc = oc.add(1:5);
            oc = oc.add(4);
            assertEqual(oc.n_duplicates,[1,1,1,2,1]);

            [oc,gidx] = oc.replace(10,4);

            assertEqual(gidx,6);
            assertEqual(oc.n_objects,6)
            assertEqual(oc.idx,[1,2,3,4,5,6])

            assertEqual(oc.unique_objects,{1,2,3,4,5,10});
            assertEqual(oc.n_duplicates,[1,1,1,1,1,1]);
        end

        function test_replace_single_gidx(~)
            % replace unique object located at specified global index
            oc = unique_only_obj_container('double');
            oc = oc.add(1:5);

            [oc,gidx] = oc.replace(10,4);

            assertEqual(oc.n_objects,5)
            assertEqual(oc.idx,[1,2,3,4,5])
            assertEqual(gidx,4);

            assertEqual(oc.unique_objects,{1,2,3,10,5});
            assertEqual(oc.n_duplicates,[1,1,1,1,1]);
        end
        %------------------------------------------------------------------
        function test_replace_far_out_of_range_fail(~)
            % replace object located at specified global index
            oc = unique_only_obj_container('double');
            oc = oc.add(1:5);
            function thrower()
                oc = oc.replace(10,7);
            end
            assertExceptionThrown(@thrower,'HERBERT:ObjContainersBase:invalid_argument');
        end
        function test_replace_out_of_range_fail(~)
            % replace object located at specified global index
            oc = unique_only_obj_container('double');
            oc = oc.add(1:5);
            function thrower()
                oc = oc.replace(10,6);
            end
            assertExceptionThrown(@thrower,'HERBERT:ObjContainersBase:invalid_argument');
        end
        function test_replace_at_expansion_range_fail(~)
            % replace object located at specified global index
            oc = unique_only_obj_container('double');
            oc = oc.add(1:5);
            function thrower()
                oc = oc.replace(10,6,'+');
            end
            assertExceptionThrown(@thrower,'HERBERT:unique_only_obj_container:invalid_argument');
        end
        %------------------------------------------------------------------
        function test_add_with_duplicates(~)
            oc = unique_only_obj_container('double');
            oc = oc.add([1,2]);
            oc = oc.add([3,2,2]);
            assertEqual(oc.n_objects,3)
            assertEqual(oc.n_unique,3)
            assertEqual(oc.idx,[1,2,3])

            assertEqual(oc.unique_objects,{1,2,3});
            assertEqual(oc.n_duplicates,[1,3,1]);
        end
        function test_add_and_set_type(~)
            oc = unique_only_obj_container();
            clWa = set_temporary_warning('off','HERBERT:ObjContainerBase:incomplete_setup','HERBERT:test_warning');
            warning('HERBERT:test_warning','reset warning to deined state');
            assertEqual(oc.baseclass,'');
            oc = oc.add([1,2]);
            assertEqual(oc.baseclass,'double');
            [~,lw] = lastwarn();
            assertEqual(lw,'HERBERT:ObjContainerBase:incomplete_setup')
            assertEqual(oc.n_objects,2)
            assertEqual(oc.n_unique,2)
            assertEqual(oc.idx,[1,2])
            assertEqual(oc.unique_objects,{1,2});
            assertEqual(oc.n_duplicates,[1,1]);
        end
        function test_simple_add(~)
            oc = unique_only_obj_container('double');
            assertEqual(oc.baseclass,'double');
            oc = oc.add([1,2]);
            assertEqual(oc.n_objects,2)
            assertEqual(oc.n_unique,2)
            assertEqual(oc.idx,[1,2])
            assertEqual(oc.unique_objects,{1,2});
            assertEqual(oc.n_duplicates,[1,1]);
        end
        %------------------------------------------------------------------
        function test_constructor_with_name_only(~)
            oc = unique_only_obj_container('double');
            assertEqual(oc.baseclass,'double');
            assertEqual(oc.n_objects,0);
            assertEqual(oc.n_unique,0);
            assertTrue(isempty(oc.idx));
            assertTrue(isempty(oc.unique_objects));
            assertTrue(isempty(oc.n_duplicates));
        end
        function test_empty_empty_constructor(~)
            oc = unique_only_obj_container();
            assertEqual(oc.baseclass,'');
            assertEqual(oc.n_objects,0);
            assertEqual(oc.n_unique,0);
            assertTrue(isempty(oc.idx));
            assertTrue(isempty(oc.unique_objects));
            assertTrue(isempty(oc.n_duplicates));
        end
    end
end
