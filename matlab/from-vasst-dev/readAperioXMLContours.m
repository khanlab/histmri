function [contours,contoursClosed, names,names_alt] = readAperioXMLContours(xml)
    fid = fopen(xml,'r');
    if fid==-1
        error('Could not open file %s',xml)
    end
    dta=fread(fid,inf,'*char')';
    fclose(fid);
    
    [vertStart, end_idx, extents, matches, vertTokens] = regexpi(dta,'<Vertex X="([^"]*)" Y="([^"]*)"/>');
   if(isempty(vertStart))
    [vertStart, end_idx, extents, matches, vertTokens] = regexpi(dta,'<Vertex X="([^"]*)" Y="([^"]*)" Z="([^"]*)"/>');
   end
   
    allVertTokens = cat(1,vertTokens{:});
    
    ndims=size(allVertTokens,2);
    
    if (isempty(allVertTokens))
        contours=[];
        contoursClosed=[];
        names=[];
        names_alt=[];
        return;
    end
    
    verts=reshape(sscanf(sprintf('%s*', allVertTokens{:}), '%f*'),[],ndims);
    if (ndims==3)
        verts=verts(:,1:2);
    end
    [regionStarts, end_idx, extents, matches, regTokens] = regexpi(dta,'<Region [^>]*Type="([^"]*)"[^>]*>');
    regionTypes = cellfun(@str2double,cat(2,regTokens{:}))>0;
    [annotationStart, end_idx, extents, matches, annTokens] = regexpi(dta,'<Annotation [^>]* Name="([^"]*)"[^>]*>');
    names = cat(2,annTokens{:});
    
    
           [attributeStart, end_idx, extents, matches, attTokens] = regexpi(dta,'<Attribute Name="Description" Id="([^"]*)" Value="([^"]*)"/>');
        atts= cat(1,attTokens{:});
        if(isempty(atts))
            names_alt=[];
        else
         names_alt=atts(:,2)';
        end
        
        

    
  
    [n,annotationBin] = histc(regionStarts,[annotationStart,inf]);
    [n,regionBin] = histc(vertStart,[regionStarts,inf]);
    annotationBin2 = annotationBin(regionBin);
    
    for it = 1:length(regionStarts)
        strokes{it}=verts(regionBin==it,:);
    end
    for it = 1:length(annotationStart)
        contours{it}=strokes(annotationBin==it);
        contoursClosed{it} = regionTypes(annotationBin==it);
    end
end