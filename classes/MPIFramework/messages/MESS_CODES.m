classdef MESS_CODES < uint32
    % Helper class to keep custom MPI framework error messages
    %
    enumeration
        not_exist       (0)
        ok              (1)
        job_canceled    (2)
        a_recieve_error (3)
        a_send_error    (4)
        runtime_error   (5) % should it just throw in this case?
        timeout_exceeded (6) % exceeded timeout for waiting for blocking message
    end
end
