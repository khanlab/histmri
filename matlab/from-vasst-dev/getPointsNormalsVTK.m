function [points,normals]=getPointsNormalsVTK(surf_vtk);
%gets points and normals from a vtk polydata created in slicer


%get points from vtk 
points=importdata(surf_vtk,' ',5);
points=reshape(points.data',prod(size(points.data)),1);
points(find(isnan(points)))=[]; %remove nans
points=reshape(points,3,length(points)/3);

%get normals data from vtk
[s,startline]=system(['grep -n NORMALS ' surf_vtk '| sed ''s/\:NORMALS\ normals\ float//''']);
normals=importdata(surf_vtk,' ',str2num(startline));
normals=reshape(normals.data',prod(size(normals.data)),1);
normals(find(isnan(normals)))=[]; %remove nans
normals=reshape(normals,3,length(normals)/3);
end