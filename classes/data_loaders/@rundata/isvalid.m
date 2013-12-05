function [ok, mess,this] = isvalid (this)
% Check fields for data_array object
%
%   >> [ok, mess] = isvalid (w)
%
%   ok      ok=true if valid, =false if not
%   mess    Message if not a valid object, empty string if is valid.
%
%
% Original author: T.G.Perring
%
% 	15 August 2009  Pass w to checkfields, so that checkfields can alter fields
%                   of object. Because checkfields is a private method, the fields
%                   can be altered using w.x=<new value> *without* calling
%                   set.m. (T.G.Perring)

% check numeric
numeric_fld = {'S','ERR','efix','en','emode','n_detectors','det_par',...
           'alatt','angldeg','u','v','psi','omega','dpsi','gl','gs'};
for i=1:numel(numeric_fld)       
    if ~isempty(this.(numeric_fld{i}))
        if ~isa(this.(numeric_fld{i}),'numeric')
            ok = false;
            mess = [' field: ',numeric_fld{i},' has to be numeric but it is not'];
            return
        end
    end
end

% check S dimensions wrt ERR dimensions
mess='';
ok  = true;
if (~isempty(this.S)) && (~isempty(this.ERR))
    if size(this.S)~=size(this.ERR)
         mess='sizes S and ERR fields have to be equal';
         ok = false;
         return;
    end
end

% check en dimensions wrt the signal dimensions
if ~isempty(this.en)
    if ~iscolvector(this.en)
        if isrowvector(this.en)
            this.en = this.en';
            if get(herbert_config,'log_level')>0
                warning('RUNDATA:isvalid','en vector was a row vector which has been transformed into a column vector');
            end
        else
            ok=false;
            mess = 'en field, if present, has to be a column vector';
            return;
        end
    end
    
    if (~isempty(this.S))
        if numel(this.en) ~= size(this.S,1)+1
           ok=false;
           mess = [' en field has ',num2str(numel(this.en)),' elements and signal has ',num2str(size(this.S,1)),'x',num2str(size(this.S,2))...
                   ' elements.\n This is inconcistent as en field describes enery bins for array of signals and its value should be equal to  ',...
                     num2str(size(this.S,1)), ' plus one'];
           return;
        end
    end
end
% check efix and energy boundary wrt efix
if ~isempty(this.efix)
    if this.efix<=0
        ok=false;
        mess = ['efix has to be positive but appears to be: ',num2str(this.efix)];
        return;
    end
    if ~isempty(this.en) && this.emode == 1
        if this.efix<this.en(end)
          ok=false;
          mess = ['Last energy transfer boundarty has to be smaller then efix. In reality: efix=',...
                  num2str(this.efix),', e_transfer max=',num2str(this.en(end))];
          return;
        end
    end
end

% check det_par 
if ~isempty(this.det_par)
    if size(this.det_par,1)~=6
        ok=false;
        mess=['det_par field has to be a [6xndet] array, but has: ',num2str(size(this.det_par,1)),' columns'];
        return
    end
    if ~isempty(this.S)
        if size(this.det_par,2)~=size(this.S,2)
            ok=false;
            mess = ['Second dimension in det_par array has to coinside with the second dimension of signal array',...
                    ' In fact size(det_par,2)=',num2str(size(this.det_par,2)),' and size(S,2)=',num2str(size(this.S,2))];
            return;
        end
    end
    % TODO: add check for ndet, proper set should modify it;
end

% check iscrystal
if ~isempty(this.is_crystal)
    if ~((this.is_crystal==0) || (this.is_crystal==1))
        ok = false;
        mess = ['is_crystal has to be either true or false, is: ',num2str(this.is_crystal)];
        return;
    end
end


% check three-vectors
three_vectors_names={'alatt','angldeg','u','v'};
for i=1:numel(three_vectors_names)
    if ~isempty(this.(three_vectors_names{i}))
        n_elem=numel(this.(three_vectors_names{i}));
        if n_elem~=3
            ok = false;
            mess=[' field: ',three_vectors_names{i},' has to be a vector with 3 elements but has: ',...
                 num2str(n_elem),' element(s)'];
            return;
        end

    end
end
% check one-vectors
one_vectors_names={'psi','omega','dpsi','gl','gs'};
for i=1:numel(one_vectors_names)
    if ~isempty(this.(one_vectors_names{i}))
         n_elem=numel(this.(one_vectors_names{i}));
        if n_elem~=1
            ok = false;
            mess=[' field: ',one_vectors_names{i},' has to have 1 element but has: ',...
                 num2str(n_elem),' element(s)'];
            return;
        end

    end
end


% check angular variables -- degrees:
angular_var_names={'angldeg','psi','omega','dpsi','gl','gs'};
for i=1:numel(angular_var_names)
    if ~isempty(this.(angular_var_names{i}))
         if max(abs(this.(angular_var_names{i})))>360
            ok = false;
            mess=[' field: ',angular_var_names{i},' has to be an angular variable in deg but equal to: ',...
                 num2str(this.(angular_var_names{i}))];
            return;
        end

    end
end

% check correct angular values for lattice
if ~isempty(this.angldeg)
    if (this.angldeg(1)>=(this.angldeg(2)+this.angldeg(3)))||...
       (this.angldeg(2)>=(this.angldeg(3)+this.angldeg(1)))||...
       (this.angldeg(3)>=(this.angldeg(1)+this.angldeg(2)))
   
        ok=false;
        mess='field ''angldeg'' does not define correct 3D lattice';
        return;
    end
end




