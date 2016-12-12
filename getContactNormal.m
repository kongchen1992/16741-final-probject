function [cp, cn] = getContactNormal(obj, iv, ratio)
    % Get a contact normal at an interpolated point from three vertices of iv-th facet with respect to ratio
    %
    % iv: index for iv-th facet vertices V{iv}; scalar
    % ratio: interpolation ratio corresponding to each vertex [r1; r2; r3]; 3x1 vector;
    %       sum of r1, r2, r3 should be 1; sum(ratio)=1
    % cp: contact point position [pix; piy; piz]; 3x1 vector
    % cn: inward-pointing direction of contact normal [nix; niy; niz]; 3x1 vector
    
    % check input arguments
    if iv > size(obj.mesh, 1)
        error('Index iv should be less than or equal to the number of mesh!');
    end
    if abs(sum(ratio)-1) > eps
        warning('The sum of ratio for interpolation is not 1! L1 normalized value will be used...');
        ratio = ratio./sum(ratio);
    end
    
    % contact point position; interpolated from three vertices of iv-th facet with respect to ratio
    V = obj.vtx(obj.mesh(iv, :), :)';
    cp = V * ratio;
    
    % inward-pointing contact normal direction; inward-pointing normal vector of iv-th facet
    cn = cross(V(:,2)-V(:,1), V(:,3)-V(:,2));	% clockwise winding for inward-pointing

    % trick to handle the direction
    if V(:, 1)'*cn > 0
        cn = -cn;
    end
end
