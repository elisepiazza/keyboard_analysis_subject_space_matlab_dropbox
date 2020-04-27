%ep_analyze

clear;

subject = 1;
ROI = 1; %Options: AngularG, HeschlsG, STG, Motor, lTPJ, rTPJ, PCC
n_cropped_TRs = 10; %crop N TRs from beginning and end
% cond = 7; %Options: 1B, 2B, 8B, I, .05, I_M, I_A


load(['reshaped_by_conditions/s' num2str(subject) '.mat']);
nReps = size(data_ROIavg,4);
choose = @(samples) samples(randi(numel(samples)));

data_ROIavg = data_ROIavg(:,n_cropped_TRs+1:end-n_cropped_TRs,:,:);

for cond = 1:length(conditions)
    
    %Plot ROI time course for each run
    figure('Units', 'pixels', 'Position', [100 100 1000 375]);
    colors = {[1 0 0], [1 .5 0], [0 1 0], [0 .5 1], [0 0 1]};
    for rep = 1:nReps
        plot(data_ROIavg(ROI,:,cond,rep), 'color', colors{rep}); hold on; plot(nanmean(data_ROIavg(ROI,:,cond,:),4),'k','LineWidth',2);
        xlabel('TR'); ylabel('BOLD'); title([ROIs{ROI} smooth_tags{smoothOrNot} ' time series (' conditions{cond} ')']); ylim([-10 10]); set(gca, 'FontSize', 16);
    end
