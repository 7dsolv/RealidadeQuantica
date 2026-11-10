function info = konaet_write_stl(output)
%KONAET_WRITE_STL Geometria de placa X02 e envelopes, em milimetros.
b=konaet_acquisition_board(); folder=fullfile(output,'hardware');
p=[0 0;b.size_mm(1) 0;b.size_mm(1:2);0 b.size_mm(2)];edge=[1 2;2 3;3 4;4 1];
for k=1:size(b.holes_mm,1)
    a=-(0:23)'*2*pi/24;first=size(p,1)+1;
    p=[p;b.holes_mm(k,:)+b.hole_diameter_mm/2*[cos(a) sin(a)]]; %#ok<AGROW>
    ids=(first:first+23)';edge=[edge;ids [ids(2:end);ids(1)]]; %#ok<AGROW>
end
tri=delaunayTriangulation(p,edge);top=tri.ConnectivityList(isInterior(tri),:);p=tri.Points;n=size(p,1);
vertices=[p zeros(n,1);p repmat(b.size_mm(3),n,1)]; faces=[fliplr(top);top+n];
for k=1:size(edge,1)
    a=edge(k,1);z=edge(k,2);faces=[faces;a z z+n;a z+n a+n]; %#ok<AGROW>
end
for part=b.parts
    center=[part.xy_mm+mean(part.pads_mm,1) b.size_mm(3)+0.05+part.body_mm(3)/2];
    [v,f]=cube(center,part.body_mm);faces=[faces;f+size(vertices,1)];vertices=[vertices;v]; %#ok<AGROW>
    for j=1:size(part.pads_mm,1)
        if part.drill_mm>0,sz=[0.64 0.64 8];height=2;else,sz=[part.pad_size_mm 0.2];height=0.1;end
        [v,f]=cube([part.xy_mm+part.pads_mm(j,:) b.size_mm(3)+height],sz);
        faces=[faces;f+size(vertices,1)];vertices=[vertices;v]; %#ok<AGROW>
    end
end
path=fullfile(folder,'x02-acquisition.stl');stlwrite(triangulation(faces,vertices),path,'binary');
info=struct('units','mm','triangles',size(faces,1),'bytes',dir(path).bytes, ...
    'geometry','approximate envelopes, not manufacturer CAD; includes four mounting holes');
assert(info.bytes<10e6);konaet_write_json(fullfile(folder,'geometry.json'),info);
end
function [v,f]=cube(center,sz)
v=[-1 -1 -1;1 -1 -1;1 1 -1;-1 1 -1;-1 -1 1;1 -1 1;1 1 1;-1 1 1].*sz/2+center;
f=[1 3 2;1 4 3;5 6 7;5 7 8;1 2 6;1 6 5;2 3 7;2 7 6;3 4 8;3 8 7;4 1 5;4 5 8];
end
