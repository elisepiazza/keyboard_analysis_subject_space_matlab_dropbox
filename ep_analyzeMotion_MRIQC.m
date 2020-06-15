%ep_analyzeMotion_MRIQC
%Analyze average FD from MRIQC
clear;
filepath = '../motion/';

%Analyze average FD (from MRIQC) 
load([filepath 'FD_from_MRIQC.mat']);

subjects = [101 102 103 104 105 108 109 110 115 117 120 121 122 123]; nSubs = length(subjects);

nRuns = [23 8 18 16 18 18 18 18 20 18 18 18 18 18];
headcase = {[1:23] [1:8] [] [1:6] [1:18] [] [] [] [] [] [] [] [] []}; %In which runs did we use the headcase?

headcase_data = NaN(23,nSubs);
no_headcase_data = NaN(23,nSubs);

headcase_data(:,1) = s101;
headcase_data(1:8,2) = s102(1:8);
headcase_data(1:6,4) = s104(1:6);
headcase_data(1:18,5) = s105;

no_headcase_data(1:18,2) = s102(9:end);
no_headcase_data(1:18,3) = s103;
no_headcase_data(1:10,4) = s104(7:end);
no_headcase_data(1:18,6) = s108;
no_headcase_data(1:18,7) = s109;
no_headcase_data(1:18,8) = s110;
no_headcase_data(1:20,9) = s115;
no_headcase_data(1:18,10) = s117;
no_headcase_data(1:18,11) = s120;
no_headcase_data(1:18,12) = s121;
no_headcase_data(1:18,13) = s122;
no_headcase_data(1:18,14) = s123;

plot(1:nSubs,no_headcase_data,'ko','MarkerSize',8,'LineWidth',1); hold on;
plot(1:nSubs,headcase_data,'co','MarkerSize',8,'LineWidth',1);
set(gca,'FontSize',16); xlim([0 15]); xlabel('Subject'); ylabel('Avg FD in a Run (from MRIQC)'); 



