function [obj,hash,is_calculated] = build_hash(obj)
% makes a hash from the argument object which will be unique
% when generated from any identical object
%
% Input:
% obj      -- object to be hashed
%
% Output:
% obj      -- unchanged object. Present here to maintain interface, common
%             with the same named method in hashable.
% hash     -- the resulting hash, a row vector of uint8's
% is_calsulated
%          --  always true, kept to support common interface to hashable
%

is_calculated = true;
% get config to use use_mex
use_mex = config_store.instance().get_value('hor_config','use_mex');
persistent Engine;
% In case the java engine is going to be used, initialise it as
% a persistent object
if isa(obj,'uint8')
    bytestream = obj;
else
    bytestream = serialize(obj);
end

if use_mex
    % mex version to be used, use it
    hash = GetMD5(bytestream);
else

    if isempty(Engine)
        Engine = java.security.MessageDigest.getInstance('MD5');
    end


    % mex version not to be used, manually construct from the
    % Java engine
    Engine.update(bytestream);
    hash0 = Engine.digest;

    %using the following typecast to remedy that dec2hex
    %does not work with negative numbers before Matlab 2020b.
    %the typecast moves negative numbers to twos-complement
    %positive representation, as is automatically done by the
    %later dec2hex
    hash1 = typecast(hash0,'uint8');

    hash2 = dec2hex(hash1);
    hash3 = cellstr(hash2);
    hash4 = horzcat(hash3{:});
    hash = lower(hash4); 
end
