classdef test_obj2struct < TestCaseWithSave
    % Test of obj2struct
    properties
        mod1
        mod2
        mod3
        mod4
        chop1
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_obj2struct (name)
            self@TestCaseWithSave(name);
            
            % Some moderators
            moderator = IX_moderator(10,13,'ikcarp',[5,25,0.4]);
            self.mod1 = moderator; self.mod1.distance = 1;
            self.mod2 = moderator; self.mod2.distance = 2;
            self.mod3 = moderator; self.mod3.distance = 3;
            self.mod4 = moderator; self.mod4.distance = 4;
            
            % A chopper
            self.chop1 = IX_fermi_chopper(10,150,0.049,1.3,0.003,Inf, 0, 0,50);
            
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_1 (self)
            % Simple structure - should be unchanged
            S.a = {'hello'};
            Sres = obj2structIndep(S);
            
            assertEqualWithSave (self,Sres);
            
        end
        
        %--------------------------------------------------------------------------
        function test_2 (self)
            % Structure of array of objects - public properties
            S.a = {[self.mod1,self.mod2]};
            Sres = obj2struct(S);
            
            assertEqualWithSave (self,Sres);
            
        end
        
        %--------------------------------------------------------------------------
        function test_3 (self)
            % Structure of array of objects - independent properties
            S.a = {[self.mod1,self.mod2]};
            Sres = obj2structIndep(S);
            
            assertEqualWithSave (self,Sres);
            
        end
        
        %--------------------------------------------------------------------------
        function test_4 (self)
            % Complicated structure - public properties
            Ssub2.aa = 'kitty';
            Ssub2.bb = IX_aperture;
            
            Ssub.a = {'hello',[34,35],[self.mod1,self.mod2],{self.mod3,self.mod4},Ssub2};
            Ssub.b = [101,102,103];
            
            S.alph = self.chop1;
            S.beta = Ssub;
            
            Sres = obj2struct(S);
            
            assertEqualWithSave (self,Sres);
            
        end
        
        %--------------------------------------------------------------------------
        function test_5 (self)
            % Complicated structure - independent properties
            Ssub2.aa = 'kitty';
            Ssub2.bb = IX_aperture;
            
            Ssub.a = {'hello',[34,35],[self.mod1,self.mod2],{self.mod3,self.mod4},Ssub2};
            Ssub.b = [101,102,103];
            
            S.alph = self.chop1;
            S.beta = Ssub;
            
            Sres = obj2structIndep(S);
            
            assertEqualWithSave (self,Sres);
            
        end
        
        %--------------------------------------------------------------------------
    end
end


