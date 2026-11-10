function konaet_commit_memory(path,history,expected)
%KONAET_COMMIT_MEMORY Bounded local transaction; never overwrite newer state.
lock=java.io.File([path '.lock']);
assert(lock.createNewFile(),'Konaet:StateBusy','Outra execucao esta publicando a memoria.');
lock_guard=onCleanup(@() lock.delete()); %#ok<NASGU>
assert(strcmp(fileread(path),expected),'Konaet:StaleState','A memoria avancou durante o calculo; descarte esta rodada.');
temporary=[tempname(fileparts(path)) '.csv'];
file_guard=onCleanup(@() remove_temporary(temporary)); %#ok<NASGU>
writematrix(history,temporary);
[ok,message]=movefile(temporary,path,'f');assert(ok,'Konaet:StateWrite','%s',message);
end
function remove_temporary(path)
if isfile(path),delete(path);end
end
