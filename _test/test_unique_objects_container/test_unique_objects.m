classdef test_unique_objects < TestCase

    methods
        function this=test_unique_objects(varargin)
            if nargin>0
                name = varargin{1};
            else
                name  = 'test_unique_objects';
            end
            this = this@TestCase(name);                  
        end
        %
        %------------------------------------------------------------------
        function test_add_non_unique_objects(~)
            disp('Test: test_add_non_unique_objects');
            
            % create two different instruments from a couple of instrument
            % creator functions
            li = let_instrument(5, 240, 80, 20, 1);
            mi = merlin_instrument(180, 600, 'g');            
            % make sure the original 2 different instruments are the right
            % type
            assertTrue( isa(li,'IX_inst_DGdisk') );
            assertTrue( isa(mi,'IX_inst_DGfermi') );
            
            % make a unique_objects_container (empty)
            uoc = unique_objects_container('type','{}');
            
            % add 3 identical instruments to the container
            uoc = uoc.add(li);
            uoc = uoc.add(li);
            uoc = uoc.add(li);
            % add 2 more instruments, identical to each other but not the
            % first 3
            uoc = uoc.add(mi);
            uoc = uoc.add(mi);
            % add another instrument same as the first 3
            uoc = uoc.add(li);
            
            % test that we put 6 instruments in the container
            assertEqual( numel(uoc.idx), 6);
            
            % test that there are only 2 uniquely different instruments in
            % the container
            assertEqual( numel(uoc.stored_objects), 2);
            
            % test that there are 2 correspondingly different hashes in the
            % container for these instruments
            assertEqual( size(uoc.stored_hashes,1), 2);
            
            % test that each hash has has 16 uint8's in it
            assertEqual( size(uoc.stored_hashes,2), 16);
            
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
                assertEqual( mi, uoc.get(i) );
            end
            
            % test that the last instrument in the container is also the
            % same as instrument li
            assertEqual( li, uoc.get(6) );
        end
        
        %----------------------------------------------------------------
        function test_add_similar_non_unique_objects(~)
            disp('Test: test_add_similar_non_unique_objects');

            mi1 = merlin_instrument(180, 600, 'g');            
            mi2 = merlin_instrument(190, 700, 'g');  
            assertFalse( isequal(mi1,mi2) );
            uoc = unique_objects_container('type','{}');
            [uoc,nuix] = uoc.add(mi1);
            assertEqual( nuix, 1);
            [uoc,nuix] = uoc.add(mi2);
            assertEqual( nuix, 2);
            [uoc,nuix] = uoc.add(mi1);
            assertEqual( nuix, 3);
            [uoc,nuix] = uoc.add(mi2);
            assertEqual( nuix, 4);
            [uoc,nuix] = uoc.add(mi2);
            assertEqual( nuix, 5);
            assertEqual( numel(uoc.stored_objects), 2);
            assertEqual( numel(uoc.idx), 5);
            assertEqual( mi1, uoc.get(3) );
            assertEqual( mi2, uoc.get(5) );
        end
        %----------------------------------------------------------------
        function test_add_different_types(~)
            disp('Test: test_add_different_types');
            disp('NB This test WILL emit a warning');
            mi1 = merlin_instrument(180, 600, 'g'); 
            sm1 = IX_null_sample();
            uoc = unique_objects_container('type','{}');
            uoc = uoc.add(mi1);
            uoc = uoc.add(sm1);
            assertEqual( numel(uoc.stored_objects), 2);
            assertEqual( numel(uoc.idx), 2);
            assertEqual( mi1, uoc.get(1) );
            assertEqual( sm1, uoc.get(2) );
            voc = unique_objects_container('type','{}','baseclass','IX_inst');
            [voc,nuix] = voc.add(mi1);
            assertTrue( nuix>0 );
            [voc,nuix] = voc.add(sm1);
            assertFalse( nuix>0 );
            assertEqual( numel(voc.stored_objects), 1);
            assertEqual( numel(voc.idx), 1);
        end
        %----------------------------------------------------------------
        function test_change_serializer(~)
            disp('Test: test_change_serializer');
            mi1 = merlin_instrument(180, 600, 'g'); 
            mi2 = merlin_instrument(190, 700, 'g');  
            uoc = unique_objects_container('type','{}');
            uoc = uoc.add(mi1);
            uoc = uoc.add(mi2);
            voc = unique_objects_container('type','{}','convert_to_stream',@hlp_serialise);
            voc = voc.add(mi1);
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
        function test_constructor_arguments(~)
            disp('Test: test_constructor_arguments');
            disp('NB This test WILL emit warningS');
            mi1 = merlin_instrument(180, 600, 'g'); 
            sm1 = IX_null_sample();
            uoc = unique_objects_container('type','{}');
            uoc = uoc.add(mi1);
            uoc = uoc.add(sm1);
            assertEqual( numel(uoc.stored_objects), 2);
            uoc = unique_objects_container('type','{}','baseclass','IX_inst');
            uoc = uoc.add(mi1);
            uoc = uoc.add(sm1);
            assertEqual( numel(uoc.stored_objects), 1);
            %{
            Turns out that hashes are not portable between all Matlab
            versions and platforms, so suppressing this bit.

            u1 = uint8(...
                [122    85    30   186    79    64   138   166   121   219   196   239    36   104   116    22]...
                );
            assertEqual( u1, uoc.stored_hashes(1,:) );
            %}
            uoc = unique_objects_container('type','{}','baseclass','IX_inst','convert_to_stream',@hlp_serialise);
            uoc = uoc.add(mi1);
            uoc = uoc.add(sm1);
            assertEqual( numel(uoc.stored_objects), 1);
            %{
            Turns out that hashes are not portable between all Matlab
            versions and platforms, so suppressing this bit.
            u1 = uint8(...
                [124   197    72   173   189    40   141    89   154   200    43   138   160    63   243   121] ...
                );
            assertEqual( u1, uoc.stored_hashes(1,:) );
            %}
            uoc = unique_objects_container('type','{}','convert_to_stream',@hlp_serialise,'baseclass','IX_inst');
            uoc = uoc.add(mi1);
            uoc = uoc.add(sm1);
            assertEqual( numel(uoc.stored_objects), 1);
            %{
            Turns out that hashes are not portable between all Matlab
            versions and platforms, so suppressing this bit.
            
            u1 = uint8(...
                [124   197    72   173   189    40   141    89   154   200    43   138   160    63   243   121] ...
                );
            assertEqual( u1, uoc.stored_hashes(1,:) );
            %}
        end
        
        function test_subscripting(~)
            % repeats test_constructor_arguments using subscripting
            disp('Test: test_constructor_arguments');
            disp('NB This test WILL emit warningS');
            mi1 = merlin_instrument(180, 600, 'g'); 
            sm1 = IX_null_sample();
            uoc = unique_objects_container('type','{}');
            uoc{1} = mi1;
            uoc{2} = sm1;
            assertEqual( numel(uoc.stored_objects), 2);
            uoc = unique_objects_container('type','{}','baseclass','IX_inst');
            uoc{1} = mi1;
            uoc{2} = sm1;
            assertEqual( numel(uoc.stored_objects), 1);
            %{
            Turns out that hashes are not portable between all Matlab
            versions and platforms, so suppressing this bit.
            
            u1 = uint8(...
                [122    85    30   186    79    64   138   166   121   219   196   239    36   104   116    22]...
                );
            assertEqual( u1, uoc.stored_hashes(1,:) );
            %}
            uoc = unique_objects_container('type','{}','baseclass','IX_inst','convert_to_stream',@hlp_serialise);
            uoc{1} = mi1;
            uoc{2} = sm1;
            assertEqual( numel(uoc.stored_objects), 1);
            %{
            Turns out that hashes are not portable between all Matlab
            versions and platforms, so suppressing this bit.            
            u1 = uint8(...
                [124   197    72   173   189    40   141    89   154   200    43   138   160    63   243   121] ...
                );            
            assertEqual( u1, uoc.stored_hashes(1,:) );
            %}
            uoc = unique_objects_container('type','{}','convert_to_stream',@hlp_serialise,'baseclass','IX_inst');
            uoc{1} = mi1;
            uoc{2} = sm1;
            assertEqual( numel(uoc.stored_objects), 1);
            %{
            Turns out that hashes are not portable between all Matlab
            versions and platforms, so suppressing this bit.            
            u1 = uint8(...
                [124   197    72   173   189    40   141    89   154   200    43   138   160    63   243   121] ...
                );
            assertEqual( u1, uoc.stored_hashes(1,:) );
            %}
            % additional tests for other subscript functions
            % NB horrible syntax but way to put assignments in anonymous
            % functions is worse! Replacements for assertExceptionThrown
            uoc = unique_objects_container('type','{}','convert_to_stream',@hlp_serialise,'baseclass','IX_inst');
            try
                uoc{2} = mi1;
                error('HERBERT:unique_objects_container:error_not_raised',...
                      'out of range subscript should error');
            catch ME
                if ~(strcmp(ME.identifier,'HERBERT:unique_objects_container:invalid_argument') && ...
                     strcmp(ME.message, 'index outside legal range'))
                    rethrow(ME);
                end
            end
            try
                uoc{-1} = mi1; % should error before next line
                error('HERBERT:unique_objects_container:error_not_raised',...
                      'negative subscript should error');
            catch ME
                if ~(strcmp(ME.identifier,'HERBERT:unique_objects_container:invalid_argument') && ...
                     strcmp(ME.message, 'non-positive index not allowed'))
                    rethrow(ME);
                end
            end
            uoc = unique_objects_container('type','{}','convert_to_stream',@hlp_serialise,'baseclass','IX_inst');
            uoc{1} = mi1;
            uoc{2} = IX_null_inst();
            assertEqual( uoc.n_duplicates(1),1);            
            uoc{3} = mi1;
            assertEqual( numel(uoc.stored_objects),2);
            assertEqual( uoc.n_duplicates(1),2);            
            uoc{1} = IX_null_inst();
            assertEqual( numel(uoc.stored_objects),2);            
            assertEqual( uoc.n_duplicates(1),1);
            uoc{3} = IX_null_inst();
            assertEqual( numel(uoc.stored_objects),1);            
            assertEqual( uoc.n_duplicates(1),3);         
        end
    end
end