%ep_computeCorrClass
%For each subject, for each ROI, for each of the 4 scrambled conditions,
%make an averaged VxT matrix (loaf) across nRep-1 reps and hold out the remaining
%one. For each held-out loaf, which of the 4 other conditions is it most correlated with? (Chance = .25)
%Repeat for nReps


%TO ADD: in which areas is I_A more correlated w/ I than the other 3
%scrambles?

clear;

subject = 3;
nCond = 4;

load(['reshaped_by_conditions/s' num2str(subject) '.mat']);
nReps = size(data_ROIavg,4);
choose = @(samples) samples(randi(numel(samples)));

nROIs = length(ROIs);
n_cropped_TRs = 10; %crop N TRs from beginning and end
reps_per_cond = [3 3 3 3 2 2 2];

data_ROIavg = data_ROIavg(:,n_cropped_TRs+1:end-n_cropped_TRs,:,:);

for ROI = 1:nROIs
    
    data_thisROI = data{ROI}; %The extracted 4D matrix should be V x T x cond x rep
    
    held_out_runs = randperm(nReps);
    
    for i = 1:nReps
        
            test_run = held_out_runs(i);

            %Average of 1B training runs (VxT)
            train_1B = mean(data_thisROI(:,:,1,setdiff([1:nReps],test_run)),4);
            
            %Average of 2B training runs (VxT)
            train_2B = mean(data_thisROI(:,:,2,setdiff([1:nReps],test_run)),4);

            %Average of 8B training runs (VxT)
            train_8B = mean(data_thisROI(:,:,3,setdiff([1:nReps],test_run)),4);

            %Average of I training runs (VxT)
            train_I = mean(data_thisROI(:,:,4,setdiff([1:nReps],test_run)),4);
            
            %Held-out 1B run (VxT)
            test_1B = data_thisROI(:,:,1,test_run);
            
            %Held-out 2B run (VxT)
            test_2B = data_thisROI(:,:,2,test_run);
            
            %Held-out 8B run (VxT)
            test_8B = data_thisROI(:,:,3,test_run);

            %Held-out I run (VxT)
            test_I = data_thisROI(:,:,4,test_run);
            
            %Is train_1B most strongly correlated with its own held-out (test) loaf than the other 3? 
            R1 = corrcoef(train_1B(:,:),test_1B(:,:)); R2 = corrcoef(train_1B(:,:),test_I(:,:)); R3 = corrcoef(train_1B(:,:),test_8B(:,:)); R4 = corrcoef(train_1B(:,:),test_2B(:,:));
            acc1 = R1(2,1) > [R2(2,1) R3(2,1) R4(2,1)]; acc_1B(i) = sum(acc1) == 3;
          
            %Is train_2B most strongly correlated with its own held-out (test) loaf than the other 3? 
            R1 = corrcoef(train_2B(:,:),test_2B(:,:)); R2 = corrcoef(train_2B(:,:),test_I(:,:)); R3 = corrcoef(train_2B(:,:),test_8B(:,:)); R4 = corrcoef(train_2B(:,:),test_1B(:,:));
            acc1 = R1(2,1) > [R2(2,1) R3(2,1) R4(2,1)]; acc_2B(i) = sum(acc1) == 3;
         
            %Is train_8B most strongly correlated with its own held-out (test) loaf than the other 3? 
            R1 = corrcoef(train_8B(:,:),test_8B(:,:)); R2 = corrcoef(train_8B(:,:),test_I(:,:)); R3 = corrcoef(train_8B(:,:),test_2B(:,:)); R4 = corrcoef(train_8B(:,:),test_1B(:,:));
            acc1 = R1(2,1) > [R2(2,1) R3(2,1) R4(2,1)]; acc_8B(i) = sum(acc1) == 3;

            %Is train_1 most strongly correlated with its own held-out (test) loaf than the other 3? 
            R1 = corrcoef(train_I(:,:),test_I(:,:)); R2 = corrcoef(train_I(:,:),test_8B(:,:)); R3 = corrcoef(train_I(:,:),test_2B(:,:)); R4 = corrcoef(train_I(:,:),test_1B(:,:));
            acc1 = R1(2,1) > [R2(2,1) R3(2,1) R4(2,1)]; acc_I(i) = sum(acc1) == 3;
    end
    
    ROI_acc(ROI,1) = mean(acc_1B);
    ROI_acc(ROI,2) = mean(acc_2B);
    ROI_acc(ROI,3) = mean(acc_8B);
    ROI_acc(ROI,4) = mean(acc_I);

end

figsize = [100 100 400 500];
figure('Units', 'pixels', 'Position', figsize); imagesc(ROI_acc); xlabel('Condition'); ylabel('ROI'); set(gca, 'XTickLabel', conditions(1:4), 'YTickLabel', ROIs, 'FontSize', 16, 'FontName', 'Helvetica'); colorbar; caxis([0 1]);
print(gcf, '-dtiff', ['../figures/s' num2str(subject) '/Corr classifier.tif']);

%
% %Plot corr classifier results across runs
% N = length(held_out_runs);
% x = 1;
% y = mean(mean_acc);
% errors = std(mean_acc)/sqrt(N);
%
% figsize = [100 100 300 375]; barwidth = .6; barcolor = [.5 0 .9];
% figure('Units', 'pixels', 'Position', figsize);
% bar(x,y,barwidth,'facecolor',barcolor); hold on;
% errorbar(x,y,errors,'k.', 'LineWidth', 1)
%
% xlabel('Melody 1 vs. Melody 2'); ylabel('Mean accuracy across runs'); title(['Corr classifier (' ROI_names{whichROI} smooth_tags{smoothOrNot} ')']); set(gca, 'FontSize', 16, 'FontName', 'Helvetica');
% % print(gcf, '-dtiff', ['../figures/Corr classifier (' ROI_names{whichROI} smooth_tags{smoothOrNot} ').tif']);

