function [CPF, WF, CPs] = grasp_object(cad)
for iN = 1:20
    N = iN;
    fprintf('Tring N = %d\n', iN);
    for itry = 1:1e3
        CPs = zeros(3, N);
        CNs = zeros(3, N);
        faces = randsample(1:size(cad.mesh, 1), N);
        for iiv = 1 : N
            iv = faces(iiv);
            ratio = rand(3, 1);
            ratio = ratio / norm(ratio, 1);
            [cp, cn] = getContactNormal(cad, iv, ratio);
            CPs(:, iiv) = cp;
            CNs(:, iiv) = cn;
        end

        % friction coefficient
        mu = 0.3;
        
        % the number of side facets of a linearized polyhedral friction cone
        M = 10;

        [CPF, CNF] = frictionCone(CPs, CNs, mu, M);
        [WF] = contactScrew(CPF, CNF);
        [bFCF, zmaxF] = isForceClosure(WF);
        if bFCF
            % print out results
            N
            CPs
            zmaxF
            return;
        end
    end
end
