classdef test_singleton_impl<TestCase
    % Test Script for Class SingletonImpl
    % Step through and execute this script cell-by-cell to verify the Singleton
    % Desgin Pattern implementation in MATLAB.
    %
    % Written by Bobby Nedelkovski
    % The MathWorks Australia Pty Ltd
    % Copyright 2009, The MathWorks, Inc.
    
    
    methods
        function this = test_singleton_impl(name)
            this = this@TestCase(name);
        end
       function this=tearDown(this)

            clear SingletonImplToTest;
        end
        
        function rez=wrong_access(this)
            % Try Create Instance with Constructor
            % This yields an error as expected since we are guarding the constructor
            % from user access.
            rez=SingletonImplToTest();
        end
        function rez=wrong_access1(this)
            % Create Instance 'a' Using instance() Method
            a = SingletonImplToTest.instance();
            a.singletonData;
        end
        function test_wrong_constructions(this)
            
            f = @()this.wrong_access();
            assertExceptionThrown(f,'MATLAB:class:MethodRestricted');                                 

            
            % Check Protected Property
            % This yields an error as singletonData is private to the abstract class
            % Singleton.            
            f = @()this.wrong_access1();            
            assertExceptionThrown(f,'MATLAB:noSuchMethodOrField');            
            
        end
        function test_proper_work(this)
            
            % Create Instance 'a' Using instance() Method
            a = SingletonImplToTest.instance();
            
            % Query Protected Property
            data = a.getSingletonData();
            assertTrue(isempty(data));
            
            
            %Modify Protected Property
            a.setSingletonData(0);
            
            
            % Query Protected Property
            % Verify that singletonData has changed -> singletonData = 0.
            data = a.getSingletonData();
            assertEqual(0,data)
            
            % Use Custom Method
            % This method internally modifies singletonData.
            a.myOperation(9);
            
            
            % Check Custom Method
            % Check that singletonData has changed -> singletonData = 9.
            data = a.getSingletonData();
            assertEqual(9,data)
            
            % Modify Custom Attribute Using 'a'
            a.myData = 1;
            
            data = a.getSingletonData();
            assertEqual(9,data)
            assertEqual(1,a.myData)            
            
            % Create Another Reference 'b' to the Same Singleton
            % Notice that 'a' and 'b' refer to the same object in memory ->
            % singletonData = 1 for both.
            b = SingletonImplToTest.instance();
            
            
            % Modify Custom Attribute Using 'b'
            % Both 'a' and 'b' reflect the change in value.
            b.myData = 3;
            assertEqual(a,b)
            assertEqual(3,b.myData)
            
            % Clear Variable 'a' From Workspace
            clear a
            assertEqual(3,b.myData)
            
            
            % Create Another Reference 'c' to the Same Singleton
            % Notice that 'b' and 'c' refer to the same object in memory ->
            % myData = 3 for both
            c = SingletonImplToTest.instance();
            assertEqual(3,c.myData)
            
            % Modify Custom Attribute Using 'c'
            % Both 'b' and 'c' reflect the change in value.
            c.myData = 5;
            assertEqual(c,b)
            assertEqual(5,c.myData)
            
            
            % Clear Variables
            % No variables
            clear b c data
            
            
            % Create Another Reference 'd' to the Same Singleton
            % Notice that 'd' refers to the same object in memory as did 'a', 'b' and
            % 'c' earlier -> myData = 5
            d = SingletonImplToTest.instance();
            assertEqual(5,d.myData)
            
            % Destroy Singleton in Memory
            %clear all
            clear SingletonImplToTest
            
            % Create New Instance 'e'
            % The myData property is empty.
            e = SingletonImplToTest.instance();
            assertTrue(isempty(e.myData));
             
        end
    end
end
