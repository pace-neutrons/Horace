classdef test_sortStruct < TestCaseWithSave
    % Test of sortStruct, uniqueStruct
    properties
        anum
        blog
        cchr
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_sortStruct (name)
            self@TestCaseWithSave(name);
            
            % Cell arrays with elements in increasing order
            self.anum = {[33,99;44,55], [33,44;99,55], [11;9;4], [11;9;4;6;1]};
            self.blog = {true(0,0), [true, false], [true, false, false, true], [true;true]};
            self.cchr= {'Man','hell','hello','Mister'};
            
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_1 (self)
            % Test sorting on one field (all distinct elements) - row structure
            a = self.anum([3,1,4,1]);
            b = self.blog([2,3,1,4]);
            c = self.cchr([2,2,1,3]);
            aStruct = struct('a',a,'b',b,'c',c);
            [bStruct,ix] = sortStruct(aStruct,'b');
            assertEqual(ix,[3,1,2,4])
            assertEqual(bStruct,aStruct(ix))
        end
        
        %--------------------------------------------------------------------------
        function test_2 (self)
            % Test sorting on one field (all distinct elements) - column structure
            a = self.anum([3,1,4,1]);
            b = self.blog([2,3,1,4]);
            c = self.cchr([2,2,1,3]);
            aStruct = struct('a',a','b',b','c',c');
            [bStruct,ix] = sortStruct(aStruct,'b');
            assertEqual(ix,[3,1,2,4]')
            assertEqual(bStruct,aStruct(ix))
        end
        
        %--------------------------------------------------------------------------
        function test_3 (self)
            % Test sorting on two fields (distinct as paired) - row structure
            a = self.anum([3,1,4,1]);
            b = self.blog([2,3,1,4]);
            c = self.cchr([2,2,1,3]);
            aStruct = struct('a',a,'b',b,'c',c);
            [bStruct,ix] = sortStruct(aStruct,{'a','c'});
            assertEqual(ix,[2,4,1,3])
            assertEqual(bStruct,aStruct(ix))
        end
        
        %--------------------------------------------------------------------------
        function test_4 (self)
            % Test sorting on two fields (distinct as paired) - row structure
            a = self.anum([3,1,4,1]);
            b = self.blog([2,3,1,4]);
            c = self.cchr([2,2,1,3]);
            aStruct = struct('a',a,'b',b,'c',c);
            [bStruct,ix] = sortStruct(aStruct,{'c','a'});
            assertEqual(ix,[3,2,1,4])
            assertEqual(bStruct,aStruct(ix))
        end

        %--------------------------------------------------------------------------
        function test_5 (self)
            % Test sorting on two fields (distinct as paired) - column structure
            a = self.anum([3,1,4,1]);
            b = self.blog([2,3,1,4]);
            c = self.cchr([2,2,1,3]);
            aStruct = struct('a',a','b',b','c',c');
            [bStruct,ix] = sortStruct(aStruct,{'c','a'});
            assertEqual(ix,[3,2,1,4]')
            assertEqual(bStruct,aStruct(ix))
        end

        %--------------------------------------------------------------------------
        function test_6 (self)
            % Test sorting on all fields - row structure
            a = self.anum([3,1,1,4]);
            b = self.blog([2,3,3,4]);
            c = self.cchr([2,2,3,3]);
            aStruct = struct('a',a,'b',b,'c',c);
            [bStruct,ix] = sortStruct(aStruct,{'a','b','c'});
            assertEqual(ix,[2,3,1,4])
            assertEqual(bStruct,aStruct(ix))
        end

        %--------------------------------------------------------------------------
        function test_7 (self)
            % Test sorting on all fields by default - row structure
            a = self.anum([3,1,1,4]);
            b = self.blog([2,3,3,4]);
            c = self.cchr([2,2,3,3]);
            aStruct = struct('a',a,'b',b,'c',c);
            [bStruct,ix] = sortStruct(aStruct);
            assertEqual(ix,[2,3,1,4])
            assertEqual(bStruct,aStruct(ix))
        end

        %--------------------------------------------------------------------------
        function test_8 (self)
            % Test sorting on all fields with direction reversal - row structure
            a = self.anum([3,1,1,3]);
            b = self.blog([2,3,3,4]);
            c = self.cchr([2,2,3,3]);
            aStruct = struct('a',a,'b',b,'c',c);
            [bStruct,ix] = sortStruct(aStruct,{'a','b','c'},[1,-1,-1]);
            assertEqual(ix,[3,2,4,1])
            assertEqual(bStruct,aStruct(ix))
        end

        %--------------------------------------------------------------------------
        function test_9 (self)
            % Test uniqueStruct - row structure
            a = self.anum([3,1,1,2,3,2,1,3]);
            b = self.blog([2,3,3,4,2,4,1,2]);
            c = self.cchr([2,3,3,3,2,3,1,2]);
            aStruct = struct('a',a,'b',b,'c',c);
            [bStruct,m,n] = uniqueStruct(aStruct);
            assertEqual(m,[7,2,4,1]')
            assertEqual(n,[4,2,2,3,4,3,1,4]')
            assertEqual(bStruct,aStruct(m))
        end

        %--------------------------------------------------------------------------
        function test_10 (self)
            % Test uniqueStruct - column structure
            a = self.anum([3,1,1,2,3,2,1,3]);
            b = self.blog([2,3,3,4,2,4,1,2]);
            c = self.cchr([2,3,3,3,2,3,1,2]);
            aStruct = struct('a',a','b',b','c',c');
            [bStruct,m,n] = uniqueStruct(aStruct);
            assertEqual(m,[7,2,4,1]')
            assertEqual(n,[4,2,2,3,4,3,1,4]')
            assertEqual(bStruct,aStruct(m))
        end

        %--------------------------------------------------------------------------
        function test_11 (self)
            % Test uniqueStruct - row structure, legacy behaviour of built-in unique
            a = self.anum([3,1,1,2,3,2,1,3]);
            b = self.blog([2,3,3,4,2,4,1,2]);
            c = self.cchr([2,3,3,3,2,3,1,2]);
            aStruct = struct('a',a,'b',b,'c',c);
            [bStruct,m,n] = uniqueStruct(aStruct,'legacy');
            assertEqual(m,[7,3,6,8])
            assertEqual(n,[4,2,2,3,4,3,1,4])
            assertEqual(bStruct,aStruct(m))
        end

        %--------------------------------------------------------------------------
        function test_12 (self)
            % Test uniqueStruct - column structure, legacy behaviour of built-in unique
            a = self.anum([3,1,1,2,3,2,1,3]);
            b = self.blog([2,3,3,4,2,4,1,2]);
            c = self.cchr([2,3,3,3,2,3,1,2]);
            aStruct = struct('a',a','b',b','c',c');
            [bStruct,m,n] = uniqueStruct(aStruct,'legacy');
            assertEqual(m,[7,3,6,8]')
            assertEqual(n,[4,2,2,3,4,3,1,4]')
            assertEqual(bStruct,aStruct(m))
        end

        %--------------------------------------------------------------------------
    end
end
