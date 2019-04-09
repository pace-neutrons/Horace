classdef test_mess_cache < TestCase
    %
    % $Revision:: 830 ($Date:: 2019-04-09 10:03:50 +0100 (Tue, 9 Apr 2019) $)
    %
    
    properties
    end
    methods
        %
        function this=test_mess_cache(name)
            if ~exist('name','var')
                name = 'test_mess_cache';
            end
            this = this@TestCase(name);
        end
        function test_get_cache_messages(obj)
            mess_cache.instance('delete');
            mc = mess_cache.instance(11);
            assertEqual(mc.get_n_occupied(),0);
            
            mc.push_messages(3 ,aMessage('running'));
            mc.push_messages(5 ,aMessage('running'));
            mc.push_messages(7 ,aMessage('completed'));
            mc.push_messages(9 ,aMessage('failed'));
            mc.push_messages(10 ,aMessage('running'));
            
            assertEqual(mc.get_n_occupied(),5);
            
            tid_requested = [1,2,4,6,8,11];
            [mess,mess_present] = ...
                mess_cache.instance().get_cache_messages(tid_requested,'',false);
            assertEqual(numel(mess),numel(tid_requested));
            assertEqual(numel(mess),numel(mess_present));
            assertTrue(~any(mess_present));
            
            
            mess_name = 'running';
            tid_requested = 5:9;
            
            [mess,mess_present] = ...
                mess_cache.instance().get_cache_messages(tid_requested,mess_name,true);
            assertEqual(numel(mess),numel(tid_requested));
            assertEqual(numel(mess),numel(mess_present));
            
            %1 2 3 4 5
            %5 6 7 8 9
            %x - x - x
            %r - - - f
            assertTrue(mess_present(1));
            assertFalse(mess_present(2));
            assertFalse(mess_present(3));
            assertFalse(mess_present(4));
            assertTrue(mess_present(5));
            
            assertEqual(mc.get_n_occupied(),4);
            assertEqual(mess_cache.instance().get_n_occupied(),4);
        end
        
        
        function test_cache_operations(obj)
            mess_cache.instance('delete');
            
            mess_list{1} = aMessage('running');
            mess_list{2} = aMessage('running');
            mess_list{3} = aMessage('completed');
            mess_list{4} = aMessage('failed');
            tid = [3,4,5,9];
            
            mc = mess_cache.instance(9);
            mc.clear();
            assertEqual(mc.cache_capacity,9)
            
            mc.push_messages(tid,mess_list);
            
            [mess_rec,tid ] = mess_cache.instance().pop_messages(1:4);
            assertEqual(numel(mess_rec),2)
            assertEqual(numel(tid ),2)
            assertEqual(tid(1),3);
            assertEqual(tid(2),4);
            assertEqual(mc.cache_capacity,9)
            assertEqual(mc.get_n_occupied,2)
            
            mess_list1{1} = aMessage('running');
            mess_list1{2} = aMessage('completed');
            tid = [3,4];
            mc.push_messages(tid,mess_list1);
            
            assertEqual(mc.cache_capacity,9)
            assertEqual(mc.get_n_occupied(),4);
            
            [mess_rec,tid ] = mess_cache.instance().pop_messages([],'completed');
            assertEqual(numel(mess_rec),3)
            assertEqual(numel(tid ),3)
            assertEqual(tid(1),4);
            assertEqual(tid(2),5);
            assertEqual(tid(3),9);
            assertTrue(strcmp(mess_rec{3}.mess_name,'failed'));
            assertEqual(mc.cache_capacity,9)
            
            %  failed messaged are persistent so should not be
            % removed from the cache while all other should
            assertEqual(mc.get_n_occupied(),2);
            
        end
        function test_cache_boolean(obj)
            mess_cache.instance('delete');
            
            mess_list = cell(1,10);
            tid = [3,5,7,9,10];
            mess_list{tid(1)} = aMessage('running');
            mess_list{tid(2)} = aMessage('running');
            mess_list{tid(3)} = aMessage('completed');
            mess_list{tid(4)} = aMessage('failed');
            mess_list{tid(5)} = aMessage('running');
            
            
            mc = mess_cache.instance(10);
            mc.clear();
            assertEqual(mc.cache_capacity,10)
            
            tid_bool = cellfun(@(x)~isempty(x),mess_list);
            mc.push_messages(tid_bool ,mess_list);
            assertEqual(mc.cache_capacity,10)
            
            [mess_rec,tid ] = mess_cache.instance().pop_messages(6:10,'running');
            assertEqual(numel(mess_rec),2)
            assertEqual(numel(tid ),2)
            assertEqual(tid(1),9);
            assertEqual(tid(2),10);
            assertTrue(strcmp(mess_rec{1}.mess_name,'failed'));
            
        end
        function test_cache_single(obj)
            mess_cache.instance('delete');
            mc = mess_cache.instance(11);
            mc.clear();
            assertEqual(mc.cache_capacity,11)
            
            mc.push_messages(3 ,aMessage('running'));
            mc.push_messages(5 ,aMessage('running'));
            mc.push_messages(7 ,aMessage('completed'));
            mc.push_messages(9 ,aMessage('failed'));
            mc.push_messages(10 ,aMessage('running'));
            
            assertEqual(mc.cache_capacity,11)
            assertEqual(mc.get_n_occupied(),5)
            
            [mess_rec,tid ] = mess_cache.instance().pop_messages(6:10,'running');
            assertEqual(numel(mess_rec),2)
            assertEqual(numel(tid ),2)
            assertEqual(tid(1),9);
            assertEqual(tid(2),10);
            assertTrue(strcmp(mess_rec{1}.mess_name,'failed'));
            
            assertEqual(mc.get_n_occupied(),4)
        end
        function test_single_queue(obj)
            mc = single_tid_mess_queue;
            mess = mc.pop();
            assertTrue(isempty(mess));
            
            mc.push(struct('num',1));
            mc.push(struct('num',2));
            mc.push(struct('num',3));
            assertEqual(mc.length,uint64(3));
            mess = mc.pop();
            assertEqual(mc.length,uint64(2));
            assertEqual(mess.num,1);
            
            mc.push(struct('num',4));
            assertEqual(mc.length,uint64(3));
            
            mess = mc.pop();
            assertEqual(mc.length,uint64(2));
            assertEqual(mess.num,2);
            
            mess = mc.pop();
            assertEqual(mc.length,uint64(1));
            assertEqual(mess.num,3);
            
            mess = mc.pop();
            assertEqual(mc.length,uint64(0));
            assertEqual(mess.num,4);
            
            mess = mc.pop();
            assertEqual(mc.length,uint64(0));
            assertTrue(isempty(mess));
            
            mc.push(struct('num',3));
            assertEqual(mc.length,uint64(1));
            
            mess = mc.pop();
            assertEqual(mc.length,uint64(0));
            assertEqual(mess.num,3);
            
            mc.push(struct('num',1,'mess_name','a'));
            mc.push(struct('num',2,'mess_name','b'));
            mc.push(struct('num',3,'mess_name','a'));
            mc.push(struct('num',4,'mess_name','c'));
            assertEqual(mc.length,uint64(4));
            
            [present,queue_key] = mc.check('a');
            assertTrue(present)
            assertEqual(queue_key,1);
            
            mess = mc.pop('a',queue_key);
            assertEqual(mess.num,1);
            assertEqual(mc.length,uint64(3));
            
            [present,queue_key] = mc.check('a');
            assertTrue(present)
            assertEqual(queue_key,3);
            
            mess = mc.pop('a',queue_key);
            assertEqual(mess.num,3);
            assertEqual(mc.length,uint64(2));
            
            mess = mc.pop();
            assertEqual(mess.num,2);
            assertEqual(mess.mess_name,'b');
            assertEqual(mc.length,uint64(1));
            
            mc.push(struct('num',5,'mess_name','a'));
            assertEqual(mc.length,uint64(2));
            
            mess = mc.pop();
            assertEqual(mess.num,4);
            assertEqual(mess.mess_name,'c');
            assertEqual(mc.length,uint64(1));
            
            mess = mc.pop();
            assertEqual(mess.num,5);
            assertEqual(mess.mess_name,'a');
            assertEqual(mc.length,uint64(0));
            
            mc.push(struct('num',1,'mess_name','a'));
            assertEqual(mc.length,uint64(1));
        end
        
    end
    
end
