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


