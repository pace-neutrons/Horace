function  [info,ok,err_mess]  = init_worker_(this,job_id,varargin)
% initialise a worker's info on the job dispatcher side
% Input:
% job_id         -- the identifier of the job to start
% varargin       -- arguments to transmit to the job
% Output:
% info           -- serialized string, used to start worker

info = this.init_worker_control(job_id);

mess = aMessage('starting');
mess.payload = varargin{:};

[ok,err_mess]=this.send_message(job_id,mess);
    
