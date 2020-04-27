%ep_extractDatabyCondition
%For each subject, for each ROI, save all data into a V x T x condition x rep array.
%Note: C's method would just create one big GM (all voxels) x T x condition
%x rep array and later index into GM using an ROI (defined by a subset of
%voxels)
%Note: all runs had a metronome

clear;

%Analysis parameters to change per subject
subject = 1;
cond_order = [2 3 6 4 7 4 1 7 2 1 4 2 4 7 3 4 3 1 7 5 2 1 6]; %order of conditions
ideal_n_reps = 5; %# reps the subject SHOULD have completed for each condition
runs_by_session = [12 11]; %# of runs in each session
smoothOrNot = 1; %Use smoothed ROIs (1) or not (2)

ROIs = {'HeschlsG', 'STG', 'MotorCortex', 'lTPJ', 'rTPJ', 'PCC'}; % FIX ANGULARG!!
conditions = {'1B', '2B', '8B', 'I', '.05', 'I_M', 'I_A'};
smooth_tags = {'_withsmoothing', '_nosmoothing'};
TR = 1.7;
runLength = 148; %We collected 154 TRs/run and removed the first 6 during preprocessing
nRuns = sum(runs_by_session); runStarts = 1:runLength:(runLength*nRuns);
filepath = '../preprocessed_ROI_data_keyboard_main/';

data = cell(6,1); %Initialize the big dataset

for ROI = 1:length(ROIs)
    
    %Load the 2 sessions for this ROI
    ROIdata_session1 = load([filepath 'keyboard10' num2str(subject) '/session1/' ROIs{ROI}  smooth_tags{smoothOrNot} '.txt']); data_1_no_voxel_IDs = ROIdata_session1(:,4:end);
    ROIdata_session2 = load([filepath 'keyboard10' num2str(subject) '/session2/' ROIs{ROI}  smooth_tags{smoothOrNot} '.txt']); data_2_no_voxel_IDs = ROIdata_session2(:,4:end);
    
    %Concatenate the 2 sessions for this ROI into one voxel x TR matrix
    ROIdata = horzcat(data_1_no_voxel_IDs, data_2_no_voxel_IDs);
    
    %Extract the TR segments that correspond to each condition to make a V x T x cond x rep matrix for this ROI 
    for cond = 1:length(conditions)
        cond_reps = find(cond_order==cond); n_cond_reps = length(cond_reps);
        
        for rep = 1:ideal_n_reps
            if rep <= n_cond_reps
                curr_rep = cond_reps(rep);
                ROIdata_org(:,:,cond,rep) = ROIdata(:,runStarts(curr_rep):runStarts(curr_rep)+runLength-1);
            elseif rep > n_cond_reps
                ROIdata_org(:,:,cond,rep) = NaN; %If a subject didn't complete a rep of one condition, save as NaNs
            end
        end
        
    end
    
    data{ROI} = ROIdata_org; %Save the V x T x cond x rep data for this ROI into the big dataset. 
    
    data_ROIavg(ROI,:,:,:) = mean(ROIdata_org,1); %save the avgV x T x cond x rep data for this ROI
    clear ROIdata_org;
    
end

save(['reshaped_by_conditions/s' num2str(subject) '.mat'], 'data', 'data_ROIavg', 'conditions', 'ROIs', 'smooth_tags', 'smoothOrNot');                
       