%     print(gcf, '-dtiff', ['../figures/s' num2str(subject) '/Time series by rep (' conditions{cond} '_' ROIs{ROI} smooth_tags{smoothOrNot} ').tif']);
        
    %Compute ISC (for each rep of a given condition, correlate the average ROI time series for that rep w/ the average across the other reps
    nReps = 5;
    for rep = 1:nReps
        others = nanmean(data_ROIavg(ROI,:,cond,setdiff([1:nReps],rep)),4);
        rs_and_ps = corrcoef(data_ROIavg(ROI,:,cond,rep),others);
        ISC(rep,cond) = rs_and_ps(2,1);
                
        rand_cond = choose(setdiff(1:length(conditions),cond)); %pick a random condition that's not this one
        others_rand_cond = nanmean(data_ROIavg(ROI,:,rand_cond,setdiff([1:nReps],rep)),4); %average the reps for another condition (and the other reps) that's not this one
        rs_and_ps_rand = corrcoef(data_ROIavg(ROI,:,cond,rep),others_rand_cond);
        ISC_rand(rep,cond) = rs_and_ps_rand(2,1);
    end
    
end


%Plot ISC for all conditions
N = nReps;
x = 1:length(conditions);
y = nanmean(ISC);
errors = nanstd(ISC)/sqrt(N);

figsize = [100 100 400 375]; barwidth = .5; barcolor = [.9 .5 0];
figure('Units', 'pixels', 'Position', figsize);
bar(x,y,barwidth,'facecolor', barcolor); hold on;
errorbar(x,y,errors,'k.', 'LineWidth', 1)

xticklab = conditions;
xlabel('Condition'); ylabel('Cross-rep ISC by condition (r)'); title([ROIs{ROI} smooth_tags{smoothOrNot}]); xlim([.3 7.7]); ylim([0 .6]); set(gca, 'XTickLabel', xticklab, 'FontSize', 16, 'FontName', 'Helvetica');
% print(gcf, '-dtiff', ['../figures/s' num2str(subject) '/Cross-rep ISC by condition (' ROIs{ROI} smooth_tags{smoothOrNot} ').tif']);


%Plot ISC for all conditions
N = nReps;
x = 1:length(conditions);
y = nanmean(ISC_rand);
errors = nanstd(ISC_rand)/sqrt(N);

figsize = [100 100 400 375]; barwidth = .5; barcolor = [.5 .9 0];
figure('Units', 'pixels', 'Position', figsize);
bar(x,y,barwidth,'facecolor', barcolor); hold on;
errorbar(x,y,errors,'k.', 'LineWidth', 1)

xticklab = conditions;
xlabel('Condition'); ylabel('Cross-cond, cross-rep ISC by condition (r)'); title([ROIs{ROI} smooth_tags{smoothOrNot}]); xlim([.3 7.7]); ylim([0 .6]); set(gca, 'XTickLabel', xticklab, 'FontSize', 16, 'FontName', 'Helvetica');
% print(gcf, '-dtiff', ['../figures/s' num2str(subject) '/Cross-cond, cross-rep ISC by condition (' ROIs{ROI} smooth_tags{smoothOrNot} ').tif']);

% %Plot ISC for each successive run for melody 1, melody 2
% figure('Units', 'pixels', 'Position', [100 100 900 375]);
% subplot(1,2,1); plot(corr_melody1, 'bo', 'MarkerSize', 16, 'MarkerFaceColor', 'b'); xlim([0 6]); title([ROI_names{whichROI} smooth_tags{smoothOrNot} ' (Melody 1)']); xlabel('Run'); ylabel('ISC (btwn this run and others)'); set(gca, 'FontSize', 16);
% subplot(1,2,2); plot(corr_melody2, 'bo', 'MarkerSize', 16, 'MarkerFaceColor', 'b'); xlim([0 6]); title([ROI_names{whichROI} smooth_tags{smoothOrNot} ' (Melody 2)']); xlabel('Run'); ylabel('ISC (btwn this run and others'); set(gca, 'FontSize', 16);
% print(gcf, '-dtiff', ['../figures/ISC by run (' ROI_names{whichROI} smooth_tags{smoothOrNot} ').tif']);


% %% Correlation classifier
% 
% loaf_melody1 = ROI_melody1_runs; %TR x rep for this condition
% loaf_melody2 = ROI_melody2_runs;
% held_out_runs = randperm(nMelodyReps);
% 
% for i = 1:nMelodyReps
%     
%     test_run = held_out_runs(i);
%     
%     %Average of melody 1 training runs (VxT)
%     train_melody1 = mean(loaf_melody1(:,:,setdiff([1:nMelodyReps],test_run)),3);
%     
%     %Average of melody 2 training runs (VxT)
%     train_melody2 = mean(loaf_melody2(:,:,setdiff([1:nMelodyReps],test_run)),3);
%     
%     %Held-out melody 1 run (VxT)
%     test_melody1 = loaf_melody1(:,:,test_run);
%     
%     %Held-out melody 2 run (VxT)
%     test_melody2 = loaf_melody2(:,:,test_run);
%     
%     %Is melody 1 (test) correlated more strongly w/ melody 1 (train) or melody 2 (train)?
%     acc_1 = corrcoef(test_melody1(:,:),train_melody1(:,:)) > corrcoef(test_melody1(:,:),train_melody2(:,:)); acc_1 = acc_1(2,1);
%     
%     %Is melody 2 (test) correlated more strongly w/ melody 1 (train) or melody 2 (train)?
%     acc_2 = corrcoef(test_melody2(:,:),train_melody1(:,:)) < corrcoef(test_melody2(:,:),train_melody2(:,:)); acc_2 = acc_2(2,1);
%     
%     mean_acc(i) = mean([acc_1 acc_2]);
% end
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

%% TR x TR corr matrix within this ROI (within-run corr based on average run)
ROI_melody1_avg_across_runs = mean(ROI_melody1_runs,3); %avg VxT across runs
ROI_melody2_avg_across_runs = mean(ROI_melody2_runs,3);

TR_matrix_melody1 = zeros(runLength,runLength);
TR_matrix_melody2 = zeros(runLength,runLength);
for TR1 = 1:runLength
    for TR2 = 1:runLength
        [r, p] = corrcoef(ROI_melody1_avg_across_runs(:,TR1),ROI_melody1_avg_across_runs(:,TR2));
        TR_matrix_melody1(TR1,TR2) = r(2,1);
        
        [r, p] = corrcoef(ROI_melody2_avg_across_runs(:,TR1),ROI_melody2_avg_across_runs(:,TR2));
        TR_matrix_melody2(TR1,TR2) = r(2,1);
    end
end

figsize = [100 100 900 375];
figure('Units', 'pixels', 'Position', figsize);
subplot(1,2,1); imagesc(TR_matrix_melody1); xlabel('TR'); ylabel('TR'); title(['Pattern corr, TR vs. TR (' ROI_names{whichROI} smooth_tags{smoothOrNot} '), Melody 1']); set(gca, 'FontSize', 16); colorbar;
subplot(1,2,2); imagesc(TR_matrix_melody2); xlabel('TR'); ylabel('TR'); title(['Pattern corr, TR vs. TR (' ROI_names{whichROI} smooth_tags{smoothOrNot} '), Melody 2']); set(gca, 'FontSize', 16); colorbar;
% print(gcf, '-dtiff', ['../figures/Pattern corr (within-run, ' ROI_names{whichROI} smooth_tags{smoothOrNot} ').tif']);

%% TR x TR corr matrix within this ROI (across-run corr)
TR_matrix_melody1_crossrun = zeros(runLength,runLength,nMelodyReps);
TR_matrix_melody2_crossrun = zeros(runLength,runLength,nMelodyReps);

for rep = 1:nMelodyReps
    
    for TR1 = 1:runLength
        for TR2 = 1:runLength
            [r, p] = corrcoef(ROI_melody1_runs(:,TR1,rep),mean(ROI_melody1_runs(:,TR2,setdiff([1:nMelodyReps],rep)),3));
            TR_matrix_melody1_crossrun(TR1,TR2,rep) = r(2,1);
            
            [r, p] = corrcoef(ROI_melody2_runs(:,TR1,rep),mean(ROI_melody2_runs(:,TR2,setdiff([1:nMelodyReps],rep)),3));
            TR_matrix_melody2_crossrun(TR1,TR2,rep) = r(2,1);
        end
    end
    
end

figsize = [100 100 900 375];
figure('Units', 'pixels', 'Position', figsize);
subplot(1,2,1); imagesc(mean(TR_matrix_melody1_crossrun,3)); xlabel('TR'); ylabel('TR'); title(['Pattern corr, TR vs. TR (' ROI_names{whichROI} smooth_tags{smoothOrNot} '), Melody 1']); set(gca, 'FontSize', 16); colorbar;
subplot(1,2,2); imagesc(mean(TR_matrix_melody2_crossrun,3)); xlabel('TR'); ylabel('TR'); title(['Pattern corr, TR vs. TR (' ROI_names{whichROI} smooth_tags{smoothOrNot} '), Melody 2']); set(gca, 'FontSize', 16); colorbar;
% print(gcf, '-dtiff', ['../figures/Pattern corr (across-run, ' ROI_names{whichROI} smooth_tags{smoothOrNot} ').tif']);



nCondReps = sum(cond_order==cond); %# of reps to include in cross-run ISC

% 
%         others_ROIavg_cond(:,cond,rep) = nanmean(data_ROIavg(ROI,:,cond,setdiff([1:nReps],rep)),4);
%     
%         corr_cond_rs_and_ps = corrcoef(data_ROIavg(ROI,:,cond,rep),others_ROIavg_cond(:,cond,rep));
%         corr_cond(cond,rep) = corr_cond_rs_and_ps(2,1);


%Old version: Compute ISC (for each run of a given category, correlate the ROI VxT matrix for that run with the average VxT matrix across the other runs)


% save('A1_ISCs_across_runs.mat', 'corr_metro', 'corr_nometro', 'corr_melody1_metro', 'corr_melody2_metro', 'corr_crossmelody1_metro', 'corr_crossmelody2_metro', 'corr_rand1', 'corr_rand2', 'corr_crossrand1', 'corr_crossrand2');


