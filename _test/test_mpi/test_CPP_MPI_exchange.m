classdef test_CPP_MPI_exchange< TestCase
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %
    
    properties
    end
    methods
        %
        function obj=test_CPP_MPI_exchange(name)
            if ~exist('name','var')
                name = 'test_CPP_MPI_exchange';
            end
            obj = obj@TestCase(name);
        end
        function xest_MessagesCppMPI_constructor(this)
            % crashes Matlab if applied for second time
            % needs some thinking on how to avoid this. 
            if isempty(which('cpp_communicator'))
                return
            end
            mf = MessagesCppMPI('test_comm');
            clob = onCleanup(@()(finalize_all(mf)));
            
            assertEqual(mf.labIndex,uint64(1));
            assertEqual(mf.numLabs,uint64(1));
                       
        end
    end
end


