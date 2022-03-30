clear all
clc
%% nacitani obr
obr_rgb = imread("01_dr.JPG");
obr = im2double(imread("01_dr.JPG"));
% obr_mask = im2double(imread("14_dr_mask.tif"));
obr_bin = imread("01_dr.tif");
%% skeletonizace
obr_bin = logical( obr_bin );
skel = bwskel(obr_bin);

%% hledani uzlu
kriz =  [1  0  0  0  0  0  1 ;
         0  1  0  0  0  1  0 ;
         0  0  1  0  1  0  0 ;
         0  0  0  1   0 0  0 ;
         0  0  1  0  1  0  0 ;
         0  1  0  0  0  1  0 ;
         1  0  0  0  0  0  1 ]/13;

kriz2 = [0  0  0  1  0  0  0 ;
         0  0  0  1  0  0  0 ;
         0  0  0  1  0  0  0 ;
         1  1  1  1  1  1  1 ;
         0  0  0  1  0  0  0 ;
         0  0  0  1  0  0  0 ;
         0  0  0  1  0  0  0 ]/13;

M = zeros(size(skel));
prah = 7;
% prah = 6.2;
for i = 1:size(skel, 1)-6      % ve for cyklu prochazime cely obrazek, vystrihneme ctverec 7x7 a provedeme konvoluci s krizem a krizem2
                                    % za predpokladem ze v miste uzlu soucet konvolucnich obrazku bude > nez vybrany prah  
    for j = 1:size(skel, 2)-6  
        obr_7x7 =  skel(i:i+6,j:j+6);
        konv = conv2(kriz, obr_7x7, "same");
        konv2 = conv2(kriz2, obr_7x7, "same");
        if sum(sum(konv))>prah || sum(sum(konv2))>prah
        % do matice M ulozime 1 v pripade ze soucet konvolucnich obrazku je vetsi nez prah:
        M(i+3,j+3) = 1;
        end
    end
end

% M do jednoho bodu
figure(1)
M(M~=skel) = 0; 
M = logical(M) ;
stredy_uzlu = regionprops(M,'centroid');
% stredy_uzlu = round(stredy_uzlu);
centroids = cat(1,stredy_uzlu.Centroid);
centroids = round(centroids);
imshow(skel)
% hold on
% plot(centroids(:,1),centroids(:,2),'rx','MarkerSize',15,'LineWidth',2)
% hold off
%
obsh = (zeros(size(obr_bin)));
for i = 1:length(centroids)
jeden_kruh = fce_kruh(size(obr_bin,1), size(obr_bin,2),centroids(i,1),centroids(i,2));
obsh = obsh + jeden_kruh;
end
obsh = (logical(obsh));
pom = obr_bin;
pom(obsh == 1)=0;

stats = regionprops(pom,"PixelList");

sz = size(obr_bin);
[A] = fce_jednotlive_cevy(stats,1,sz);
%napr.
% figure(3);imshow(A);
%% histogramy ruznych slozek

% R = im2double(obr_rgb(:,:,1));
% hodnoty_jen_cev = R(obr_bin);
% bar(imhist(hodnoty_jen_cev));
% title("R");


%% klasifikace cev mezi uzly 
% ...


%%
function kruh = fce_kruh(Y, X,a,b)
[col, row] = meshgrid(1:X, 1:Y);
center_X = a;
center_Y = b;
radius = 18;
kruh = (row - center_Y).^2 ...
    + (col - center_X).^2 <= radius.^2;

end
function [A] = fce_jednotlive_cevy(stats,n,sz)
reg = stats(n).PixelList;
% sz = size(obr_bin);
A = zeros(sz);
X = reg(:,1);
Y = reg(:,2);
ind = sub2ind(sz,Y,X);
A = A(:); A(ind) = 1; A = reshape(A,sz);
end
