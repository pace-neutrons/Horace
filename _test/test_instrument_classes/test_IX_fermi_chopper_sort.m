classdef test_IX_fermi_chopper_sort < TestCaseWithSave
    % Test of fermi chopper object sorting - tests the object sort routines
    properties
        c_ref
        c_repeat_ref
        c_same
        c_same_arr
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_IX_fermi_chopper_sort (name)
            self@TestCaseWithSave(name);
            
            % Array of choppers that is in increasing order
            self.c_ref = [IX_fermi_chopper(10,150,0.049,1.3,1.2,50),...
                IX_fermi_chopper(10,250,0.049,1.3,1.2,100),...
                IX_fermi_chopper(10,250,0.049,1.3,1.2,120),...
                IX_fermi_chopper(10,350,0.049,1.3,1.2,300),...
                IX_fermi_chopper(10,450,0.049,1.3,1.2,400),...
                IX_fermi_chopper(10,550,0.049,1.3,1.2,350)];
            
            % Random array of multiple repetitions of most (not all) elements
            self.c_repeat_ref = [repmat(self.c_ref(1),1,5),...
                repmat(self.c_ref(2),1,10),...
                repmat(self.c_ref(3),1,15),...
                self.c_ref(4),...
                repmat(self.c_ref(5),1,8),...
                repmat(self.c_ref(6),1,12)];
            ind = randperm(numel(self.c_repeat_ref));
            self.c_repeat_ref = self.c_repeat_ref(ind);
            
            % Repeat of a single object as an array (built to hopefully
            % just being an array of pointers)
            nch = 100;
            tmp = repmat(IX_fermi_chopper,1,nch);
            for i=1:nch
                tmp(i) = IX_fermi_chopper(10,150,0.049,1.3,1.2,50);
            end
            self.c_same_arr = tmp;
            self.c_same = IX_fermi_chopper(10,150,0.049,1.3,1.2,50);
              
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_fermi_sortObj_1 (self)
            % Test of the special sortObj function which assumes simple fields
            c = self.c_ref([6,4,3,1,2,4]);
            
            [csort,ix]=sortObj(c);
            assertEqual(csort,c(ix))
            assertEqual(ix,[4,5,3,2,6,1]);
        end
        
        %--------------------------------------------------------------------------
        function test_fermi_gensort_1 (self)
            % Test of the generic sort function gensort
            c = self.c_ref([6,4,3,1,2,4]);
            
            [csort,ix]=gensort(c);
            assertEqual(csort,c(ix))
            assertEqual(ix,[4,5,3,2,6,1]);
        end
        
        %--------------------------------------------------------------------------
        function test_fermi_sortObj_2 (self)
            % Test of sortObj with element repetitions (checks stable sort output)
            c = self.c_ref([6,1,3,1,3,4]);
            
            [csort,ix]=sortObj(c);
            assertEqual(csort,c(ix))
            assertEqual(ix,[2,4,3,5,6,1]);
        end
        
        %--------------------------------------------------------------------------
        function test_fermi_gensort_2 (self)
            % Test of sortObj with element repetitions (checks stable sort output)
            c = self.c_ref([6,1,3,1,3,4]);
            
            [csort,ix]=gensort(c);
            assertEqual(csort,c(ix))
            assertEqual(ix,[2,4,3,5,6,1]);
        end
        
        %--------------------------------------------------------------------------
        function test_fermi_uniqueObj_1 (self)
            % Test of uniqueObj (which assumes simple fields)
            c = self.c_repeat_ref;
            c_unique = self.c_ref;

            [c_out,m,n] = uniqueObj(c);
            assertEqual(c_out,c_unique)
            assertEqual(c(m), c_out);
            assertEqual(c_out(n), c);
        end
        
        %--------------------------------------------------------------------------
        function test_fermi_genunique_1 (self)
            % Test of genunique (generic sort)
            c = self.c_repeat_ref;
            c_unique = self.c_ref;

            [c_out,m,n] = genunique(c,'resolve');   % resolves objects to structures first
            assertEqual(c_out,c_unique)
            assertEqual(c(m), c_out);
            assertEqual(c_out(n), c);
        end
        
        %--------------------------------------------------------------------------
        function test_fermi_genunique_2 (self)
            % Test of genunique (generic sort)
            c = self.c_repeat_ref;
            c_unique = self.c_ref;

            [c_out,m,n] = genunique(c);   % sorts as objects, not as structures
            assertEqual(c_out,c_unique)
            assertEqual(c(m), c_out);
            assertEqual(c_out(n), c);
        end
        
        %--------------------------------------------------------------------------
        function test_fermi_uniqueObj_single_1 (self)
            % Test of uniqueObj (which assumes simple fields) - single unique element
            c = self.c_same_arr;
            c_unique = self.c_same;

            [c_out,m,n] = uniqueObj(c);
            assertEqual(c_out,c_unique)
            assertEqual(c(m), c_out);
            assertEqual(c_out(n), c(:));
        end
        
        %--------------------------------------------------------------------------
        function test_fermi_genunique_single_1 (self)
            % Test of genunique (generic sort) - single unique element
            c = self.c_same_arr;
            c_unique = self.c_same;

            [c_out,m,n] = genunique(c,'resolve');   % resolves objects to structures first
            assertEqual(c_out,c_unique)
            assertEqual(c(m), c_out);
            assertEqual(c_out(n), c(:));
        end
        
        %--------------------------------------------------------------------------
        function test_fermi_genunique_single_2 (self)
            % Test of genunique (generic sort) - single unique element
            c = self.c_same_arr;
            c_unique = self.c_same;

            [c_out,m,n] = genunique(c);   % sorts as objects, not as structures
            assertEqual(c_out,c_unique)
            assertEqual(c(m), c_out);
            assertEqual(c_out(n), c(:));
        end
        
        %--------------------------------------------------------------------------
    end
end
