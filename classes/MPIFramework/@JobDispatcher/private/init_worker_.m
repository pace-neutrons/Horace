function  [info,ok,err_mess]  = init_worker_(this,task_id,varargin)
% initialise a worker's info on the job dispatcher side
% Input:
% task_id        -- the identifier of the job to start
% varargin       -- arguments to transmit to the job
% Output:
% info           -- serialized string, used to start worker

mf = this.mess_framework_;
info = mf.build_control(task_id);

mess = aMessage('starting');
mess.payload = varargin{:};

[ok,err_mess]=this.send_message(task_id,mess);
    
