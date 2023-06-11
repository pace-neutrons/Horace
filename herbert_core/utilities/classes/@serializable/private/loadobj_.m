function obj = loadobj_(S, obj_template)
% %*******************************************************************************
% %*******************************************************************************
% %
% %   CAN DELETE THIS NOW, AS CODE PUT IN METHOD LOADOBJ
% %
% %*******************************************************************************
% %*******************************************************************************
% % Restore object or array of objects from a structure
% %
% %   >> obj = loadobj_ (S)
% %   >> obj = loadobj_ (S, obj_template)
% %
% % The class of the object to restore is determined from a field of the
% % structure with name 'serial_name'.
% %
% % If there is not a field called 'serial_name'
% %
% % Input:
% % ------
% %   S       Structure from which to restore an object or array of
% %           objects.
% %
% %           If the template object obj_in (below) is not given, then
% %
% % Optional:
% %   obj_in  Instance of
% %
% %
% % Output:
% % -------
% %   obj     An instance of class_instance object or array of objects
% 
% 
% if isstruct(S)
%     % As S is a structure, attempt to load using from_struct_
%     if nargin==2
%         obj = from_struct_ (S, obj_template);
%     else
%         obj = from_struct_ (S);
%     end
% else
%     % We allow that in the case of S being an object that matches the class of
%     % the template object, then simply return S as the object
%     if nargin==2
%         if isa(S, class(obj_template))
%             obj = S;
%         else
%             error('HERBERT:serializable:invalid_argument',...
%                 'The input data and template object class names do not match')
%         end
%     else
%         error('HERBERT:serializable:invalid_argument',...
%             'The input data is not a structure but no template object class was given')
%     end
% end
