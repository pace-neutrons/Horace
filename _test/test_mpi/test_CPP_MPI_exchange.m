classdef test_CPP_MPI_exchange< TestCase
    %
    % $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)
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
        function test_MessagesCppMPI_constructor(this)
            if isempty(which('cpp_communicator'))
                return
            end
            mf = MessagesCppMPI_tester('test_comm');
            clob = onCleanup(@()(finalize_all(mf)));
            
            assertEqual(mf.labIndex,uint64(1));
            assertEqual(mf.numLabs,uint64(1));
           
            % test direct access to framework's lab_index
            [mf,labNum,nLabs]=mf.lab_index_test();
            assertEqual(labNum,uint64(1));            
            assertEqual(nLabs,uint64(1));                        
            mf.finalize_all();
        end
    end
end


