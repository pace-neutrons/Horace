function delete_buffers
% Remove stsord moderator models etc

buffered_sampling_table(IX_moderator(0,0,'ikcarp',[5,20,0.3]),1,'purge');
buffered_sampling_table(IX_fermi_chopper,'purge');
buffered_sampling_table(IX_divergence_profile([1,2,3,4],[0,1,1,0]),'purge');



