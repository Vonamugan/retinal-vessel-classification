% script vyzaduje nasledujici funkce: 
% 1. fce 
% 2. fce_jednotlive_cevy
% 3. fce_kontrola
% 4. fce_median_cevy
% dale je potreba nastavit cestu pro slozky s daty
% ===================
% uceni a testovani trva > 280.456546 seconds.
% nasledna klasifikace pro 1 obrazek trva > 88.615256 seconds.
clear all
clc
warning("off","all"); % (warning vyskakuje pri postupnem vyplneni tabulky)
%%
% tic
q = 0;
f = waitbar(q,"Bude to chvili trvat ... ");
%% pred spustenim nastavit tri slozky ~\clasified ~\images  a ~\manual1 :
listing_Evy = dir("C:\Users\START\Desktop\PROJ ABO\vessels_classification_HRF\clasified");
listing_images = dir("C:\Users\START\Desktop\PROJ ABO\vessels_classification_HRF\images");
listing_bin = dir("C:\Users\START\Desktop\PROJ ABO\vessels_classification_HRF\manual1");
% listing_dont_care = dir("C:\Users\START\Desktop\PROJ ABO\vessels_classification_HRF\mask");

% listing_Evy(3:8).name;
% listing_images(42:47).name
% listing_bin(42:47).name
%% vyplnovani tabulky T s priznaky 
% (1.MEDIAN V AKTUALNIM KUSU CEVY, 
% 2. KVADR.OD. V A.K.C., 
% 3. PRUMER V A.K.C. 
% 4. HODNOTA AKTUALNIHO PIXELU, 
% 5. LABLE AKTUALNIHO PIXELU)

% indexovani = {};
T = table('Size',[0 5],'VariableTypes',{'double','double','double', 'double','uint8'},'VariableNames',{'median','kvadr_odch','mean','pomer','vysl'});
% tic Elapsed time is 201.913078 seconds.
for i = 1:5
    raz = fullfile(listing_Evy(1).folder,(listing_Evy(2+i).name));
    dva = fullfile(listing_images(1).folder,(listing_images(41+i).name));
    tri = fullfile(listing_bin(1).folder,(listing_bin(41+i).name));
[med_pomer_b_g, kv_odch_pomer_b_g, mean_pomer_b_g, pomer1, ~, vysl,~] = fce( raz, dva, tri);
med_pomer_b_g = med_pomer_b_g(:);
kv_odch_pomer_b_g = kv_odch_pomer_b_g(:);
mean_pomer_b_g = mean_pomer_b_g(:);
pomer1 = pomer1(:);
C = [length(med_pomer_b_g~=0); length(kv_odch_pomer_b_g~=0); length(mean_pomer_b_g~=0); length(pomer1~=0) ];
C_cell = {med_pomer_b_g~=0; kv_odch_pomer_b_g~=0; mean_pomer_b_g~=0; pomer1~=0 };
[M,I] = min(C);
nenul = find(C_cell{I(1)});

med_pomer_b_g = med_pomer_b_g(nenul);
kv_odch_pomer_b_g = kv_odch_pomer_b_g(nenul);
mean_pomer_b_g = mean_pomer_b_g(nenul);
pomer1 = pomer1(nenul);
vysl = vysl(nenul);

sz = length(med_pomer_b_g(:));

T.median((i-1)*sz+1:sz*i) = med_pomer_b_g(:);
T.kvadr_odch((i-1)*sz+1:sz*i) = kv_odch_pomer_b_g(:);
T.mean ((i-1)*sz+1:sz*i) = mean_pomer_b_g(:);
T.pomer((i-1)*sz+1:sz*i)  = pomer1(:);
T.vysl ((i-1)*sz+1:sz*i) = vysl(:);

% indexovani{i} = obsh;
q = q + 0.1;
waitbar(q,f,["pro " + num2str(i) + "/5 obrazku jsou vytvorene priznaky"]);
end


