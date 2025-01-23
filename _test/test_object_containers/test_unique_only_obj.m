classdef test_unique_only_obj < TestCase
    properties
        mi1;q
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
        function test_find_in_container_object(obj)
            uoc = unique_only_obj_container_tester('IX_inst');
            uoc = uoc.add(obj.mi1);
            uoc = uoc.add(IX_null_inst());
            uoc = uoc.add(merlin_instrument(185, 600, 'g'));
            uoc = uoc.add(IX_null_inst());

            assertEqual(uoc.n_objects,3)

            [ind,hash,mi1] = uoc.find_in_container(obj.mi1);
            assertTrue(~isempty(ind));
            assertEqual(ind,1);
            assertTrue(mi1.hash_defined);
            assertEqual(mi1.hash_value,hash);
        end
        % %----------------------------------------------------------------
        function test_add_similar_non_unique_objects(obj)
            %disp('Test: test_add_similar_non_unique_objects');

            mi2 = merlin_instrument(190, 700, 'g');
            assertFalse( isequal(obj.mi1,mi2) );

            uoc = unique_only_obj_container_tester('IX_inst');
            [uoc,nuix] = uoc.add(obj.mi1);
            assertEqual( nuix, 1);
            [uoc,nuix] = uoc.add(mi2);
            assertEqual( nuix, 2);
            [uoc,nuix] = uoc.add(obj.mi1);
            assertEqual( nuix, 1);
            [uoc,nuix] = uoc.add(mi2);
            assertEqual( nuix, 2);
            [uoc,nuix] = uoc.add(mi2);
            assertEqual( nuix, 2);
            assertEqual( numel(uoc.unique_objects), 2);
            assertEqual( numel(uoc.idx), 2);
            assertEqual( obj.mi1, uoc.get(1) );
            assertEqual( mi2, uoc.get(2) );
        end
        %----------------------------------------------------------------
        function test_add_and_return_position(obj)
            %
            voc = unique_only_obj_container_tester('baseclass','IX_inst');
            [voc,nuix] = voc.add(obj.mi1);

            assertTrue( nuix>0 );
            function thrower()
                [voc,nuix] = voc.add(obj.nul_sm1);
            end
            assertExceptionThrown(@thrower,'HERBERT:ObjContainerBase:invalid_argument');

            assertEqual( numel(voc.unique_objects), 1);
            assertEqual( numel(voc.idx), 1);
        end
        %----------------------------------------------------------------

        function test_subscripting_no_type(obj)
            clWarn = set_temporary_warning('off','HERBERT:ObjContainerBase:incomplete_setup');
            % repeats test_constructor_arguments using subscripting
            uoc = unique_only_obj_container_tester();
            uoc{1} = obj.mi1; % first asignment have defined the container type
            function thrower()
                uoc{2} = obj.nul_sm1;   % this one should throw
            end
            me = assertExceptionThrown(@thrower,'HERBERT:ObjContainerBase:invalid_argument');
            assertEqual(me.message, ...
                'Assigning object of class: "IX_null_sample" to container with baseclass: "IX_inst_DGfermi" is prohibited');
            assertEqual( numel(uoc.unique_objects), 1);

        end
        %
        function test_expand_to_nruns(obj)
            uoc = unique_only_obj_container_tester('baseclass','IX_inst');
            uoc{1} = obj.mi1;
            assertEqual(uoc.n_objects,1)
            assertEqual(uoc.n_unique,1)

            uoc = uoc.replicate_runs(10,1);
            assertEqual(uoc.n_objects,1);
            assertEqual(uoc.n_unique,1);
            assertEqual(uoc.n_duplicates,10);

        end
        function test_instr_replacement_with_duplicates_round(obj)
            % this container is not intended for this operations but still
            % can  be used this way

            uoc = unique_only_obj_container_tester('baseclass','IX_inst');
            uoc(1) = obj.mi1;
            uoc(2) = IX_null_inst();
            assertEqual( uoc.n_duplicates,[1,1]);
            assertEqual( uoc.n_objects,2);
            assertEqual( uoc.n_unique,2);
            uoc(3) = obj.mi1;
            assertEqual( uoc.n_objects,2);
            assertEqual(uoc.n_duplicates,[2,1]);
            assertEqual(uoc.n_unique,2);
            uoc(1) = IX_null_inst();
            assertEqual( uoc.n_objects,2);
            assertEqual( uoc.n_duplicates,[1,2]);
            uoc(3) = IX_null_inst();

            assertEqual(uoc.n_objects,2);
            assertEqual(uoc.n_unique,2);
            assertEqual(uoc.n_duplicates,[1,3]);
        end
        %
        function test_instr_replacement_with_duplicates_curly(obj)
            % this container is not intended for this operations but still
            % can  be used this way

            uoc = unique_only_obj_container_tester('baseclass','IX_inst');
            uoc{1} = obj.mi1;
            uoc{2} = IX_null_inst();
            assertEqual( uoc.n_duplicates,[1,1]);
            assertEqual( uoc.n_objects,2);
            assertEqual( uoc.n_unique,2);
            uoc{3} = obj.mi1;
            assertEqual( uoc.n_objects,2);
            assertEqual(uoc.n_duplicates,[2,1]);
            assertEqual(uoc.n_unique,2);
            uoc{1} = IX_null_inst();
            assertEqual( uoc.n_objects,2);
            assertEqual( uoc.n_duplicates,[1,2]);
            uoc{3} = IX_null_inst();

            assertEqual(uoc.n_objects,2);
            assertEqual(uoc.n_unique,2);
            assertEqual(uoc.n_duplicates,[1,3]);
        end
        %-----------------------------------------------------------------
        function test_use_properties(~)
            urc = unique_only_obj_container('thingy_tester');
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
                'Some or all input indices: [2..2] are outside allowed range [1:1] for this container');
        end
        % %-----------------------------------------------------------------
        %
        %------------------------------------------------------------------
        function test_replace_at_last_pos_add_at_the_end(~)
            % replace unique object located at specified global index
            oc = unique_only_obj_container_tester('char');
            oc = oc.add({'1','2','3','4','5'});
            oc = oc.add('3');
            assertEqual(oc.n_duplicates,[1,1,2,1,1]);

            [oc,gidx] = oc.replace('1',5);
            assertEqual(gidx,1); % this 1 will go to idx(5)=1 of reference container
            assertEqual(oc.n_objects,4)
            assertEqual(oc.idx,[1,2,3,4])
            assertEqual(oc.unique_objects,{'1','2','3','4'});
            assertEqual(oc.get_at_direct_idx(1:4),'1234');
            assertEqual(oc.n_duplicates,[2,1,2,1]);

            [oc,gidx] = oc.add('100');
            assertEqual(gidx,5);
            assertEqual(oc.n_objects,5)
            assertEqual(oc.idx,[1,2,3,4,5])
            assertEqual(oc.unique_objects,{'1','2','3','4','100'});
            assertEqual(oc.get_at_direct_idx(1:5),'1234100');
            assertEqual(oc.n_duplicates,[2,1,2,1,1]);
        end

        function test_add_new_after_replace_takes_free(~)
            % replace unique object located at specified global index
            oc = unique_only_obj_container_tester('char');
            oc = oc.add({'1','2','3','4','5'});
            oc = oc.add('5');
            assertEqual(oc.n_duplicates,[1,1,1,1,2]);

            [oc,gidx] = oc.replace('2',3);
            assertEqual(gidx,2); % this 2 will go to idx(3)=2 of reference container
            assertEqual(oc.n_objects,4)
            assertEqual(oc.idx,[1,2,0,4,5])
            assertEqual(oc.unique_objects,{'1','2','5','4'});
            assertEqual(oc.n_duplicates,[1,2,0,1,2]);

            [oc,gidx] = oc.add('100');
            assertEqual(gidx,3);
            assertEqual(oc.n_objects,5)
            assertEqual(oc.idx,[1,2,3,4,5])
            assertEqual(oc.unique_objects,{'1','2','5','4','100'});
            assertEqual(oc.get_at_direct_idx(1:5),'1210045');
            assertEqual(oc.n_duplicates,[1,2,1,1,2]);


            assertEqual(oc.get(1:5),'1254100');
        end

        function test_replace_existing_no_duplicates(~)
            % replace unique object located at specified global index
            oc = unique_only_obj_container_tester('double');
            [oc,gidx] = oc.add(1:5);
            assertEqual(gidx,1:5);
            [oc,gidx] = oc.add(5); % two duplicates of 5
            assertEqual(gidx,5);
            assertEqual(oc.n_duplicates,[1,1,1,1,2]);
            uob_sample = [1,2,3,4,5];
            assertEqual(oc.get(1:5),uob_sample);


            [oc,gidx] = oc.replace(2,3);

            assertEqual(gidx,2);
            assertEqual(oc.n_objects,4)
            assertEqual(oc.idx,[1,2,0,4,5])

            assertEqual(oc.unique_objects,{1,2,5,4});
            assertEqual(oc.n_duplicates,[1,2,0,1,2]);
            % local indices make array continuous and last object is placed
            % on the empty space
            uob_sample = [1,2,5,4];
            assertEqual(oc.get(1:4),uob_sample);
        end

        function test_replace_existing_with_duplicates(~)
            % replace unique object located at specified global index
            oc = unique_only_obj_container_tester('double');
            oc = oc.add(1:5);
            oc = oc.add(4:5);
            assertEqual(oc.n_duplicates,[1,1,1,2,2]);

            [oc,gidx] = oc.replace(4,5);

            assertEqual(gidx,4);
            assertEqual(oc.n_objects,5)
            assertEqual(oc.idx,[1,2,3,4,5])

            assertEqual(oc.unique_objects,{1,2,3,4,5});
            assertEqual(oc.n_duplicates,[1,1,1,3,1]);

            uob_sample = 1:5;
            for i=1:5
                assertEqual(uob_sample(i),oc.get(i));
            end
        end

        function test_replace_with_duplicates_works_in_place(~)
            % replace unique object located at specified global index
            oc = unique_only_obj_container_tester('double');
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
            oc = unique_only_obj_container_tester('double');
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
            oc = unique_only_obj_container_tester('double');
            oc = oc.add(1:5);
            function thrower()
                oc = oc.replace(10,7);
            end
            assertExceptionThrown(@thrower,'HERBERT:ObjContainersBase:invalid_argument');
        end
        function test_replace_out_of_range_fail(~)
            % replace object located at specified global index
            oc = unique_only_obj_container_tester('double');
            oc = oc.add(1:5);
            function thrower()
                oc = oc.replace(10,6);
            end
            assertExceptionThrown(@thrower,'HERBERT:ObjContainersBase:invalid_argument');
        end
        function test_replace_at_expansion_range_fail(~)
            % replace object located at specified global index
            oc = unique_only_obj_container_tester('double');
            [oc,gidx] = oc.add(1:5);
            function thrower()
                oc = oc.replace(10,6,'+');
            end
            assertEqual(gidx,1:5);
            assertExceptionThrown(@thrower,'HERBERT:unique_only_obj_container:invalid_argument');
        end
        %------------------------------------------------------------------
        function test_add_with_duplicates(~)
            oc = unique_only_obj_container_tester('double');
            [oc,gidx] = oc.add([1,2]);
            assertEqual(gidx,oc.idx);
            [oc,gidx] = oc.add([3,2,2]);
            assertEqual(gidx,[3,2,2]);
            assertEqual(oc.n_objects,3)
            assertEqual(oc.n_unique,3)
            assertEqual(oc.idx,[1,2,3])

            assertEqual(oc.unique_objects,{1,2,3});
            assertEqual(oc.n_duplicates,[1,3,1]);
        end
        function test_add_and_set_type(~)
            oc = unique_only_obj_container_tester();
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
            oc = unique_only_obj_container_tester('double');
            assertEqual(oc.baseclass,'double');
            [oc,gidx] = oc.add([1,2]);
            assertEqual(gidx,[1,2])
            assertEqual(oc.n_objects,2)
            assertEqual(oc.n_unique,2)
            assertEqual(oc.idx,[1,2])
            assertEqual(oc.unique_objects,{1,2});
            assertEqual(oc.n_duplicates,[1,1]);
        end
        %------------------------------------------------------------------
        function test_constructor_with_name_only(~)
            oc = unique_only_obj_container_tester('double');
            assertEqual(oc.baseclass,'double');
            assertEqual(oc.n_objects,0);
            assertEqual(oc.n_unique,0);
            assertTrue(isempty(oc.idx));
            assertTrue(isempty(oc.unique_objects));
            assertTrue(isempty(oc.n_duplicates));
        end
        function test_empty_empty_constructor(~)
            oc = unique_only_obj_container_tester();
            assertEqual(oc.baseclass,'');
            assertEqual(oc.n_objects,0);
            assertEqual(oc.n_unique,0);
            assertTrue(isempty(oc.idx));
            assertTrue(isempty(oc.unique_objects));
            assertTrue(isempty(oc.n_duplicates));
        end
        %------------------------------------------------------------------
        function test_memory_expansion(~)
            oc = unique_only_obj_container_tester('double');
            oc.mem_expansion_chunk = 5;
            assertEqual(oc.total_allocated,0);
            members = 1:12;
            oc = oc.add(members);
            assertEqual(oc.total_allocated,15);
            assertEqual(oc.n_duplicates,ones(1,12));            
        end
    end
end
