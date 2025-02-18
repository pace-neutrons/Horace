classdef test_get_en_transfer< TestCase
    %
    %

    properties
    end
    methods
        %
        function obj=test_get_en_transfer(varargin)
            if nargin == 0
                name = 'test_get_en_transfer';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
            
        end
        %------------------------------------------------------------------
        function test_multiple_unique_en_lidx(~)
            id1 = IX_experiment();
            en1 = -0.5:1:10.5;
            en2 = -2:2:21;            
            id1.en =en1 ;
            id = repmat(id1,1,5);
            id1.en =en2 ;            
            id2 = repmat(id1,1,3);            
            id1.en =en1 ;                     
            id3 = repmat(id1,1,2);                        
            id = [id,id2,id3];

            [uen,lidx] = get_en_transfer(id,true,true);

            assertEqual(uen,{0.5*(en1(1:end-1)+en1(2:end)), ...
                0.5*(en2(1:end-1)+en2(2:end))});
            assertEqual(lidx,{[1:5,9,10],[6,7,8]});
        end
        
        function test_multiple_unique_en_gidx(~)
            id1 = IX_experiment();
            en1 = -0.5:1:10.5;
            en2 = -2:2:21;            
            id1.en =en1 ;
            id = repmat(id1,1,5);
            id1.en =en2 ;            
            id2 = repmat(id1,1,3);            
            id1.en =en1 ;                     
            id3 = repmat(id1,1,2);                        
            id = [id,id2,id3];

            [uen,gidx] = get_en_transfer(id,true,false);

            assertEqual(uen{1},0.5*(en1(1:end-1)+en1(2:end)));
            assertEqual(uen{2},0.5*(en2(1:end-1)+en2(2:end)));            
            assertEqual(gidx,{1,6});
        end
        
        function test_single_unique_en_lidx(~)
            id1 = IX_experiment();
            en = -0.5:1:10.5;
            id1.en =en ;
            id = repmat(id1,1,5);
            

            [uen,lidx] = get_en_transfer(id,true,true);

            assertEqual(uen,{0.5*(en(1:end-1)+en(2:end))});
            assertEqual(lidx,{1:5});
        end
        
        function test_single_unique_en(~)
            id1 = IX_experiment();
            en = -0.5:1:10.5;
            id1.en =en ;
            id = repmat(id1,1,5);
            

            [uen,gidx] = get_en_transfer(id,true,false);

            assertEqual(uen,{0.5*(en(1:end-1)+en(2:end))});
            assertEqual(gidx,{1});
        end
    end
end
