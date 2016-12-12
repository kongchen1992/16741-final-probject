% 16-741 Mechanics of Manipulation, Fall 2015
% Author: Sung Kyun Kim (kimsk@cs.cmu.edu)
%
% W: a set of normalized contact screws [[cix; ciy; ciz; c0ix; c0iy; c0iz] ...]; 6x(NM) matrix
% bFC: a flag which is true if the grasp is force closure; boolean
% zmax: the maximum value of the objective function at the optimal point; scalar

function [bFC, zmax] = isForceClosure(W)

N = size(W, 2);

W = W./repmat(sqrt(sum(W.^2, 1)), 6, 1);
P = mean(W, 2);

A = bsxfun(@minus, W, P)';
b = ones(1, N);

if rank(A) ~= 6
    bFC = false;
    zmax = NaN;
    return
end

e = linprog(P, A, b);
zmax = -P'*e;

bFC = zmax < 1;
