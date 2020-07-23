%ep_extractDatabyCondition
%For each subject, for each ROI, save all data into a V x T x condition x rep array.
%Note: C's method would just create one big GM (all voxels) x T x condition
%x rep array and later index into GM using an ROI (defined by a subset of
%voxels)
%Note: all runs were perfectly timed with metronome

clear;

%Analysis parameters to change per subject
subject = 123;

%Order of conditions
% cond_order = [3 4 1 2 4 1 2 3 4 2 3 1 5 5 6 6 7 7]; %s103
% cond_order = [1 4 2 3 1 3 4 2 1 3 2 4 6 6 7 7];     %s104
% cond_order = [2 1 3 4 3 4 1 2 4 1 2 3 5 5 6 6 7 7]; %s105
% cond_order = [4 2 3 1 2 4 3 1 3 2 4 1 5 5 6 6 7 7]; %s108
% cond_order = [NaN 3 2 4 3 1 2 4 2 1 4 3 1 5 5 6 6 NaN 7 7]; %s115 (runs 1 and 18 were bad)
% cond_order = [3 1 4 2 3 1 2 4 3 2 1 4 5 5 6 6 7 7]; %s117
% cond_order = [2 1 3 4 3 4 1 2 4 1 2 3 5 5 6 6 7 7]; %s120
% cond_order = [3 4 2 1 4 2 3 1 2 4 3 1 5 5 6 6 7 7]; %s121
% cond_order = [1 3 4 2 4 3 1 2 1 4 3 2 5 5 6 6 7 7]; %s122
cond_order = [1 2 3 4 1 4 3 2 4 3 2 1 5 5 6 6 7 7]; %s123

ROIs = {'AngularG', 'Cerebellum', 'HeschlsG', 'STG', 'MotorCortex', 'lTPJ', 'rTPJ', 'PCC', 'precuneus'}; nROI = length(ROIs);
scramble_conditions = {'1B', '2B', '8B', 'I'}; n_scramble_conditions = length(scramble_conditions); n_scramble_reps = 3; scramble_cond_nums = [1 2 3 4];
control_conditions = {'I_noise', 'Listen', 'Imagine'}; n_control_conditions = length(control_conditions); n_control_reps = 2; control_cond_nums = [5 6 7];
TR = 1.7;
nTRs = 148; %We collected 154 TRs/run and removed the first 6 during preprocessing
filepath = '../data/';

%Initialize the big datasets
data_scramble = cell(nROI,1);
data_control = cell(nROI,1);

for ROI = 1:nROI
    
    %Load data for this ROI into a V x TR matrix   
    ROIdata = load([filepath 'sub-' num2str(subject) '/' ROIs{ROI} '.txt']); 
    %Remove 1st 3 columns of voxel coords
    ROIdata = ROIdata(:,4:end); 
    %Reshape into V x TR x rep
    ROIdata = reshape(ROIdata,[size(ROIdata,1) nTRs 18]); 
    
    %Initialize the empty arrays for scramble and control conditions
    ROIdata_scramble = zeros(size(ROIdata,1),nTRs,n_scramble_conditions,n_scramble_reps);
    ROIdata_control = zeros(size(ROIdata,1),nTRs,n_control_conditions,n_control_reps);
    
    %Extract the TR segments that correspond to each condition to make a V x T x cond x rep matrix for this ROI 
    
    %Do this for 4 scrambled conditions
    for cond = 1:n_scramble_conditions
        curr_cond = scramble_cond_nums(cond);
        cond_runs = find(cond_order==curr_cond); 
        ROIdata_scramble(:,:,cond,:) = ROIdata(:,:,cond_runs);
    end
    
    %Do this for 3 controls
    for cond = 1:n_control_conditions
        curr_cond = control_cond_nums(cond);
        cond_runs = find(cond_order==curr_cond);
        ROIdata_control(:,:,cond,:) = ROIdata(:,:,cond_runs);
    end

    %Save the V x T x cond x rep data for this ROI into the big dataset. 
    data_scramble{ROI} = ROIdata_scramble; 
    data_control{ROI} = ROIdata_control;
    
    %Save the T x cond x rep data for this ROI (average voxel)
    data_ROIavg_scramble(ROI,:,:,:) = mean(ROIdata_scramble,1); 
    data_ROIavg_control(ROI,:,:,:) = mean(ROIdata_control,1);
    
end

save(['../reshaped_by_conditions/sub-' num2str(subject) '.mat'], 'data_scramble', 'data_control', 'data_ROIavg_scramble', 'data_ROIavg_control', 'scramble_conditions', 'control_conditions', 'ROIs');                
       



% for ROI = 1:nROI
%     
%     %Load data for this ROI into a V x TR matrix and remove voxel coords
%     ROIdata = load([filepath 'sub-' num2str(subject) '/' ROIs{ROI} '.txt']); ROIdata = ROIdata(:,4:end);
%     
%     %Extract the TR segments that correspond to each condition to make a V x T x cond x rep matrix for this ROI 
%     for cond = 1:length(conditions)
%         cond_runs = find(cond_order==cond); n_cond_reps = length(cond_runs);
%         
%         for rep = 1:ideal_n_reps
%             if rep <= n_cond_reps
%                 curr_run = cond_runs(rep);
%                 ROIdata_org(:,:,cond,rep) = ROIdata(:,runStarts(curr_run):runStarts(curr_run)+runLength-1);
%             elseif rep > n_cond_reps
%                 ROIdata_org(:,:,cond,rep) = NaN; %If a subject didn't complete a rep of one condition, save as NaNs
%             end
%         end
%         
%     end
%     
%     data{ROI} = ROIdata_org; %Save the V x T x cond x rep data for this ROI into the big dataset. 
%     
%     data_ROIavg(ROI,:,:,:) = mean(ROIdata_org,1); %Save the T x cond x rep data for this ROI (average voxel)
%     clear ROIdata_org;
%     
% end
% 
% save(['reshaped_by_conditions/s' num2str(subject) '.mat'], 'data', 'data_ROIavg', 'conditions', 'ROIs');                
%        
