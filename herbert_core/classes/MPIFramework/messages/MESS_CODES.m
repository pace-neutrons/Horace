classdef MESS_CODES < uint32
    % Helper class to keep custom MPI framework error messages
    %
    enumeration
        not_exist       (0)
        ok              (1)
        job_cancelled    (2)
        job_cancelled_request  (3) % received job cancelled message request
        a_recieve_error (4)
        a_send_error    (5)
        runtime_error   (6) % should it just throw in this case?
        timeout_exceeded (7) % exceeded timeout for waiting for blocking message
        write_lock_persists (7) % writer can not delete write lock
    end
end
