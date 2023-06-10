clc
clear all
close all

% load the data
startdate = '01/01/2000';
enddate = '12/31/2022';
f = fred
KOY = fetch(f,'NGDPRSAXDCKRQ',startdate,enddate)
JPY = fetch(f,'JPNRGDPEXP',startdate,enddate)

koy = log(KOY.Data(:,2));
jpy = log(JPY.Data(:,2));

koq = KOY.Data(:,1);
jpq = JPY.Data(:,1);

T = size(koy,1);
T = size(jpy,1);

% Hodrick-Prescott filter
lam = 1600;
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

tauKOGDP = A\koy;
tauJPGDP = A\jpy;

% detrended GDP
koytilde = koy-tauKOGDP;
jpytilde = jpy-tauJPGDP;

% plot detrended GDP
kodates = 2000:1/4:2022.1/4; zerovec = zeros(size(koy));
jpdates = 2000:1/4:2022.1/4; zerovec = zeros(size(jpy));
figure
title('Detrended log(real GDP) 2000Q1-2022Q4'); hold on
plot(koq, koytilde,'b', koq, zerovec,'y')
plot(jpq, jpytilde,'r', jpq, zerovec,'y')
datetick('x', 'yyyy-qq')

legend

% compute sd(y), sd(c), rho(y), rho(c), corr(y,c) (from detrended series)
koysd = std(koytilde)*100;
jpysd = std(jpytilde)*100;

koyrho = corrcoef(koytilde(2:T),koytilde(1:T-1)); koyrho = koyrho(1,2);
jpyrho = corrcoef(jpytilde(2:T),jpytilde(1:T-1)); jpyrho = jpyrho(1,2);

corrkoyjpy = corrcoef(koytilde(1:T),jpytilde(1:T)); corrkoyjpy = corrkoyjpy(1,2);

disp(['Percent standard deviation of detrended log real GDP for Korea: ', num2str(koysd),'.']); disp(' ')
disp(['Percent standard deviation of detrended log real GDP for Japan: ', num2str(jpysd),'.']); disp(' ')

disp(['Serial correlation of detrended log real GDP for Korea: ', num2str(koyrho),'.']); disp(' ')
disp(['Serial correlation of detrended log real GDP for Japan: ', num2str(jpyrho),'.']); disp(' ')