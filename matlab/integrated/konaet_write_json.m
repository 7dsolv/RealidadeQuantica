function konaet_write_json(path,value)
fid=fopen(path,'w','n','UTF-8'); assert(fid>=0); guard=onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid,'%s\n',jsonencode(value,PrettyPrint=true));
end
