%ep_extractDatabyCondition
%For each subject, for each ROI, save all data into a V x T x condition x rep array.
%Note: C's method would just create one big GM (all voxels) x T x condition
%x rep array and later index into GM using an ROI (defined by a subset of
%voxels)
%Note: all runs were perfectly timed with metronome

clear;

%Analysis parameters to change per subject
subject = 23;
%Order of conditions
% cond_order = [3 4 1 2 4 1 2 3 4 2 3 1 5 5 6 6 7 7]; %s3
% cond_order = [1 4 2 3 1 3 4 2 1 3 2 4 6 6 7 7];     %s4
% cond_order = [2 1 3 4 3 4 1 2 4 1 2 3 5 5 6 6 7 7]; %s5
% cond_order = [4 2 3 1 2 4 3 1 3 2 4 1 5 5 6 6 7 7]; %s8
% cond_order = [NaN 3 2 4 3 1 2 4 2 1 4 3 1 5 5 6 6 NaN 7 7]; %s15 (runs 1 and 18 were bad)
% cond_order = [2 1 3 4 3 4 1 2 4 1 2 3 5 5 6 6 7 7]; %s20
% cond_order = [3 4 2 1 4 2 3 1 2 4 3 1 5 5 6 6 7 7]; %s21
cond_order = [1 2 3 4 1 4 3 2 4 3 2 1 5 5 6 6 7 7]; %s23

ideal_n_reps = 3;
% ideal_n_reps = [3 3 3 3 2 2 2]; %# reps the subject SHOULD have completed for each condition

ROIs = {'AngularG', 'Cerebellum', 'HeschlsG', 'STG', 'MotorCortex', 'lTPJ', 'rTPJ', 'PCC', 'precuneus'}; nROI = length(ROIs);
conditions = {'1B', '2B', '8B', 'I', 'I_noise', 'Listen', 'Imagine'};
TR = 1.7;
runLength = 148; %We collected 154 TRs/run and removed the first 6 during preprocessing
nRuns = length(cond_order); runStarts = 1:runLength:(runLength*nRuns);
filepath = '../preprocessed_ROI_data_keyboard_main/';

data = cell(nROI,1); %Initialize the big dataset

for ROI = 1:nROI
    
    %Load data for this ROI into a V x TR matrix and remove voxel coords
    ROIdata = load([filepath 'keyboard1' num2str(subject) '/' ROIs{ROI} '.txt']); ROIdata = ROIdata(:,4:end);
    
    %Extract the TR segments that correspond to each condition to make a V x T x cond x rep matrix for this ROI 
    for cond = 1:length(conditions)
        cond_runs = find(cond_order==cond); n_cond_reps = length(cond_runs);
        
        for rep = 1:ideal_n_reps
            if rep <= n_cond_reps
                curr_run = cond_runs(rep);
                ROIdata_org(:,:,cond,rep) = ROIdata(:,runStarts(curr_run):runStarts(curr_run)+runLength-1);
            elseif rep > n_cond_reps
                ROIdata_org(:,:,cond,rep) = NaN; %If a subject didn't complete a rep of one condition, save as NaNs
            end
        end
        
    end
    
    data{ROI} = ROIdata_org; %Save the V x T x cond x rep data for this ROI into the big dataset. 
    
    data_ROIavg(ROI,:,:,:) = mean(ROIdata_org,1); %Save the T x cond x rep data for this ROI (average voxel)
    clear ROIdata_org;
    
end

save(['reshaped_by_conditions/s' num2str(subject) '.mat'], 'data', 'data_ROIavg', 'conditions', 'ROIs');                
       
