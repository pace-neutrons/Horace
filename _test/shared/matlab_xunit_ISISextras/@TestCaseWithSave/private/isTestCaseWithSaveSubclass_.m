function tf = isTestCaseWithSaveSubclass_(name)
% True for name of a TestCaseWithSave subclass
%   >> tf = isTestCaseWithSaveSubclass_ (name)
%
% Code is a copy of isTestCaseSubclass from the Matlab xUnit test suite by
% Steven L. Eddins, (see below), with the name of the superclass changed
%
%   Steven L. Eddins
%   Copyright 2008-2009 The MathWorks, Inc.


tf = false;

class_meta = meta.class.fromName(name);
if isempty(class_meta)
    % Not the name of a class
    return;
end

if strcmp(class_meta.Name, 'TestCaseWithSave')
    tf = true;
else
    tf = isMetaTestCaseSubclass(class_meta);
end

%------------------------------------------------------------------------------
function tf = isMetaTestCaseSubclass(class_meta)

tf = false;

if strcmp(class_meta.Name, 'TestCaseWithSave')
    tf = true;
else
    % Invoke function recursively on parent classes.
    super_classes = class_meta.SuperClasses;
    for k = 1:numel(super_classes)
        if isMetaTestCaseSubclass(super_classes{k})
            tf = true;
            break;
        end
    end
end