% toc
%% rozdeleni testovacich a trenovacich dat
% vysledek : dataTest a dataTrain
cv = cvpartition(height(T),'HoldOut',0.3);
idx = cv.test;
dataTest=T(idx,:);
dataTrain=T(~idx,:);
q = q + 0.1;
waitbar(q,f,"Data jsou rozdelene pro testovani a trenovani ... ");
%% trenovani, testovani random forest
% tic  Elapsed time is 106.5590 seconds pro 50 trees
ResponseVarName = 'vysl';
treeBag = TreeBagger(50,dataTrain,ResponseVarName);
Yfit = predict(treeBag,dataTest);
q = q + 0.1;
waitbar(q,f,"Random forest model je vytvoren ... ");
% toc
%% accuracy pro jednotlive pixely, neni to konecna accuracy. na obrazku je potreba uprava, aby kusy cev obsahovali jen jeden typ pixelu
% tic
R = dataTest.vysl;
RR = [];
for x = 1:length(Yfit)
    pom = Yfit(x,1);
    pomo = pom{1};
RR(x,1) = str2double(pomo);
end
rr = find(R==0);
R(rr)=[];
RR(rr)=[];
porovnani = R==RR;
disp(["accuracy of random forest pixel classification before median = " + 100*(sum(porovnani)/length(Yfit)) + "%"]);
% toc

%% predtim jsme ucili a trenovali trees na jednotlive pixely, ted chci videt vysledek jako obrazek na naucene drive siti. bereme 15_h(neucil se na tom ani netestoval):

[med_pomer_b_g, kv_odch_pomer_b_g, mean_pomer_b_g, pomer1, obsh, vysl,skel] = fce( fullfile(listing_Evy(1).folder,(listing_Evy(end).name)), fullfile(listing_images(1).folder,(listing_images(end).name)), fullfile(listing_bin(1).folder,(listing_bin(end).name)));
sz = length(med_pomer_b_g(:));
T_posledni = table('Size',[0 4],'VariableTypes',{'double','double','double', 'double'},'VariableNames',{'median','kvadr_odch','mean','pomer'});
T_posledni.median(1:sz) = med_pomer_b_g(:);
T_posledni.kvadr_odch(1:sz)  = kv_odch_pomer_b_g(:);
T_posledni.mean (1:sz)  = mean_pomer_b_g(:);
T_posledni.pomer(1:sz)   = pomer1(:);

% predikce:
Yfit2 = predict(treeBag,T_posledni);
% detekovane pixely naskladame nazpet do podoby obrazku(D) :
RR = [];
for x = 1:length(Yfit2)
    pom = Yfit2(x,1);
    pomo = pom{1};
RR(x) = str2double(pomo);
end
D = reshape(RR,1168,1752);
q = q + 0.1;
waitbar(q,f,"Predikce obrazku probehla, posledni upravy ... ");

%% uprava, aby kusy cev obsahovali jen jeden class (byla pouzita hodnota medianu)
% viz fce_median_cevy
[B,~,~] = fce_median_cevy(obsh, D);

%% pro zobrazeni naseho vysledku a _Eva dat 1 do if:
if 1
figure()
imshowpair(B,vysl,"montage");
title("Zleva - nase klasifikace, zprava - hotove data pro porovnani vysledku.");
end
%% vypisuje procento spravne a spatne detekovanych pixelu
% (pixelu v skeletu, tloustka cevy neni brana v potaz, lze ji umele zmenit
% bez zlepseni ucinnosti klasifikace)
vysl_skel = double(vysl).*double(skel);
obr_skel = double(B).*double(skel);
[spravne, spatne] = fce_kontrola(obr_skel, vysl_skel);
disp(["spravne = " + num2str(( spravne/(spravne+spatne)*100 )) + " %"]);
disp(["spatne = " + num2str((  spatne/(spravne+spatne) *100)) + " %"]);

disp(["spravne = " + num2str(spravne) + " px"]);
disp(["spatne = " + num2str(spatne) + " px"]);
% toc
waitbar(1,f,"Hotovo! ");
