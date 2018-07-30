classdef single_tid_mess_queue < matlab.mixin.Copyable
    % The class provides FIFO queue for the messages
    %
    properties(Dependent)
        length
    end
    properties(Access = private)
        next_ = 0;
        n_message_ = 0;
        buffer_ ;
        failed_ = [];
    end
    methods
        function n_mess = get.length(obj)
            % return number of elements, stored in the queue.
            if ~isempty(obj.failed_)
                n_mess = uint64(1);
                return;
            end
            
            if obj.n_message_ ==0
                n_mess = uint64(0);
            else
                n_mess  = obj.buffer_.Count;
            end
        end
        function [ok,queue_key]=check(obj,mess_name)
            % check if the message with the specified name is present in the
            % queue.
            
            %Returns:
            % ok    -- true if message exist and false if not
            % queue_key -- if ok == true, the key to retrieve message from
            %              the messages queue, if oj==false queue_key == 0;
            queue_key = 0;
            if ~isempty(obj.failed_)
                ok=true;
                return;
            end
            ok = false;
            
            if ~obj.n_message_ == 0
                keys = obj.buffer_.keys();
                keys = [keys{:}];  %  theoretically it may not be necessary,
                keys = sort(keys); % but
                for i=1:numel(keys)
                    if strcmp(obj.buffer_(keys(i)).mess_name,mess_name)
                        ok = true;
                        queue_key = keys(i);
                        break;
                    end
                end
            end
        end
        function push(obj,mess)
            % add message to the end of the queue
            if ischar(mess) && strcmp(mess,'failed')
                obj.failed_ = aMessage('failed');
                return
            elseif isa(mess,'aMessage') && strcmp(mess.mess_name,'failed')
                obj.failed_ = mess;
                return;
            end
            if obj.n_message_ == 0
                obj.n_message_ = 1;
                obj.next_      = 1;
                obj.buffer_ = containers.Map(1,mess);
            else
                obj.n_message_ = obj.n_message_+1;
                obj.buffer_(obj.n_message_) = mess;
            end
        end
        function mess = pop(obj,mess_name,queue_ind)
            % return the oldest message and remove it from the queue
            %
            if ~isempty(obj.failed_)
                mess = obj.failed_;
                return;
            end
            
            if obj.n_message_ == 0
                mess = [];
                return
            end
            if exist('mess_name','var') % pop only next message requested
                if ~exist('queue_ind','var')
                    [present,queue_ind] = obj.check(mess_name);
                else
                    present = true;
                end
                if ~present
                    mess = [];
                    return
                end
                if queue_ind == obj.next_
                    mess = obj.progress_queue_(queue_ind);
                else
                    mess = obj.buffer_(queue_ind);
                    obj.buffer_.remove(queue_ind);
                end
            else
                key = obj.next_;
                mess = obj.progress_queue_(key);
            end
        end
    end
    methods(Access=private)
        function mess = progress_queue_(obj,key)
            mess = obj.buffer_(key);
            obj.next_ =  obj.next_ +1;
            while ~obj.buffer_.isKey(obj.next_) && obj.next_ <=obj.n_message_
                obj.next_ = obj.next_+1;
            end
            if obj.next_ > obj.n_message_
                obj.n_message_ = 0;
                obj.next_      = 0;
            else
                obj.buffer_.remove(key);
            end
            
        end
    end
end
