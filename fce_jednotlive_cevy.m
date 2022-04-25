function [A] = fce_jednotlive_cevy(stats,n,sz)
reg = stats(n).PixelList;
% sz = size(obr_bin);
A = zeros(sz);
X = reg(:,1);
Y = reg(:,2);
ind = sub2ind(sz,Y,X);
A = A(:); A(ind) = 1; A = reshape(A,sz);
A = logical(A);
end