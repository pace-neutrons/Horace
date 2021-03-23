classdef test_MESS_NAMES_factory< TestCase
    %
    properties
    end
    methods
        %
        function obj=test_MESS_NAMES_factory(name)
            if ~exist('name', 'var')
                name = 'test_MESS_NAMES_factory';
            end
            obj = obj@TestCase(name);
        end
        %
        function test_get_mess_class(~)
            mni = MESS_NAMES.instance();
            mess = mni.get_mess_class('failed');
            assertTrue(isa(mess,'FailedMessage'));
        end
        %
        function test_fixture_tags(~)
            ft = MESS_NAMES.instance().pool_fixture_tags;
            assertTrue(isnumeric(ft));
            assertTrue(numel(ft)>3);
        end
        %
        function test_persistent(~)
            is = MESS_NAMES.is_persistent('failed');
            assertTrue(is);
            
            is = MESS_NAMES.is_persistent(0);
            assertFalse(is);
            
            mess = CanceledMessage();
            is = MESS_NAMES.is_persistent(mess);
            assertTrue(is);
            
        end
        %
        function test_interrupts(~)
            il = MESS_NAMES.instance().interrupts;
            assertTrue(iscell(il))
            assertTrue(numel(il)>=1)
            assertTrue(ismember('failed',il));
            itag = MESS_NAMES.instance().interrupt_tags;
            assertTrue(numel(itag)>=1)
            assertTrue(isnumeric(itag))
        end
        %        
        function test_selection(~)
            name = MESS_NAMES.mess_name(8);
            assertTrue(ischar(name));
            
            mni = MESS_NAMES.instance();
            is = mni.is_subscribed(name);
            assertTrue(is);
            is = mni.is_registered(name);
            assertTrue(is);
            
            
            id = MESS_NAMES.mess_id(name);
            assertEqual(id,8);
            id = MESS_NAMES.mess_id({name});
            assertEqual(id,8);
            
            selection = [1,3,5];
            names = MESS_NAMES.mess_name(selection);
            
            id_s = MESS_NAMES.mess_id(names);
            assertEqual(selection,id_s);
            
            ids = MESS_NAMES.mess_id(names);
            assertEqual(ids,selection);
            
        end
        %
        function test_operations(~)
            mni = MESS_NAMES.instance();
            assertTrue(mni.is_initialized);
            
            names = mni.known_messages;
            
            for i=1:numel(names)
                name = names{i};
                assertTrue(mni.is_registered(name));
                assertTrue(mni.is_subscribed(name));
                mess = mni.get_mess_class(name);
                
                assertEqual(mess.mess_name,name);
                assertEqual(mess.is_blocking,MESS_NAMES.is_blocking(name));
                assertEqual(mess.is_persistent,MESS_NAMES.is_persistent(name));
                
                assertEqual(mess.tag,mni.mess_id(name));
                id = mess.tag;
                assertTrue(MESS_NAMES.tag_valid(id));
                assertEqual(MESS_NAMES.mess_name(id),mess.mess_name);
                
            end
        end
        %
        function test_any_tag(~)
            
            is = MESS_NAMES.tag_valid(-1);
            assertTrue(is);
            
            id = MESS_NAMES.mess_id('any');
            assertEqual(id,-1);
            
            name = MESS_NAMES.mess_name(-1);
            assertEqual(name,'any');
            
            is = MESS_NAMES.is_persistent(-1);
            assertFalse(is);
            is = MESS_NAMES.is_blocking(-1);
            assertFalse(is);
        end
        %
        function test_mess_name_and_interrupt_channel_hack(~)
            name = MESS_NAMES.mess_name(1:4);
            assertTrue(iscell(name));
            
            name = MESS_NAMES.mess_name([1,3,100],100);
            
            assertTrue(iscell(name));
            assertEqual(name{3},'interrupt');
        end
        %
        function test_mess_id_and_interrupt_channel_hack(~)
            ids = MESS_NAMES.mess_id({'completed','pending','queued'});
            assertTrue(isnumeric(ids));
            assertEqual(numel(ids),3);
            
            ids = MESS_NAMES.mess_id({'completed','pending','interrupt'},1000);
            
            assertTrue(isnumeric(ids));
            assertEqual(numel(ids),3);
            assertEqual(ids(3),1000);
            
            ids2 = MESS_NAMES.mess_id('interrupt',1000);
            assertTrue(isnumeric(ids2));
            assertEqual(numel(ids2),1);
            assertEqual(ids2,1000);
            
            ids1 = MESS_NAMES.mess_id('completed');
            assertTrue(isnumeric(ids1));
            assertEqual(numel(ids1),1);
            assertEqual(ids1,ids(1));
            
            ids1 = MESS_NAMES.mess_id('completed',100);
            assertTrue(isnumeric(ids1));
            assertEqual(numel(ids1),1);
            assertEqual(ids1,ids(1));            
        end
        %            
        function test_specialized_classes(obj)
            try
                mc = aMessage('nont_exist');
                thrown = false;
            catch ME
                thrown = true;
                assertEqual(ME.identifier,'MESS_NAMES:invalid_argument');
            end
            assertTrue(thrown,' Successfull attempt to create non-subscribed message');
            
            try
                mc = aMessage(1);
                thrown = false;
            catch ME
                thrown = true;
                assertEqual(ME.identifier,'MESS_NAMES:invalid_argument');
            end
            assertTrue(thrown,' Successfull attempt to create message with wrong arguments');
            
            
            % initialize empty init message using generic constructor
            try
                mc = aMessage('init');
                thrown = false;
            catch ME
                thrown = true;
                assertEqual(ME.identifier,'AMESSAGE:invalid_argument');
            end
            assertTrue(thrown,' Successfull attempt to intialize specialized message using generic constructor');
            
            
            mc = InitMessage('some init info');
            assertTrue(isa(mc,'InitMessage'));
            
            assertEqual(mc.common_data,'some init info');
            
            mc1 = InitMessage('other init info');
            assertTrue(isa(mc1,'InitMessage'));
            assertEqual(mc1.common_data,'other init info');
            
            assertFalse(strcmp(mc1.common_data,mc.common_data));
        end
    end
end


